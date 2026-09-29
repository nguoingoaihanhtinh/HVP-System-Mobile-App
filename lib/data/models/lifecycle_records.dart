/// Append-only records written by UC15–UC17 and the audit trail.
library;

enum FreezeAction { freeze, unfreeze }

/// Row of `marks_freeze_logs`. Freezing never creates a point transaction.
class MarksFreezeLog {
  final String id;
  final String memberId;
  final String? membershipId;
  final FreezeAction action;
  final int marksBalanceSnapshot;
  final int marksHeldSnapshot;

  /// UC15 BR122: balance at unfreeze differs from the freeze snapshot (MSG41).
  final bool balanceMismatch;
  final String idempotencyKey;
  final DateTime createdAt;

  const MarksFreezeLog({
    required this.id,
    required this.memberId,
    required this.membershipId,
    required this.action,
    required this.marksBalanceSnapshot,
    required this.marksHeldSnapshot,
    required this.idempotencyKey,
    required this.createdAt,
    this.balanceMismatch = false,
  });
}

/// Completed session (the part of `attendances` UC17 needs).
class Attendance {
  final String id;
  final String memberId;
  final DateTime completedAt;

  const Attendance(
      {required this.id, required this.memberId, required this.completedAt});
}

enum ComebackStatus { granted, capped }

/// Row of `comeback_cycles`. Unique (member, previous attendance).
class ComebackCycle {
  final String id;
  final String memberId;
  final String previousAttendanceId;
  final String returnAttendanceId;
  final int gapDays;
  final int dpGranted;
  final ComebackStatus status;
  final DateTime createdAt;

  const ComebackCycle({
    required this.id,
    required this.memberId,
    required this.previousAttendanceId,
    required this.returnAttendanceId,
    required this.gapDays,
    required this.dpGranted,
    required this.status,
    required this.createdAt,
  });
}

/// Row of `notifications`. [recipient] is a user id or `ROLE:<ROLE>`.
class AppNotification {
  final String id;
  final String recipient;
  final String type;
  final String title;
  final String body;
  final String? dedupeKey;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipient,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.dedupeKey,
  });
}

/// Row of `audit_logs`. [actor] null means SYSTEM.
class AuditLog {
  final String id;
  final String? actor;
  final String action;
  final String entity;
  final String entityId;
  final String? before;
  final String? after;
  final String? reason;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.actor,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.createdAt,
    this.before,
    this.after,
    this.reason,
  });
}
