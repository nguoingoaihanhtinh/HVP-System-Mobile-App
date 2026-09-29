import 'package:flutter/foundation.dart';

import '../../core/idempotency.dart';
import '../../core/messages.dart';
import '../../core/result.dart';
import '../models/lifecycle_records.dart';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/package_type.dart';
import '../models/point_transaction.dart';
import '../models/renewal_request.dart';
import '../repositories/membership_repository.dart';
import 'mock_db.dart';
import 'mock_lifecycle_repository.dart';

class MockMembershipRepository implements MembershipRepository {
  MockMembershipRepository(this.db, this.lifecycle);

  final MockDb db;
  final MockLifecycleRepository lifecycle;

  static const receptionistInbox = 'ROLE:RECEPTIONIST';

  @override
  Listenable get changes => db;

  @override
  DateTime get serverToday => db.today;

  @override
  Member? member(String memberId) => db.members[memberId];

  @override
  Membership? activeMembership(String memberId) =>
      db.membershipWhere(memberId, MembershipStatus.active);

  @override
  Membership? scheduledMembership(String memberId) =>
      db.membershipWhere(memberId, MembershipStatus.scheduled);

  @override
  List<Membership> memberships(String memberId) =>
      db.memberships.where((m) => m.memberId == memberId).toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

  @override
  List<PackageType> packageTypes() => List.unmodifiable(db.packageTypes);

  @override
  int dpBalance(String memberId) => db.balances.dp(memberId);

  @override
  int marksBalance(String memberId) => db.balances.marks(memberId);

  @override
  int availableMarks(String memberId) {
    final member = db.members[memberId];
    if (member == null || member.marksStatus == MarksStatus.frozen) return 0;
    return db.balances.marks(memberId) - db.balances.marksHeld(memberId);
  }

  @override
  bool needsRenewalReminder(String memberId) {
    if (scheduledMembership(memberId) != null) return false;
    final active = activeMembership(memberId);
    if (active == null) return true;
    final daysLeft = active.daysLeft(db.today);
    final sessionsLeft = active.remainingSessions;
    return (daysLeft != null && daysLeft <= db.config.renewalReminderDays) ||
        (sessionsLeft != null &&
            sessionsLeft <= db.config.renewalReminderSessions);
  }

  @override
  RenewalRequest? pendingRenewal(String memberId) {
    for (final request in db.renewalRequests) {
      if (request.memberId == memberId &&
          request.status == RenewalStatus.pending) {
        return request;
      }
    }
    return null;
  }

  @override
  List<AppNotification> notificationsFor(String userId) => db.notifications
      .where((item) => item.recipient == userId)
      .toList()
      .reversed
      .toList();

  @override
  Future<Result<RenewalRequest>> submitRenewalRequest({
    required String memberId,
    required String? desiredPackageTypeId,
    required ContactChannel? channel,
    required String clientRequestId,
    String? note,
  }) async {
    await db.delay();
    // Retry of the same form: return the request already created.
    for (final request in db.renewalRequests) {
      if (request.clientRequestId == clientRequestId) {
        return Ok(request, message: Msgs.renewalSent);
      }
    }
    if (desiredPackageTypeId == null || channel == null) {
      return const Err(Msgs.renewalMissing);
    }
    if (pendingRenewal(memberId) != null) {
      return const Err(Msgs.renewalDuplicate);
    }

    final request = RenewalRequest(
      id: newId('RR'),
      memberId: memberId,
      currentMembershipId: activeMembership(memberId)?.id,
      desiredPackageTypeId: desiredPackageTypeId,
      contactChannel: channel,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      clientRequestId: clientRequestId,
      createdAt: db.now,
    );
    db.renewalRequests.add(request);
    db.audit(memberId, 'RENEWAL_REQUESTED', 'renewal_requests', request.id);
    db.notify(
        receptionistInbox,
        'RENEWAL_REQUEST',
        'Yêu cầu gia hạn mới',
        '${db.members[memberId]?.fullName ?? memberId} muốn gia hạn '
            '${db.packageById(desiredPackageTypeId).name} '
            '(${channel.label}).');
    db.commit();
    return Ok(request, message: Msgs.renewalSent);
  }

  @override
  List<RenewalRequest> pendingRenewals() => db.renewalRequests
      .where((request) => request.status == RenewalStatus.pending)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  RenewalRequest? _request(String id) {
    for (final request in db.renewalRequests) {
      if (request.id == id) return request;
    }
    return null;
  }

  @override
  Future<Result<RenewalRequest>> logContactAttempt(
      String requestId, String staffId) async {
    await db.delay();
    final request = _request(requestId);
    if (request == null || request.status != RenewalStatus.pending) {
      return const Err(Msgs.requestNotPending);
    }
    request.contactAttempts++;
    db.audit(staffId, 'RENEWAL_CONTACTED', 'renewal_requests', request.id,
        after: 'attempt ${request.contactAttempts}');
    db.commit();
    return Ok(request);
  }

