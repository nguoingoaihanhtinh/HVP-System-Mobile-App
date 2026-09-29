import '../../core/clock.dart';
import 'package_type.dart';

/// `memberships.status`. At most one ACTIVE per member.
enum MembershipStatus { scheduled, active, expired, cancelled }

extension MembershipStatusLabel on MembershipStatus {
  String get label => name.toUpperCase();
}

/// Row of `memberships`.
class Membership {
  final String id;
  final String memberId;
  final PackageType package;
  final String branchName;
  final DateTime startDate;

  /// null only for open-ended packages.
  final DateTime? endDate;

  /// Snapshot of the package at sale time.
  final int? totalSessions;
  int usedSessions;
  MembershipStatus status;

  /// Renewal chain.
  final String? previousMembershipId;
  final String? activatedBy;
  final DateTime activatedAt;
  DateTime? expiredAt;

  Membership({
    required this.id,
    required this.memberId,
    required this.package,
    required this.branchName,
    required this.startDate,
    required this.endDate,
    required this.totalSessions,
    required this.status,
    required this.activatedAt,
    this.usedSessions = 0,
    this.previousMembershipId,
    this.activatedBy,
    this.expiredAt,
  });

  int? get remainingSessions =>
      totalSessions == null ? null : totalSessions! - usedSessions;

  bool get isOutOfSessions =>
      package.expireOnZeroSessions &&
      remainingSessions != null &&
      remainingSessions! <= 0;

  /// Past its end date on [today] (the end date itself is still valid).
  bool isPastEnd(DateTime today) =>
      endDate != null && daysBetween(endDate!, today) > 0;

  int? daysLeft(DateTime today) =>
      endDate == null ? null : daysBetween(today, endDate!);
}
