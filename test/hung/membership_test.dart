import 'package:flutter_test/flutter_test.dart';
import 'package:hvp_boxing_prototype/core/messages.dart';
import 'package:hvp_boxing_prototype/core/result.dart';
import 'package:hvp_boxing_prototype/data/models/membership.dart';
import 'package:hvp_boxing_prototype/data/models/renewal_request.dart';

import 'test_helpers.dart';

void main() {
  group('UC14 renewal request', () {
    test('missing package or channel is rejected', () async {
      final f = Fixture();
      final result = await f.membership.submitRenewalRequest(
          memberId: Fixture.minh,
          desiredPackageTypeId: null,
          channel: ContactChannel.phone,
          clientRequestId: 'c1');
      expect((result as Err).message, Msgs.renewalMissing);
    });

    test('a second PENDING request is rejected', () async {
      final f = Fixture();
      final first = await f.membership.submitRenewalRequest(
          memberId: Fixture.minh,
          desiredPackageTypeId: 'PKG-J3M',
          channel: ContactChannel.zalo,
          clientRequestId: 'c1');
      final second = await f.membership.submitRenewalRequest(
          memberId: Fixture.minh,
          desiredPackageTypeId: 'PKG-J3M',
          channel: ContactChannel.zalo,
          clientRequestId: 'c2');
      expect(first.isOk, isTrue);
      expect((second as Err).message, Msgs.renewalDuplicate);
    });

    test('retrying the same form returns the same request', () async {
      final f = Fixture();
      final a = await f.membership.submitRenewalRequest(
          memberId: Fixture.minh,
          desiredPackageTypeId: 'PKG-J3M',
          channel: ContactChannel.zalo,
          clientRequestId: 'same');
      final b = await f.membership.submitRenewalRequest(
          memberId: Fixture.minh,
          desiredPackageTypeId: 'PKG-J3M',
          channel: ContactChannel.zalo,
          clientRequestId: 'same');
      expect((b as Ok).value, (a as Ok).value);
      expect(f.membership.pendingRenewals(), hasLength(2)); // An's seed + Minh
    });

    test('early renewal is SCHEDULED at end + 1 and pays Marks once',
        () async {
      final f = Fixture();
      final current = f.membership.activeMembership(Fixture.minh)!;
      final marksBefore = f.db.appState.marksBalance;
      final request = await f.membership.submitRenewalRequest(
          memberId: Fixture.minh,
          desiredPackageTypeId: 'PKG-J3M',
          channel: ContactChannel.phone,
          clientRequestId: 'c1');

      final approved = await f.membership
          .approveRenewal((request as Ok<RenewalRequest>).value.id, Fixture.staff);

      final next = (approved as Ok<Membership>).value;
      expect(next.status, MembershipStatus.scheduled);
      expect(next.startDate, current.endDate!.add(const Duration(days: 1)));
      expect(next.previousMembershipId, current.id);
      expect(f.db.appState.marksBalance, marksBefore + 50);
      expect(request.value.status, RenewalStatus.completed);
    });

    test('cancel needs a reason and notifies the member', () async {
      final f = Fixture();
      final empty = await f.membership.cancelRenewal('RR-AN-1', Fixture.staff, ' ');
      expect((empty as Err).message, Msgs.cancelReasonRequired);

      final done =
          await f.membership.cancelRenewal('RR-AN-1', Fixture.staff, 'Chưa sắp xếp được');
      expect(done.isOk, isTrue);
      expect(f.membership.notificationsFor(Fixture.an).first.type,
          'RENEWAL_CANCELLED');
      final again = await f.membership.approveRenewal('RR-AN-1', Fixture.staff);
      expect((again as Err).message, Msgs.requestNotPending);
    });
  });
}
