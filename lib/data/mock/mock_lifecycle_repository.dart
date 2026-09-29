import '../../core/clock.dart';
import '../../core/idempotency.dart';
import '../../core/messages.dart';
import '../models/lifecycle_records.dart';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/point_transaction.dart';
import '../repositories/lifecycle_repository.dart';
import 'mock_db.dart';

/// Mock of the backend jobs and event handlers for UC15–UC17.
class MockLifecycleRepository implements LifecycleRepository {
  MockLifecycleRepository(this.db);

  final MockDb db;

  // ---------------------------------------------------------------- UC15

  @override
  Future<JobReport> runExpiryJob() async {
    await db.delay();
    final today = db.today;
    final lines = <String>[];
    var changed = 0;
    var skipped = 0;

    final due = db.memberships
        .where((m) =>
            m.status == MembershipStatus.active &&
            (m.isPastEnd(today) || m.isOutOfSessions))
        .toList();
    for (final membership in due) {
      final member = db.members[membership.memberId];
      if (member == null) continue;
      membership.status = MembershipStatus.expired;
      membership.expiredAt = db.now;
      db.audit(null, 'MEMBERSHIP_EXPIRED', 'memberships', membership.id,
          before: 'ACTIVE', after: 'EXPIRED');

      final next = db.membershipWhere(member.userId, MembershipStatus.scheduled);
      if (next != null) {
        // Follow-on package: no freeze (diagram step 1 "không có gói nối tiếp").
        next.status = MembershipStatus.active;
        db.audit(null, 'MEMBERSHIP_ACTIVATED', 'memberships', next.id,
            before: 'SCHEDULED', after: 'ACTIVE');
        lines.add('${member.fullName}: ${membership.package.name} hết hạn → '
            'kích hoạt gói nối tiếp ${next.package.name}.');
        changed++;
        continue;
      }

      if (freezeMarks(member, membership.id)) {
        lines.add('${member.fullName}: ${membership.package.name} hết hạn → '
            'FROZEN, giữ ${db.balances.marks(member.userId)} Marks.');
        changed++;
      } else {
        lines.add('${member.fullName}: đã đóng băng trước đó (bỏ qua).');
        skipped++;
      }
    }
    if (due.isEmpty) lines.add('Không có gói nào hết hạn hôm nay.');
    db.commit();
    return JobReport(
        job: 'Quét gói hết hạn (UC15) · ${dmy(today)}',
        changed: changed,
        skipped: skipped,
        lines: lines);
  }

  /// Diagram steps 2–3. Returns false when this membership was already
  /// frozen (idempotency key `freeze:{membershipId}`).
  bool freezeMarks(Member member, String membershipId) {
    final key = IdempotencyKeys.freeze(membershipId);
    if (db.freezeLogs.any((log) => log.idempotencyKey == key)) return false;

    if (member.status == MemberStatus.active) {
      member.status = MemberStatus.frozen;
    }
    member.marksStatus = MarksStatus.frozen;
    db.freezeLogs.add(MarksFreezeLog(
      id: newId('FL'),
      memberId: member.userId,
      membershipId: membershipId,
      action: FreezeAction.freeze,
      marksBalanceSnapshot: db.balances.marks(member.userId),
      marksHeldSnapshot: db.balances.marksHeld(member.userId),
      idempotencyKey: key,
      createdAt: db.now,
    ));
    db.audit(null, 'MARKS_FROZEN', 'members', member.userId,
        before: 'ACTIVE', after: 'FROZEN');
    db.notify(member.userId, 'MARKS_FROZEN', 'YOUR MARKS ARE WAITING',
        Msgs.marksFrozen.text,
        dedupeKey: key);
    return true;
  }

