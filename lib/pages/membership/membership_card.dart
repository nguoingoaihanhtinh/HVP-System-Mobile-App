import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/repositories.dart';
import '../../core/clock.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'membership_screen.dart';

/// Home / Profile "Membership Card": live package summary, opens UC14.
class MembershipCardSummary extends StatelessWidget {
  final bool compact;

  const MembershipCardSummary({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final repo = Repositories.membership;
    return AnimatedBuilder(
      animation: Listenable.merge([repo.changes, appState]),
      builder: (context, _) {
        final memberId = Repositories.currentMemberId;
        final member = repo.member(memberId);
        final active = repo.activeMembership(memberId);
        final status = member?.status.name.toUpperCase() ?? '—';
        final String summary;
        if (active == null) {
          summary = 'Không có gói hoạt động · $status';
        } else {
          final end = active.endDate == null
              ? 'không thời hạn'
              : 'hết hạn ${dmy(active.endDate!)}';
          final sessions = active.remainingSessions == null
              ? 'không giới hạn buổi'
              : '${active.remainingSessions} buổi còn lại';
          summary = compact
              ? '$status · ${active.branchName}'
              : '${active.package.name} · $status · $end\n$sessions · ${active.branchName}';
        }
        void open() => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MembershipScreen()));

        return Panel(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: open,
            leading: compact ? const Icon(Icons.card_membership_outlined) : null,
            title: Text(
                compact ? active?.package.name ?? 'Gói tập' : 'Membership Card',
                style: TextStyle(
                    fontSize: compact ? null : 17, fontWeight: FontWeight.bold)),
            subtitle: Text(summary,
                style: const TextStyle(color: AppColors.dim, height: 1.5)),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
