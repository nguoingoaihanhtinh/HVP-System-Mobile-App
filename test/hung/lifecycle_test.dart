import 'package:flutter_test/flutter_test.dart';
import 'package:hvp_boxing_prototype/core/clock.dart';
import 'package:hvp_boxing_prototype/core/messages.dart';
import 'package:hvp_boxing_prototype/core/result.dart';
import 'package:hvp_boxing_prototype/data/models/lifecycle_records.dart';
import 'package:hvp_boxing_prototype/data/models/member.dart';
import 'package:hvp_boxing_prototype/data/models/membership.dart';
import 'package:hvp_boxing_prototype/data/models/point_transaction.dart';
import 'package:hvp_boxing_prototype/data/repositories/lifecycle_repository.dart';

import 'test_helpers.dart';

void main() {
  group('UC15 freeze / unfreeze', () {
    test('expired package freezes Marks once, balance kept', () async {
      final f = Fixture();
      final marks = f.db.appState.marksBalance;
      f.db.clock.advance(const Duration(days: 11)); // Minh's end date + 1

      await f.lifecycle.runExpiryJob();
      await f.lifecycle.runExpiryJob();

      final member = f.membership.member(Fixture.minh)!;
      expect(member.status, MemberStatus.frozen);
      expect(member.marksStatus, MarksStatus.frozen);
      expect(f.lifecycle.freezeLogs(Fixture.minh), hasLength(1));
      expect(f.db.appState.marksBalance, marks);
      expect(f.db.appState.availableMarks, 0);
      expect(f.membership.availableMarks(Fixture.minh), 0);
      expect(f.db.ledger.forMember(Fixture.minh), isEmpty); // no ledger rows
    });

    test('the end date itself is still valid', () async {
      final f = Fixture();
      f.db.clock.advance(const Duration(days: 10));
      await f.lifecycle.runExpiryJob();
      expect(f.membership.member(Fixture.minh)!.status, MemberStatus.active);
    });

    test('0 sessions left expires a session package', () async {
      final f = Fixture();
      f.membership.activeMembership(Fixture.minh)!.usedSessions = 12;
      await f.lifecycle.runExpiryJob();
      expect(f.membership.member(Fixture.minh)!.status, MemberStatus.frozen);
    });

    test('freeze key is idempotent', () {
      final f = Fixture();
      final member = f.membership.member(Fixture.minh)!;
      expect(f.lifecycle.freezeMarks(member, 'MS-X'), isTrue);
      expect(f.lifecycle.freezeMarks(member, 'MS-X'), isFalse);
    });

    test('a SCHEDULED follow-on package prevents the freeze', () async {
      final f = Fixture();
      f.membership.activate(Fixture.minh, 'PKG-J3M', Fixture.staff);
      f.db.clock.advance(const Duration(days: 11));

      await f.lifecycle.runExpiryJob();

      expect(f.membership.member(Fixture.minh)!.status, MemberStatus.active);
      expect(f.membership.activeMembership(Fixture.minh)!.package.code,
          'JOURNEY_3M');
      expect(f.lifecycle.freezeLogs(Fixture.minh), isEmpty);
    });

    test('activation unfreezes at the same balance', () async {
      final f = Fixture();
      f.db.clock.advance(const Duration(days: 11));
      await f.lifecycle.runExpiryJob();

      final result = f.membership.activate(Fixture.minh, 'PKG-J3M', Fixture.staff);

      expect(result.isOk, isTrue);
      final member = f.membership.member(Fixture.minh)!;
      expect(member.status, MemberStatus.active);
      expect(member.marksStatus, MarksStatus.active);
      final logs = f.lifecycle.freezeLogs(Fixture.minh);
      expect(logs.map((l) => l.action),
          [FreezeAction.freeze, FreezeAction.unfreeze]);
      expect(logs.last.balanceMismatch, isFalse);
      expect(f.db.appState.availableMarks, f.db.appState.marksBalance);
    });

    test('balance change while frozen is flagged (MSG41)', () async {
      final f = Fixture();
      f.db.clock.advance(const Duration(days: 11));
      await f.lifecycle.runExpiryJob();
      f.db.appState.marksBalance -= 5;

      final result = f.membership.activate(Fixture.minh, 'PKG-J3M', Fixture.staff);

      expect((result as Ok).message, Msgs.balanceMismatch);
      expect(f.lifecycle.freezeLogs(Fixture.minh).last.balanceMismatch, isTrue);
    });
  });

  group('UC16 inactive after 12 months', () {
    Future<Fixture> frozenMinh() async {
      final f = Fixture();
      f.db.clock.advance(const Duration(days: 11));
      await f.lifecycle.runExpiryJob();
      return f;
    }

    test('one day before 12 months: warning only, sent once', () async {
      final f = await frozenMinh();
      final member = f.membership.member(Fixture.minh)!;
      member.lastActivityAt =
          addMonths(f.db.today, -12).add(const Duration(days: 1));

      await f.lifecycle.runInactiveJob();
      await f.lifecycle.runInactiveJob();

      expect(member.status, MemberStatus.frozen);
      expect(
          f.membership
              .notificationsFor(Fixture.minh)
              .where((n) => n.type == 'INACTIVE_WARNING'),
          hasLength(1));
    });

    test('12 months without activity: INACTIVE, data kept', () async {
      final f = await frozenMinh();
      final dp = f.db.appState.dpBalance;
      final member = f.membership.member(Fixture.minh)!;
      member.lastActivityAt = addMonths(f.db.today, -12);

      await f.lifecycle.runInactiveJob();

      expect(member.status, MemberStatus.inactive);
      expect(member.inactiveAt, isNotNull);
      expect(f.db.appState.dpBalance, dp);
      expect(f.lifecycle.auditLogs().first.action, 'MEMBER_INACTIVE');
    });

    test('a member with a valid package is never made inactive', () async {
      final f = Fixture();
      f.membership.member(Fixture.minh)!.lastActivityAt =
          addMonths(f.db.today, -24);
      await f.lifecycle.runInactiveJob();
      expect(f.membership.member(Fixture.minh)!.status, MemberStatus.active);
    });

    test('login does not count as activity', () async {
      final f = await frozenMinh();
      final member = f.membership.member(Fixture.minh)!;
      final last = member.lastActivityAt;
      await f.auth.login('minh', 'hvp12345');
      expect(member.lastActivityAt, last);
    });

    test('activation brings an INACTIVE member back to ACTIVE', () async {
      final f = await frozenMinh();
      final member = f.membership.member(Fixture.minh)!;
      member.lastActivityAt = addMonths(f.db.today, -12);
      await f.lifecycle.runInactiveJob();

      f.membership.activate(Fixture.minh, 'PKG-TRIAL', Fixture.staff);

      expect(member.status, MemberStatus.active);
      expect(member.marksStatus, MarksStatus.active);
      expect(member.inactiveAt, isNull);
    });
  });

  group('UC17 comeback bonus', () {
    test('13 days away: no bonus', () async {
      final f = Fixture();
      f.lifecycle.setLastCompletedSessionDaysAgo(Fixture.minh, 13);
      final outcome = await f.lifecycle.onSessionCompleted(Fixture.minh);
      expect(outcome.decision, ComebackDecision.gapTooShort);
      expect(f.lifecycle.comebackCycles(Fixture.minh), isEmpty);
    });

    test('14 days away: +50 DP once per cycle', () async {
      final f = Fixture();
      final dp = f.db.appState.dpBalance;
      f.lifecycle.setLastCompletedSessionDaysAgo(Fixture.minh, 14);

      final first = await f.lifecycle.onSessionCompleted(Fixture.minh);
      final replay = await f.lifecycle.replayLastSessionCompleted(Fixture.minh);

      expect(first.decision, ComebackDecision.granted);
      expect(first.gapDays, 14);
      expect(replay.decision, ComebackDecision.alreadyGranted);
      expect(replay.posted!.duplicate, isTrue);
      expect(f.db.appState.dpBalance, dp + 50);
      expect(f.lifecycle.comebackCycles(Fixture.minh), hasLength(1));
      expect(
          f.db.ledger.findByKey(PointType.dp,
              'comeback:${Fixture.minh}:${f.lifecycle.comebackCycles(Fixture.minh).single.previousAttendanceId}'),
          isNotNull);
    });

    test('next session right after the comeback earns nothing', () async {
      final f = Fixture();
      f.lifecycle.setLastCompletedSessionDaysAgo(Fixture.minh, 20);
      await f.lifecycle.onSessionCompleted(Fixture.minh);
      final next = await f.lifecycle.onSessionCompleted(Fixture.minh);
      expect(next.decision, ComebackDecision.gapTooShort);
    });

    test('bonus is trimmed by the DP monthly cap', () async {
      final f = Fixture();
      f.db.ledger.countTowardCap(Fixture.minh, PointType.dp, 1200 - 45 - 20);
      f.lifecycle.setLastCompletedSessionDaysAgo(Fixture.minh, 30);

      final outcome = await f.lifecycle.onSessionCompleted(Fixture.minh);

      // 45 session DP counted first, 20 room left for the bonus.
      expect(outcome.decision, ComebackDecision.capped);
      expect(outcome.cycle!.dpGranted, 20);
      expect(outcome.cycle!.status, ComebackStatus.capped);
    });
  });

  test('check-in consumes one session of the active package', () {
    final f = Fixture();
    f.lifecycle.onCheckedIn(Fixture.minh);
    expect(f.membership.activeMembership(Fixture.minh)!.remainingSessions, 5);
    expect(f.db.appState.remainingSessions, 5);
    expect(f.membership.activeMembership(Fixture.minh)!.status,
        MembershipStatus.active);
  });
}
