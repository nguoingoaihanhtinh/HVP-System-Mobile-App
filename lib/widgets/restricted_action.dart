import 'package:flutter/material.dart';

import '../app/repositories.dart';
import '../core/messages.dart';
import '../data/models/member.dart';
import '../pages/membership/membership_screen.dart';

/// UC15 step 5 / UC16 step 7: blocks check-in and redemption while the
/// account is FROZEN or INACTIVE, or has no active package, and offers the
/// renewal CTA instead.
class RestrictedAction {
  static bool isBlocked(String memberId) {
    final repo = Repositories.membership;
    final member = repo.member(memberId);
    if (member == null) return false;
    return member.isRestricted || repo.activeMembership(memberId) == null;
  }

  static Future<void> guard(
      BuildContext context, Future<void> Function() action) async {
    final memberId = Repositories.currentMemberId;
    if (!isBlocked(memberId)) return action();

    final member = Repositories.membership.member(memberId);
    final message = switch (member?.status) {
      MemberStatus.inactive => Msgs.viewOnly,
      MemberStatus.frozen => Msgs.restricted,
      _ => Msgs.membershipExpired,
    };
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chưa thể thực hiện'),
        content: Text(message.display),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ĐỂ SAU')),
          FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MembershipScreen()));
              },
              child: const Text('GIA HẠN')),
        ],
      ),
    );
  }
}
