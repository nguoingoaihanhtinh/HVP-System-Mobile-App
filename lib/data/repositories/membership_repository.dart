import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../models/lifecycle_records.dart';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/package_type.dart';
import '../models/renewal_request.dart';

/// UC14 (member and receptionist sides) and package activation (LT-02).
abstract class MembershipRepository {
  /// Fires whenever membership, member status or notifications change.
  Listenable get changes;

  /// Server date used for expiry and reminders.
  DateTime get serverToday;

  Member? member(String memberId);

  Membership? activeMembership(String memberId);

  /// Early renewal stacked after the active package (Q-H14).
  Membership? scheduledMembership(String memberId);

  /// Newest first.
  List<Membership> memberships(String memberId);

  List<PackageType> packageTypes();

  int dpBalance(String memberId);

  int marksBalance(String memberId);

  /// 0 while Marks are frozen.
  int availableMarks(String memberId);

  /// Package ends within `renewalReminderDays` or has at most
  /// `renewalReminderSessions` sessions left, and no renewal is lined up.
  bool needsRenewalReminder(String memberId);

  RenewalRequest? pendingRenewal(String memberId);

  List<AppNotification> notificationsFor(String userId);

  /// Member side of UC14 (diagram steps 4–6 and 11).
  Future<Result<RenewalRequest>> submitRenewalRequest({
    required String memberId,
    required String? desiredPackageTypeId,
    required ContactChannel? channel,
    required String clientRequestId,
    String? note,
  });

  /// Receptionist queue: PENDING requests, oldest first.
  List<RenewalRequest> pendingRenewals();

  Future<Result<RenewalRequest>> logContactAttempt(
      String requestId, String staffId);

  /// Diagram step 8 "Có" → 9: renew or activate, then notify the member.
  Future<Result<Membership>> approveRenewal(String requestId, String staffId);

  /// Diagram step 8 "Không" → 12: cancel with a reason, notify the member.
  Future<Result<RenewalRequest>> cancelRenewal(
      String requestId, String staffId, String reason);
}
