import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/repositories.dart';
import '../../core/clock.dart';
import '../../data/models/member.dart';
import '../../data/models/membership.dart';
import '../../data/models/renewal_request.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'renewal_request_sheet.dart';

/// UC14 (HV-07, HV-08, HV-09, HV-10): package, status, schedule and renewal.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

enum _Range { week, month }

class _MembershipScreenState extends State<MembershipScreen> {
  _Range range = _Range.week;

  @override
  Widget build(BuildContext context) {
    final repo = Repositories.membership;
    return Scaffold(
      appBar: AppBar(title: const Text('Gói tập')),
      body: AnimatedBuilder(
        animation: Listenable.merge([repo.changes, appState]),
        builder: (context, _) {
          final memberId = Repositories.currentMemberId;
          final member = repo.member(memberId);
          final active = repo.activeMembership(memberId);
          final scheduled = repo.scheduledMembership(memberId);
          final pending = repo.pendingRenewal(memberId);
          final today = repo.serverToday;
          final latest = repo.memberships(memberId);

          return ListView(padding: const EdgeInsets.all(20), children: [
            if (member != null) _StatusHeader(member: member),
            const SizedBox(height: 8),
            if (active != null)
              _MembershipCard(membership: active, today: today, title: 'Gói hiện tại')
            else
              Panel(
                  child: Text(
                      latest.isEmpty
                          ? 'Bạn chưa có gói tập. Gửi yêu cầu để lễ tân tư vấn.'
                          : 'Gói gần nhất (${latest.first.package.name}) đã '
                              'hết hạn ngày ${latest.first.endDate == null ? '—' : dmy(latest.first.endDate!)}.',
                      style: const TextStyle(color: AppColors.dim))),
            if (scheduled != null)
              _MembershipCard(
                  membership: scheduled, today: today, title: 'Gói nối tiếp'),
            _MarksRow(memberId: memberId),
            const SizedBox(height: 8),
            if (pending != null)
              _PendingRenewalCard(request: pending)
            else if (scheduled == null)
              FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => RenewalRequestSheet(
                      memberId: memberId,
                      currentPackageTypeId: (active ?? (latest.isEmpty ? null : latest.first))
                          ?.package
                          .id),
                ),
                icon: const Icon(Icons.autorenew),
                label: Text(active == null ? 'KÍCH HOẠT / GIA HẠN GÓI' : 'GỬI YÊU CẦU GIA HẠN'),
              ),
            const SizedBox(height: 24),
            Row(children: [
              const Expanded(
                  child: Text('Lịch tập',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
              SegmentedButton<_Range>(
                segments: const [
                  ButtonSegment(value: _Range.week, label: Text('Tuần')),
                  ButtonSegment(value: _Range.month, label: Text('Tháng')),
                ],
                selected: {range},
                onSelectionChanged: (value) =>
                    setState(() => range = value.first),
              ),
            ]),
            const SizedBox(height: 10),
            ..._schedule(member?.fullName, today),
          ]);
        },
      ),
    );
  }

  List<Widget> _schedule(String? memberName, DateTime today) {
    final start = range == _Range.week
        ? today.subtract(Duration(days: today.weekday - 1))
        : DateTime(today.year, today.month);
    final end = range == _Range.week
        ? start.add(const Duration(days: 7))
        : DateTime(today.year, today.month + 1);
    final items = <(DateTime, ScheduledClass)>[];
    for (final item in appState.scheduledClasses) {
      final date = _parseDmy(item.date);
      if (date == null || date.isBefore(start) || !date.isBefore(end)) continue;
      if (memberName != null && !item.members.contains(memberName)) continue;
      items.add((date, item));
    }
    items.sort((a, b) => a.$1.compareTo(b.$1));
    if (items.isEmpty) {
      return [
        Panel(
            child: Text(
                'Không có buổi tập nào trong ${range == _Range.week ? 'tuần' : 'tháng'} này.',
                style: const TextStyle(color: AppColors.dim)))
      ];
    }
    return [
      for (final (date, item) in items)
        Panel(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(date.isBefore(today) ? '✓' : '⏱',
                style: const TextStyle(fontSize: 20)),
            title: Text(item.lessonName),
            subtitle: Text('${dmy(date)} · ${item.time} · ${item.instructor}'),
            trailing: Text(date.isBefore(today) ? 'ĐÃ QUA' : 'SẮP TỚI',
                style: const TextStyle(color: AppColors.teal, fontSize: 10)),
          ),
        ),
    ];
  }

  static DateTime? _parseDmy(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }
}

