import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/repositories.dart';
import '../../core/clock.dart';
import '../../core/messages.dart';
import '../../data/mock/mock_db.dart';
import '../../data/repositories/lifecycle_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/busy_button.dart';
import '../../widgets/shared_widgets.dart';

/// Demo triggers for the backend jobs of UC15–UC17 (mock backend only).
class LifecycleDemoScreen extends StatefulWidget {
  const LifecycleDemoScreen({super.key});

  @override
  State<LifecycleDemoScreen> createState() => _LifecycleDemoScreenState();
}

class _LifecycleDemoScreenState extends State<LifecycleDemoScreen> {
  final List<String> output = [];

  MockDb get db => Repositories.mockDb;
  static const memberId = MockDb.demoMemberId;

  void log(String title, List<String> lines) =>
      setState(() => output.insertAll(0, ['▸ $title', ...lines.map((l) => '   $l')]));

  void advance(int days) {
    db.clock.advance(Duration(days: days));
    db.commit();
    log('Tua đồng hồ +$days ngày → ${dmy(db.today)}', const []);
  }

  String describe(ComebackOutcome outcome) => switch (outcome.decision) {
        ComebackDecision.granted =>
          'GRANTED: +${outcome.cycle!.dpGranted} DP sau ${outcome.gapDays} ngày vắng.',
        ComebackDecision.capped =>
          'CAPPED: chỉ +${outcome.cycle!.dpGranted} DP (chạm trần tháng).',
        ComebackDecision.gapTooShort =>
          'Không thưởng: vắng ${outcome.gapDays} ngày (< ${db.config.comebackMinGapDays}).',
        ComebackDecision.alreadyGranted =>
          'Bỏ qua: ${Msgs.duplicateTransaction.display}',
        ComebackDecision.noPreviousSession =>
          'Không thưởng: chưa có buổi hoàn thành trước đó.',
      };

  @override
  Widget build(BuildContext context) {
    final lifecycle = Repositories.lifecycle;
    final repo = Repositories.membership;
    return Scaffold(
      appBar: AppBar(title: const Text('Lifecycle demo')),
      body: AnimatedBuilder(
        animation: Listenable.merge([db, appState]),
        builder: (context, _) {
          final member = repo.member(memberId)!;
          final active = repo.activeMembership(memberId);
          return ListView(padding: const EdgeInsets.all(20), children: [
            const Text(
                'Mô phỏng các job chạy trên backend. Chỉ có ở bản mock.',
                style: TextStyle(color: AppColors.dim)),
            const SizedBox(height: 12),
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${member.fullName} · ${member.status.name.toUpperCase()} · '
                    'Marks ${member.marksStatus.name.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'Gói: ${active == null ? 'không có' : '${active.package.name} · '
                        '${active.endDate == null ? '' : 'hết hạn ${dmy(active.endDate!)} · '}'
                        '${active.remainingSessions == null ? 'không giới hạn buổi' : 'còn ${active.remainingSessions} buổi'}'}',
                    style: const TextStyle(color: AppColors.dim)),
                Text(
                    'DP ${repo.dpBalance(memberId)} · Marks ${repo.marksBalance(memberId)} '
                    '(khả dụng ${repo.availableMarks(memberId)})',
                    style: const TextStyle(color: AppColors.dim)),
                Text(
                    'Hoạt động gần nhất: ${member.lastActivityAt == null ? '—' : dmy(member.lastActivityAt!)} · '
                    'freeze log ${lifecycle.freezeLogs(memberId).length} · '
                    'comeback ${lifecycle.comebackCycles(memberId).length}',
                    style: const TextStyle(color: AppColors.dim)),
              ]),
            ),
            _Section('Đồng hồ hệ thống · ${dmy(db.today)}', [
              for (final days in [1, 7, 11, 30, 335, 365])
                OutlinedButton(
                    onPressed: () => advance(days), child: Text('+$days ngày')),
            ]),
            _Section('UC15 · Gói hết hạn → đóng băng Marks', [
              OutlinedButton(
                onPressed: active?.totalSessions == null
                    ? null
                    : () {
                        active!.usedSessions = active.totalSessions!;
                        db.commit();
                        log('Dùng hết số buổi của ${active.package.name}', const []);
                      },
                child: const Text('Dùng hết số buổi'),
              ),
              BusyButton(
                label: 'Chạy job hết hạn',
                onPressed: () async {
                  final report = await lifecycle.runExpiryJob();
                  log(report.job, report.lines);
                },
              ),
            ]),
            _Section('UC16 · 12 tháng không hoạt động', [
              BusyButton(
                label: 'Chạy job inactive',
                onPressed: () async {
                  final report = await lifecycle.runInactiveJob();
                  log(report.job, report.lines);
                },
              ),
            ]),
            _Section('UC17 · Quay lại sau ≥ ${db.config.comebackMinGapDays} ngày', [
              OutlinedButton(
                onPressed: () {
                  Repositories.mockLifecycle
                      .setLastCompletedSessionDaysAgo(memberId, 15);
                  log('Buổi hoàn thành gần nhất: 15 ngày trước', const []);
                },
                child: const Text('Vắng 15 ngày'),
              ),
              BusyButton(
                label: 'SESSION_COMPLETED',
                onPressed: () async {
                  final outcome = await lifecycle.onSessionCompleted(memberId);
                  log('Sự kiện SESSION_COMPLETED', [describe(outcome)]);
                },
              ),
              BusyButton(
                outlined: true,
                label: 'Gửi lại sự kiện',
                onPressed: () async {
                  final outcome =
                      await lifecycle.replayLastSessionCompleted(memberId);
                  log('Replay SESSION_COMPLETED (idempotency)', [describe(outcome)]);
                },
              ),
            ]),
            if (output.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Kết quả', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Panel(
                child: Text(output.join('\n'),
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12, height: 1.5)),
              ),
            ],
            const SizedBox(height: 8),
            const Text('Audit log', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            for (final entry in lifecycle.auditLogs().take(10))
              Text(
                  '${dmy(entry.createdAt)} · ${entry.actor ?? 'SYSTEM'} · ${entry.action} · '
                  '${entry.entityId}${entry.before == null ? '' : ' · ${entry.before} → ${entry.after}'}',
                  style: const TextStyle(color: AppColors.dim, fontSize: 12)),
          ]);
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const _Section(this.title, this.actions);

  @override
  Widget build(BuildContext context) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ]),
      );
}
