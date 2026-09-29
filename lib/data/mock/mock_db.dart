import 'package:flutter/foundation.dart';

import '../../app/app_state.dart';
import '../../core/clock.dart';
import '../../core/idempotency.dart';
import '../models/lifecycle_config.dart';
import '../models/lifecycle_records.dart';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/package_type.dart';
import '../models/renewal_request.dart';
import '../models/user.dart';
import 'point_ledger.dart';

/// In-memory stand-in for the PostgreSQL schema in
/// docs/HVP- System Documents/5. Databases/hvp_schema.sql.
///
/// Shared by the mock repositories. Listeners are notified after each change.
class MockDb extends ChangeNotifier {
  static const demoMemberId = 'U-MINH';
  static const otherMemberId = 'U-AN';
  static const receptionistId = 'U-RECEPTION';
  static const demoPassword = 'hvp12345';

  MockDb({
    AppState? appState,
    SimulatedClock? clock,
    this.config = const LifecycleConfig(),
    this.latency = const Duration(milliseconds: 250),
  })  : appState = appState ?? AppState(),
        clock = clock ?? SimulatedClock() {
    balances = BalanceStore(this.appState, demoMemberId);
    ledger = PointLedger(
      balances: balances,
      clock: this.clock,
      dpMonthlyCap: config.dpMonthlyCap,
      marksMonthlyCap: config.marksMonthlyCap,
    );
    _seed();
  }

  final AppState appState;
  final SimulatedClock clock;
  final LifecycleConfig config;

  /// Simulated network delay. Tests use Duration.zero.
  final Duration latency;
  late final BalanceStore balances;
  late final PointLedger ledger;

  final List<AppUser> users = [];
  final Map<String, Member> members = {};
  final List<PackageType> packageTypes = [];
  final List<Membership> memberships = [];
  final List<RenewalRequest> renewalRequests = [];
  final List<MarksFreezeLog> freezeLogs = [];
  final List<Attendance> attendances = [];
  final List<ComebackCycle> comebackCycles = [];
  final List<AppNotification> notifications = [];
  final List<AuditLog> auditLogs = [];

  DateTime get now => clock.now();
  DateTime get today => dateOnly(now);

  Future<void> delay() => latency == Duration.zero
      ? Future<void>.value()
      : Future<void>.delayed(latency);