class _StatusHeader extends StatelessWidget {
  final Member member;

  const _StatusHeader({required this.member});

  @override
  Widget build(BuildContext context) {
    final color = switch (member.status) {
      MemberStatus.active => AppColors.teal,
      MemberStatus.frozen => AppColors.amber,
      MemberStatus.inactive => AppColors.accent,
    };
    final detail = switch (member.status) {
      MemberStatus.active => 'Tài khoản đang hoạt động.',
      MemberStatus.frozen =>
        'Gói đã hết hạn. Marks được đóng băng và giữ nguyên số dư.',
      MemberStatus.inactive =>
        'Không hoạt động từ ${member.inactiveAt == null ? '—' : dmy(member.inactiveAt!)}. Chế độ chỉ xem.',
    };
    return Row(children: [
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(member.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('${member.memberCode} · $detail',
            style: const TextStyle(color: AppColors.dim)),
      ])),
      StatusPill(label: member.status.label, color: color),
    ]);
  }
}

class _MembershipCard extends StatelessWidget {
  final Membership membership;
  final DateTime today;
  final String title;

  const _MembershipCard(
      {required this.membership, required this.today, required this.title});

  @override
  Widget build(BuildContext context) {
    final days = membership.daysLeft(today);
    final total = membership.totalSessions;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(title.toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.faint, letterSpacing: 1.2, fontSize: 11))),
          StatusPill(
              label: membership.status.label,
              color: membership.status == MembershipStatus.active
                  ? AppColors.teal
                  : AppColors.amber),
        ]),
        const SizedBox(height: 6),
        Text(membership.package.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _row('Bắt đầu', dmy(membership.startDate)),
        _row(
            'Kết thúc',
            membership.endDate == null
                ? 'Không thời hạn'
                : '${dmy(membership.endDate!)}'
                    '${membership.status == MembershipStatus.active && days != null ? ' · còn $days ngày' : ''}'),
        _row(
            'Số buổi',
            total == null
                ? 'Không giới hạn'
                : '${membership.usedSessions}/$total đã dùng · còn ${membership.remainingSessions}'),
        _row('Chi nhánh', membership.branchName),
        if (total != null) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: (membership.usedSessions / total).clamp(0.0, 1.0),
              color: AppColors.accent,
              backgroundColor: AppColors.ink2),
        ],
      ]),
    );
  }

  static Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(
              width: 90,
              child: Text(label, style: const TextStyle(color: AppColors.faint))),
          Expanded(child: Text(value)),
        ]),
      );
}

class _MarksRow extends StatelessWidget {
  final String memberId;

  const _MarksRow({required this.memberId});

  @override
  Widget build(BuildContext context) {
    final repo = Repositories.membership;
    final frozen = repo.member(memberId)?.marksStatus == MarksStatus.frozen;
    return Panel(
      child: Row(children: [
        Text(frozen ? '🧊' : '💠', style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(frozen
                ? '${repo.marksBalance(memberId)} Marks đang đóng băng'
                : '${repo.availableMarks(memberId)} Marks khả dụng')),
        Text('${repo.dpBalance(memberId)} DP',
            style: const TextStyle(color: AppColors.teal)),
      ]),
    );
  }
}

class _PendingRenewalCard extends StatelessWidget {
  final RenewalRequest request;

  const _PendingRenewalCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final package = Repositories.membership
        .packageTypes()
        .firstWhere((p) => p.id == request.desiredPackageTypeId);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Expanded(
              child: Text('YÊU CẦU GIA HẠN',
                  style: TextStyle(
                      color: AppColors.faint, letterSpacing: 1.2, fontSize: 11))),
          StatusPill(label: 'CHỜ XỬ LÝ', color: AppColors.amber),
        ]),
        const SizedBox(height: 6),
        Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
            'Liên hệ qua ${request.contactChannel.label} · gửi lúc ${dmy(request.createdAt)}'
            '${request.contactAttempts > 0 ? ' · lễ tân đã liên hệ ${request.contactAttempts} lần' : ''}',
            style: const TextStyle(color: AppColors.dim)),
        if (request.note != null)
          Text('“${request.note}”', style: const TextStyle(color: AppColors.dim)),
        const SizedBox(height: 6),
        const Text('Lễ tân sẽ tư vấn và thu phí tại quầy.',
            style: TextStyle(color: AppColors.faint, fontSize: 12)),
      ]),
    );
  }
}
