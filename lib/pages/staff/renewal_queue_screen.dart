import 'package:flutter/material.dart';

import '../../app/repositories.dart';
import '../../core/clock.dart';
import '../../core/messages.dart';
import '../../core/result.dart';
import '../../data/models/member.dart';
import '../../data/models/renewal_request.dart';
import '../../theme/app_theme.dart';
import '../../widgets/busy_button.dart';
import '../../widgets/shared_widgets.dart';

/// Receptionist side of UC14 (LT-02): contact the member, then renew or
/// cancel the request.
class RenewalQueueScreen extends StatelessWidget {
  const RenewalQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repositories.membership;
    return AnimatedBuilder(
      animation: repo.changes,
      builder: (context, _) {
        final requests = repo.pendingRenewals();
        return ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Yêu cầu gia hạn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('${requests.length} yêu cầu chờ xử lý',
              style: const TextStyle(color: AppColors.dim)),
          const SizedBox(height: 16),
          if (requests.isEmpty)
            const Panel(
                child: Text('Không có yêu cầu nào đang chờ.',
                    style: TextStyle(color: AppColors.dim))),
          for (final request in requests) _RenewalCard(request: request),
        ]);
      },
    );
  }
}

class _RenewalCard extends StatelessWidget {
  final RenewalRequest request;

  const _RenewalCard({required this.request});

  void _show(BuildContext context, Result<Object?> result) {
    final message = switch (result) {
      Ok(:final message) => message,
      Err(:final message) => message,
    };
    if (message != null) showMessage(context, message.display);
  }

  Future<void> _cancel(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelDialog(),
    );
    if (reason == null || !context.mounted) return;
    final result = await Repositories.membership
        .cancelRenewal(request.id, Repositories.currentStaffId, reason);
    if (context.mounted) _show(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Repositories.membership;
    final member = repo.member(request.memberId);
    final current = repo.activeMembership(request.memberId);
    final desired =
        repo.packageTypes().firstWhere((p) => p.id == request.desiredPackageTypeId);
    final today = repo.serverToday;
    final early = current?.endDate != null && !current!.isPastEnd(today);

    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(member?.fullName ?? request.memberId,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold))),
          StatusPill(
              label: member?.status.label ?? '—',
              color: member?.status == MemberStatus.active
                  ? AppColors.teal
                  : AppColors.amber),
        ]),
        Text(
            '${member?.memberCode ?? ''} · ${request.contactChannel.label} · '
            'gửi ${dmy(request.createdAt)}',
            style: const TextStyle(color: AppColors.dim)),
        const SizedBox(height: 8),
        Text(current == null
            ? 'Gói hiện tại: không có (đã hết hạn)'
            : 'Gói hiện tại: ${current.package.name} · hết hạn '
                '${current.endDate == null ? '—' : dmy(current.endDate!)}'),
        Text('Muốn gia hạn: ${desired.name}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        if (request.note != null)
          Text('“${request.note}”', style: const TextStyle(color: AppColors.dim)),
        Text(
            early
                ? 'Gia hạn sớm → gói mới bắt đầu sau ngày hết hạn, thưởng Marks.'
                : 'Kích hoạt ngay → mở băng Marks nếu đang đóng băng.',
            style: const TextStyle(color: AppColors.faint, fontSize: 12)),
        if (request.contactAttempts > 0)
          Text('Đã liên hệ ${request.contactAttempts} lần',
              style: const TextStyle(color: AppColors.amber, fontSize: 12)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: BusyButton(
              outlined: true,
              label: 'ĐÃ LIÊN HỆ',
              onPressed: () async {
                final result = await repo.logContactAttempt(
                    request.id, Repositories.currentStaffId);
                if (result is Err && context.mounted) _show(context, result);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
                onPressed: () => _cancel(context), child: const Text('HUỶ')),
          ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: BusyButton(
            label: 'ĐỒNG Ý · ĐÃ THU PHÍ',
            onPressed: () async {
              final result = await repo.approveRenewal(
                  request.id, Repositories.currentStaffId);
              if (context.mounted) _show(context, result);
            },
          ),
        ),
      ]),
    );
  }
}

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final controller = TextEditingController();
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Huỷ yêu cầu gia hạn'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: 'Lý do', errorText: error),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('ĐÓNG')),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) {
              setState(() => error = Msgs.cancelReasonRequired.display);
              return;
            }
            Navigator.pop(context, controller.text.trim());
          },
          child: const Text('HUỶ YÊU CẦU'),
        ),
      ],
    );
  }
}