  /// Called when a package becomes ACTIVE (UC14 step 9, UC15 steps 6–9,
  /// UC16 step 8). Returns the messages to show to staff.
  List<Msg> onMembershipActivated(
      String memberId, String newMembershipId, String? actor) {
    final member = db.members[memberId];
    if (member == null) return const [];
    final messages = <Msg>[];

    if (member.status == MemberStatus.inactive) {
      member.inactiveAt = null;
      db.audit(actor, 'MEMBER_REACTIVATED', 'members', memberId,
          before: 'INACTIVE', after: 'ACTIVE');
    }
    member.status = MemberStatus.active;
    member.lastActivityAt = db.now;

    if (member.marksStatus == MarksStatus.frozen) {
      final key = IdempotencyKeys.unfreeze(newMembershipId);
      if (!db.freezeLogs.any((log) => log.idempotencyKey == key)) {
        final lastFreeze = db.freezeLogs.lastWhere(
            (log) =>
                log.memberId == memberId && log.action == FreezeAction.freeze,
            orElse: () => MarksFreezeLog(
                id: '',
                memberId: memberId,
                membershipId: null,
                action: FreezeAction.freeze,
                marksBalanceSnapshot: db.balances.marks(memberId),
                marksHeldSnapshot: 0,
                idempotencyKey: '',
                createdAt: db.now));
        final balance = db.balances.marks(memberId);
        final mismatch = lastFreeze.marksBalanceSnapshot != balance;
        db.freezeLogs.add(MarksFreezeLog(
          id: newId('FL'),
          memberId: memberId,
          membershipId: newMembershipId,
          action: FreezeAction.unfreeze,
          marksBalanceSnapshot: balance,
          marksHeldSnapshot: db.balances.marksHeld(memberId),
          balanceMismatch: mismatch,
          idempotencyKey: key,
          createdAt: db.now,
        ));
        member.marksStatus = MarksStatus.active;
        db.audit(actor, 'MARKS_UNFROZEN', 'members', memberId,
            before: 'FROZEN', after: 'ACTIVE');
        final unfrozen = Msgs.marksUnfrozen.fill({'marks': balance});
        db.notify(memberId, 'MARKS_UNFROZEN', 'Marks sẵn sàng sử dụng',
            unfrozen.text,
            dedupeKey: key);
        messages.add(unfrozen);
        if (mismatch) {
          db.audit(actor, 'MARKS_BALANCE_MISMATCH', 'members', memberId,
              before: '${lastFreeze.marksBalanceSnapshot}',
              after: '$balance',
              reason: Msgs.balanceMismatch.code);
          messages.add(Msgs.balanceMismatch);
        }
      }
    }
    return messages;
  }

  // ---------------------------------------------------------------- UC16

  @override
  Future<JobReport> runInactiveJob() async {
    await db.delay();
    final today = db.today;
    final lines = <String>[];
    var changed = 0;
    var skipped = 0;

    for (final member in db.members.values) {
      if (member.status == MemberStatus.inactive) continue;
      final hasValidPackage =
          db.membershipWhere(member.userId, MembershipStatus.active) != null ||
              db.membershipWhere(member.userId, MembershipStatus.scheduled) !=
                  null;
      if (hasValidPackage) continue;

      final reference = member.lastActivityAt ?? member.joinedAt;
      final inactiveDate =
          dateOnly(addMonths(reference, db.config.inactiveAfterMonths));
      final daysLeft = daysBetween(today, inactiveDate);

      if (daysLeft <= 0) {
        final before = member.status.label;
        member.status = MemberStatus.inactive;
        member.marksStatus = MarksStatus.frozen;
        member.inactiveAt = db.now;
        db.audit(null, 'MEMBER_INACTIVE', 'members', member.userId,
            before: before, after: 'INACTIVE');
        db.notify(member.userId, 'ACCOUNT_INACTIVE',
            'Tài khoản không hoạt động', Msgs.accountInactive.text,
            dedupeKey:
                IdempotencyKeys.accountInactive(member.userId, inactiveDate));
        lines.add('${member.fullName}: → INACTIVE (dữ liệu được giữ nguyên).');
        changed++;
      } else if (db.config.inactiveWarningDays > 0 &&
          daysLeft <= db.config.inactiveWarningDays) {
        final sent = db.notify(
            member.userId,
            'INACTIVE_WARNING',
            'Đã lâu bạn chưa quay lại',
            Msgs.inactiveWarning.fill({'days': daysLeft}).text,
            dedupeKey:
                IdempotencyKeys.inactiveWarning(member.userId, inactiveDate));
        if (sent) {
          lines.add('${member.fullName}: cảnh báo, còn $daysLeft ngày.');
          changed++;
        } else {
          lines.add('${member.fullName}: đã cảnh báo cho mốc này (bỏ qua).');
          skipped++;
        }
      } else {
        lines.add('${member.fullName}: còn $daysLeft ngày trước mốc inactive.');
      }
    }
    if (lines.isEmpty) lines.add('Không có tài khoản nào cần xử lý.');
    db.commit();
    return JobReport(
        job: 'Quét tài khoản inactive (UC16) · ${dmy(today)}',
        changed: changed,
        skipped: skipped,
        lines: lines);
  }

  // ---------------------------------------------------------------- UC4/UC17

  @override
  void onCheckedIn(String memberId) {
    final active = db.membershipWhere(memberId, MembershipStatus.active);
    if (active != null && active.totalSessions != null) {
      active.usedSessions++;
    }
    db.commit();
  }

