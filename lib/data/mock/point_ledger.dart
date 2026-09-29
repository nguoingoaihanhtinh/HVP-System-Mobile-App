import '../../app/app_state.dart';
import '../../core/clock.dart';
import '../../core/idempotency.dart';
import '../models/point_transaction.dart';

/// Where balances live in the mock.
///
/// The demo member's balances stay in the prototype's [AppState] so the
/// existing Home, My DP, Fighter Record and Armory screens stay in sync
/// (UI spec §28). Other members use an in-memory map.
class BalanceStore {
  BalanceStore(this.appState, this.demoMemberId);

  final AppState appState;
  final String demoMemberId;
  final Map<String, int> _dp = {};
  final Map<String, int> _marks = {};

  int dp(String memberId) =>
      memberId == demoMemberId ? appState.dpBalance : _dp[memberId] ?? 0;

  int marks(String memberId) =>
      memberId == demoMemberId ? appState.marksBalance : _marks[memberId] ?? 0;

  /// Open redemptions (PENDING/READY). The prototype has no hold yet.
  int marksHeld(String memberId) => 0;

  void seed(String memberId, {required int dp, required int marks}) {
    if (memberId == demoMemberId) return;
    _dp[memberId] = dp;
    _marks[memberId] = marks;
  }

  void add(String memberId, PointType type, int amount) {
    if (memberId == demoMemberId) {
      if (type == PointType.dp) {
        appState.dpBalance += amount;
      } else {
        appState.marksBalance += amount;
      }
      return;
    }
    final map = type == PointType.dp ? _dp : _marks;
    map[memberId] = (map[memberId] ?? 0) + amount;
  }
}

/// Append-only ledger with the DB's two core guarantees:
///
/// * UNIQUE (point_type, idempotency_key): a replay returns the existing row
///   (`duplicate: true`) and changes no balance (DB §4.2, MSG33).
/// * Monthly cap: `amount = min(requested, room left this month)` for sources
///   that count toward the cap (DB §4.3).
class PointLedger {
  PointLedger({
    required this.balances,
    required this.clock,
    required this.dpMonthlyCap,
    required this.marksMonthlyCap,
  });

  final BalanceStore balances;
  final Clock clock;
  final int dpMonthlyCap;
  final int marksMonthlyCap;

  final List<PointTransaction> _rows = [];
  final Map<String, PointTransaction> _byKey = {};
  final Map<String, int> _cappedTotals = {};

  List<PointTransaction> get rows => List.unmodifiable(_rows);

  List<PointTransaction> forMember(String memberId) =>
      _rows.where((row) => row.memberId == memberId).toList();

  PointTransaction? findByKey(PointType type, String key) =>
      _byKey[_uniqueKey(type, key)];

  /// Cap room left for [memberId] in the current server month.
  int capRoom(String memberId, PointType type) {
    final cap = type == PointType.dp ? dpMonthlyCap : marksMonthlyCap;
    final used = _cappedTotals[_monthKey(memberId, type)] ?? 0;
    return (cap - used).clamp(0, cap);
  }

  /// Records points the prototype granted outside this ledger (session DP
  /// from AppState) so the cap sees them.
  void countTowardCap(String memberId, PointType type, int amount) {
    final key = _monthKey(memberId, type);
    _cappedTotals[key] = (_cappedTotals[key] ?? 0) + amount;
  }

  LedgerPostResult post({
    required String memberId,
    required PointType type,
    required String source,
    required String idempotencyKey,
    required int requestedAmount,
    required bool countsTowardCap,
    String? createdBy,
    String? membershipId,
    String? comebackCycleId,
  }) {
    final existing = findByKey(type, idempotencyKey);
    if (existing != null) return LedgerPostResult(existing, duplicate: true);

    var amount = requestedAmount;
    var capStatus = CapStatus.exempt;
    if (countsTowardCap && requestedAmount > 0) {
      final room = capRoom(memberId, type);
      amount = requestedAmount < room ? requestedAmount : room;
      capStatus = amount < requestedAmount ? CapStatus.capped : CapStatus.full;
      countTowardCap(memberId, type, amount);
    }

    final row = PointTransaction(
      id: newId('PT'),
      memberId: memberId,
      pointType: type,
      source: source,
      idempotencyKey: idempotencyKey,
      requestedAmount: requestedAmount,
      amount: amount,
      capStatus: capStatus,
      createdAt: clock.now(),
      createdBy: createdBy,
      membershipId: membershipId,
      comebackCycleId: comebackCycleId,
    );
    _rows.add(row);
    _byKey[_uniqueKey(type, idempotencyKey)] = row;
    balances.add(memberId, type, amount);
    if (memberId == balances.demoMemberId) {
      balances.appState.pointTransactions.insert(
        0,
        PointEntry(
          row.id,
          '$source · ${type.label}${capStatus == CapStatus.capped ? ' · CAPPED' : ''}',
          amount,
          'CONFIRMED',
          createdBy ?? 'System',
        ),
      );
    }
    return LedgerPostResult(row, duplicate: false);
  }

  String _uniqueKey(PointType type, String key) => '${type.name}|$key';

  String _monthKey(String memberId, PointType type) {
    final now = clock.now();
    return '$memberId|${type.name}|${now.year}-${now.month}';
  }
}