  AppUser? userById(String id) {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  PackageType packageById(String id) =>
      packageTypes.firstWhere((package) => package.id == id);

  Membership? membershipWhere(String memberId, MembershipStatus status) {
    for (final membership in memberships) {
      if (membership.memberId == memberId && membership.status == status) {
        return membership;
      }
    }
    return null;
  }

  /// Sends a notification unless one with the same [dedupeKey] exists.
  bool notify(String recipient, String type, String title, String body,
      {String? dedupeKey}) {
    if (dedupeKey != null &&
        notifications.any((item) => item.dedupeKey == dedupeKey)) {
      return false;
    }
    notifications.add(AppNotification(
      id: newId('NT'),
      recipient: recipient,
      type: type,
      title: title,
      body: body,
      dedupeKey: dedupeKey,
      createdAt: now,
    ));
    return true;
  }

  void audit(String? actor, String action, String entity, String entityId,
      {String? before, String? after, String? reason}) {
    auditLogs.add(AuditLog(
      id: newId('AL'),
      actor: actor,
      action: action,
      entity: entity,
      entityId: entityId,
      before: before,
      after: after,
      reason: reason,
      createdAt: now,
    ));
  }

  /// Pushes the demo member's state into the prototype's AppState, then
  /// notifies both listeners.
  void commit() {
    final member = members[demoMemberId];
    if (member != null) {
      appState.marksFrozen = member.marksStatus == MarksStatus.frozen;
      final active = membershipWhere(demoMemberId, MembershipStatus.active);
      appState.remainingSessions = active?.remainingSessions ?? 0;
    }
    appState.refresh();
    notifyListeners();
  }

  void _seed() {
    final created = now.subtract(const Duration(days: 400));
    users.addAll([
      AppUser(
          id: demoMemberId,
          username: 'minh',
          fullName: 'Minh Nguyễn',
          email: 'student@hvp.demo',
          phone: '0901234567',
          passwordHash: demoPassword,
          roles: {Role.member},
          createdAt: created),
      AppUser(
          id: otherMemberId,
          username: 'an',
          fullName: 'An Trần',
          email: 'an@hvp.demo',
          phone: '0907654321',
          passwordHash: demoPassword,
          roles: {Role.member},
          createdAt: created),
      AppUser(
          id: 'U-COACH',
          username: 'coach',
          fullName: 'Coach Tuấn',
          email: 'coach@hvp.demo',
          phone: '0911111111',
          passwordHash: demoPassword,
          roles: {Role.coach},
          createdAt: created),
      AppUser(
          id: receptionistId,
          username: 'reception',
          fullName: 'Lễ tân Hoa',
          email: 'reception@hvp.demo',
          phone: '0922222222',
          passwordHash: demoPassword,
          roles: {Role.receptionist},
          createdAt: created),
      AppUser(
          id: 'U-ADMIN',
          username: 'admin',
          fullName: 'Admin HVP',
          email: 'admin@hvp.demo',
          phone: '0933333333',
          passwordHash: demoPassword,
          roles: {Role.admin},
          createdAt: created),
    ]);

    // TRIAL_1M and JOURNEY_3M come from hvp_seed.sql. The session package
    // matches the prototype's "Gói A · 6 buổi còn lại" (ASSUMPTION, C8).
    packageTypes.addAll(const [
      PackageType(
          id: 'PKG-A12',
          code: 'SESSION_12',
          name: 'Gói A · 12 buổi',
          durationDays: 60,
          totalSessions: 12,
          description: 'Gói theo buổi, hết hạn khi hết buổi hoặc hết ngày.'),
      PackageType(
          id: 'PKG-TRIAL',
          code: 'TRIAL_1M',
          name: 'Gói trải nghiệm 1 tháng',
          durationDays: 30,
          totalSessions: null,
          isTrial: true,
          description: 'Tích DP/Marks, giữ streak. Tối đa THE INITIATED.'),
      PackageType(
          id: 'PKG-J3M',
          code: 'JOURNEY_3M',
          name: 'Hành trình 3 tháng (Foundation)',
          durationDays: 90,
          totalSessions: null,
          description: 'Mở khóa Foundation, Rank Trial THE DISCIPLINED.'),
    ]);

    final minhLast = now.subtract(const Duration(days: 3));
    final anLast = now.subtract(const Duration(days: 2));
    members[demoMemberId] = Member(
        userId: demoMemberId,
        memberCode: 'HVP-0001',
        fullName: 'Minh Nguyễn',
        joinedAt: created,
        lastCompletedSessionAt: minhLast,
        lastActivityAt: minhLast);
    members[otherMemberId] = Member(
        userId: otherMemberId,
        memberCode: 'HVP-0002',
        fullName: 'An Trần',
        joinedAt: created,
        lastCompletedSessionAt: anLast,
        lastActivityAt: anLast);
    balances.seed(otherMemberId, dp: 820, marks: 120);

    memberships.addAll([
      Membership(
          id: 'MS-MINH-1',
          memberId: demoMemberId,
          package: packageById('PKG-A12'),
          branchName: 'HVP Boxing Quận 7',
          startDate: today.subtract(const Duration(days: 50)),
          endDate: today.add(const Duration(days: 10)),
          totalSessions: 12,
          usedSessions: 6,
          status: MembershipStatus.active,
          activatedAt: today.subtract(const Duration(days: 50)),
          activatedBy: receptionistId),
      Membership(
          id: 'MS-AN-1',
          memberId: otherMemberId,
          package: packageById('PKG-J3M'),
          branchName: 'HVP Boxing Quận 7',
          startDate: today.subtract(const Duration(days: 85)),
          endDate: today.add(const Duration(days: 5)),
          totalSessions: null,
          status: MembershipStatus.active,
          activatedAt: today.subtract(const Duration(days: 85)),
          activatedBy: receptionistId),
    ]);

    attendances.addAll([
      Attendance(id: 'ATT-MINH-1', memberId: demoMemberId, completedAt: minhLast),
      Attendance(id: 'ATT-AN-1', memberId: otherMemberId, completedAt: anLast),
    ]);

    renewalRequests.add(RenewalRequest(
      id: 'RR-AN-1',
      memberId: otherMemberId,
      currentMembershipId: 'MS-AN-1',
      desiredPackageTypeId: 'PKG-J3M',
      contactChannel: ContactChannel.zalo,
      note: 'Muốn tiếp tục lộ trình 3 tháng.',
      clientRequestId: 'seed',
      createdAt: now.subtract(const Duration(hours: 5)),
    ));

    appState.remainingSessions = 6;
  }
}