  @override
  Future<ComebackOutcome> onSessionCompleted(String memberId) async {
    final attendance = Attendance(
        id: newId('ATT'), memberId: memberId, completedAt: db.now);
    db.attendances.add(attendance);
    final member = db.members[memberId];
    member?.lastCompletedSessionAt = db.now;
    member?.lastActivityAt = db.now;
    if (memberId == MockDb.demoMemberId) {
      // Session DP was posted by the prototype's AppState; count it for the cap.
      db.ledger.countTowardCap(
          memberId, PointType.dp, db.appState.sessionDpWeight);
    }
    final outcome = _evaluateComeback(memberId, attendance);
    db.commit();
    return outcome;
  }

  @override
  Future<ComebackOutcome> replayLastSessionCompleted(String memberId) async {
    await db.delay();
    final own = db.attendances.where((a) => a.memberId == memberId).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    if (own.isEmpty) {
      return const ComebackOutcome(ComebackDecision.noPreviousSession);
    }
    final outcome = _evaluateComeback(memberId, own.last);
    db.commit();
    return outcome;
  }

  /// UC17 steps 3–7.
  ComebackOutcome _evaluateComeback(String memberId, Attendance returning) {
    // Latest earlier completion; on equal times the one recorded last wins.
    Attendance? previous;
    for (final a in db.attendances) {
      if (a.id == returning.id) break;
      if (a.memberId != memberId ||
          a.completedAt.isAfter(returning.completedAt)) {
        continue;
      }
      if (previous == null || !a.completedAt.isBefore(previous.completedAt)) {
        previous = a;
      }
    }
    if (previous == null) {
      return const ComebackOutcome(ComebackDecision.noPreviousSession);
    }
    final gap = daysBetween(previous.completedAt, returning.completedAt);
    if (gap < db.config.comebackMinGapDays) {
      return ComebackOutcome(ComebackDecision.gapTooShort, gapDays: gap);
    }

    final key = IdempotencyKeys.comeback(memberId, previous.id);
    for (final cycle in db.comebackCycles) {
      if (cycle.memberId == memberId &&
          cycle.previousAttendanceId == previous.id) {
        return ComebackOutcome(ComebackDecision.alreadyGranted,
            gapDays: gap,
            cycle: cycle,
            posted: LedgerPostResult(db.ledger.findByKey(PointType.dp, key)!,
                duplicate: true));
      }
    }

    final cycleId = newId('CB');
    final bonus = db.config.comebackBonusDp;
    final posted = db.ledger.post(
      memberId: memberId,
      type: PointType.dp,
      source: 'COMEBACK_BONUS',
      idempotencyKey: key,
      requestedAmount: bonus,
      countsTowardCap: db.config.comebackCountsTowardCap,
      comebackCycleId: cycleId,
    );
    if (posted.duplicate) {
      return ComebackOutcome(ComebackDecision.alreadyGranted,
          gapDays: gap, posted: posted);
    }
    final granted = posted.transaction.amount;
    final cycle = ComebackCycle(
      id: cycleId,
      memberId: memberId,
      previousAttendanceId: previous.id,
      returnAttendanceId: returning.id,
      gapDays: gap,
      dpGranted: granted,
      status: granted < bonus ? ComebackStatus.capped : ComebackStatus.granted,
      createdAt: db.now,
    );
    db.comebackCycles.add(cycle);
    db.audit(null, 'COMEBACK_BONUS', 'comeback_cycles', cycle.id,
        after: '+$granted DP after $gap days');
    db.notify(memberId, 'COMEBACK_BONUS', 'WELCOME BACK.',
        Msgs.comebackGranted.fill({'days': gap, 'dp': granted}).text,
        dedupeKey: key);
    return ComebackOutcome(
        cycle.status == ComebackStatus.capped
            ? ComebackDecision.capped
            : ComebackDecision.granted,
        gapDays: gap,
        cycle: cycle,
        posted: posted);
  }

  // ---------------------------------------------------------------- demo

  /// Makes the member's last completed session [days] ago (drops newer ones).
  void setLastCompletedSessionDaysAgo(String memberId, int days) {
    final at = db.now.subtract(Duration(days: days));
    db.attendances
        .removeWhere((a) => a.memberId == memberId && a.completedAt.isAfter(at));
    db.attendances
        .add(Attendance(id: newId('ATT'), memberId: memberId, completedAt: at));
    final member = db.members[memberId];
    member?.lastCompletedSessionAt = at;
    member?.lastActivityAt = at;
    db.commit();
  }

  @override
  List<MarksFreezeLog> freezeLogs(String memberId) =>
      db.freezeLogs.where((log) => log.memberId == memberId).toList();

  @override
  List<ComebackCycle> comebackCycles(String memberId) =>
      db.comebackCycles.where((cycle) => cycle.memberId == memberId).toList();

  @override
  List<AuditLog> auditLogs() => List.unmodifiable(db.auditLogs.reversed);
}
