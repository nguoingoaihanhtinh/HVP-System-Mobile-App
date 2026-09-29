import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../app/repositories.dart';
import '../core/messages.dart';
import '../data/models/member.dart';
import '../pages/membership/membership_screen.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

/// Home/Armory banner for UC14–UC16: frozen Marks, inactive (view-only)
/// account, or a package that is about to run out.
class AccountStatusBanner extends StatelessWidget {
  const AccountStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repositories.membership;
    return AnimatedBuilder(
      animation: Listenable.merge([repo.changes, appState]),
      builder: (context, _) {
        final memberId = Repositories.currentMemberId;
        final member = repo.member(memberId);
        if (member == null) return const SizedBox.shrink();
        final pending = repo.pendingRenewal(memberId) != null;

        final (icon, title, body, color) = switch (member.status) {
          MemberStatus.frozen => (
              '🧊',
              'YOUR MARKS ARE WAITING',
              'Gói tập đã hết hạn. ${repo.marksBalance(memberId)} Marks được giữ '
                  'nguyên; đổi quà và check-in tạm khoá cho tới khi gia hạn.',
              AppColors.amber
            ),
          MemberStatus.inactive => (
              '💤',
              'TÀI KHOẢN KHÔNG HOẠT ĐỘNG',
              Msgs.viewOnly.text,
              AppColors.accent
            ),
          MemberStatus.active when repo.needsRenewalReminder(memberId) => (
              '⏳',
              'GÓI TẬP SẮP HẾT HẠN',
              _expiryText(memberId),
              AppColors.amber
            ),
          _ => ('', '', '', AppColors.text),
        };
        if (title.isEmpty) return const SizedBox.shrink();

        return Panel(
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .6)),
                const SizedBox(height: 4),
                Text(
                    pending
                        ? '$body\nĐã gửi yêu cầu gia hạn · chờ lễ tân liên hệ.'
                        : body,
                    style: const TextStyle(color: AppColors.dim, height: 1.4)),
              ]),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MembershipScreen())),
              child: Text(pending ? 'XEM' : 'GIA HẠN'),
            ),
          ]),
        );
      },
    );
  }

  static String _expiryText(String memberId) {
    final repo = Repositories.membership;
    final active = repo.activeMembership(memberId);
    if (active == null) return 'Bạn chưa có gói tập đang hoạt động.';
    final parts = <String>[];
    final days = active.daysLeft(repo.serverToday);
    if (days != null) parts.add('còn $days ngày');
    if (active.remainingSessions != null) {
      parts.add('còn ${active.remainingSessions} buổi');
    }
    return '${active.package.name}: ${parts.join(' · ')}. '
        'Gia hạn sớm để nhận thưởng Marks.';
  }
}
