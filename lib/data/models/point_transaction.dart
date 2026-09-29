enum PointType { dp, marks }

extension PointTypeLabel on PointType {
  String get label => this == PointType.dp ? 'DP' : 'Marks';
}

/// `point_transactions.cap_status`.
enum CapStatus { full, capped, exempt }

/// Row of `point_transactions` (append-only ledger).
///
/// Unique on ([pointType], [idempotencyKey]).
class PointTransaction {
  final String id;
  final String memberId;
  final PointType pointType;

  /// e.g. COMEBACK_BONUS, EARLY_RENEWAL (matches `point_rules.code`).
  final String source;
  final String idempotencyKey;
  final int requestedAmount;
  final int amount;
  final CapStatus capStatus;

  /// null = SYSTEM.
  final String? createdBy;
  final String? membershipId;
  final String? comebackCycleId;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.memberId,
    required this.pointType,
    required this.source,
    required this.idempotencyKey,
    required this.requestedAmount,
    required this.amount,
    required this.capStatus,
    required this.createdAt,
    this.createdBy,
    this.membershipId,
    this.comebackCycleId,
  });
}

/// What the ledger returns: the row plus whether it already existed.
class LedgerPostResult {
  final PointTransaction transaction;
  final bool duplicate;

  const LedgerPostResult(this.transaction, {required this.duplicate});
}