  @override
  Future<Result<Membership>> approveRenewal(
      String requestId, String staffId) async {
    await db.delay();
    final request = _request(requestId);
    if (request == null || request.status != RenewalStatus.pending) {
      return const Err(Msgs.requestNotPending);
    }
    final activated =
        activate(request.memberId, request.desiredPackageTypeId, staffId);
    if (activated is Err<Membership>) return activated;
    final membership = (activated as Ok<Membership>).value;

    request
      ..status = RenewalStatus.completed
      ..handledBy = staffId
      ..handledAt = db.now
      ..resultingMembershipId = membership.id;
    db.audit(staffId, 'RENEWAL_COMPLETED', 'renewal_requests', request.id,
        after: membership.id);
    final done = Msgs.renewalCompleted.fill({'package': membership.package.name});
    db.notify(request.memberId, 'RENEWAL_COMPLETED', 'Gia hạn thành công',
        done.text);
    db.commit();
    return Ok(membership, message: activated.message ?? done);
  }

  @override
  Future<Result<RenewalRequest>> cancelRenewal(
      String requestId, String staffId, String reason) async {
    await db.delay();
    if (reason.trim().isEmpty) return const Err(Msgs.cancelReasonRequired);
    final request = _request(requestId);
    if (request == null || request.status != RenewalStatus.pending) {
      return const Err(Msgs.requestNotPending);
    }
    request
      ..status = RenewalStatus.cancelled
      ..handledBy = staffId
      ..handledAt = db.now
      ..cancelReason = reason.trim();
    db.audit(staffId, 'RENEWAL_CANCELLED', 'renewal_requests', request.id,
        reason: reason.trim());
    db.notify(request.memberId, 'RENEWAL_CANCELLED', 'Yêu cầu gia hạn bị huỷ',
        Msgs.renewalCancelled.fill({'reason': reason.trim()}).text);
    db.commit();
    return Ok(request, message: Msgs.renewalCancelled.fill({'reason': reason.trim()}));
  }

  /// LT-02 / UC14 step 9. Early renewal is stacked as SCHEDULED
  /// (start = old end + 1, Q-H14) and earns the early-renewal Marks once per
  /// old membership. Otherwise the package is ACTIVE now, which unfreezes the
  /// Marks (UC15) and reactivates an INACTIVE account (UC16).
  Result<Membership> activate(
      String memberId, String packageTypeId, String? staffId) {
    if (scheduledMembership(memberId) != null) {
      return const Err(Msgs.alreadyScheduled);
    }
    final package = db.packageById(packageTypeId);
    final today = db.today;
    final current = activeMembership(memberId);
    final canStack = current != null &&
        current.endDate != null &&
        !current.isPastEnd(today) &&
        !current.isOutOfSessions;

    if (current != null && !canStack) {
      current
        ..status = MembershipStatus.expired
        ..expiredAt = db.now;
      db.audit(staffId, 'MEMBERSHIP_EXPIRED', 'memberships', current.id,
          before: 'ACTIVE', after: 'EXPIRED');
    }

    final start =
        canStack ? current.endDate!.add(const Duration(days: 1)) : today;
    final history = memberships(memberId);
    final membership = Membership(
      id: newId('MS'),
      memberId: memberId,
      package: package,
      branchName: current?.branchName ?? 'HVP Boxing Quận 7',
      startDate: start,
      endDate: package.durationDays == null
          ? null
          : start.add(Duration(days: package.durationDays! - 1)),
      totalSessions: package.totalSessions,
      status: canStack ? MembershipStatus.scheduled : MembershipStatus.active,
      previousMembershipId:
          current?.id ?? (history.isEmpty ? null : history.first.id),
      activatedBy: staffId,
      activatedAt: db.now,
    );
    db.memberships.add(membership);
    db.audit(staffId, 'MEMBERSHIP_CREATED', 'memberships', membership.id,
        after: membership.status.label);

    Msg? message;
    if (canStack) {
      db.members[memberId]?.lastActivityAt = db.now;
      final posted = db.ledger.post(
        memberId: memberId,
        type: PointType.marks,
        source: 'EARLY_RENEWAL',
        idempotencyKey: IdempotencyKeys.renewal(current.id),
        requestedAmount: db.config.earlyRenewalMarks,
        countsTowardCap: false,
        createdBy: staffId,
        membershipId: current.id,
      );
      if (!posted.duplicate) {
        message = Msgs.earlyRenewalBonus
            .fill({'marks': posted.transaction.amount});
      }
    } else {
      final messages =
          lifecycle.onMembershipActivated(memberId, membership.id, staffId);
      if (messages.isNotEmpty) message = messages.last;
    }
    db.commit();
    return Ok(membership, message: message);
  }
}
