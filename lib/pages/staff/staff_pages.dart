import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../shared/member_page.dart';

class StaffShell extends StatefulWidget {
  final ValueChanged<BuildContext> onSwitchRole;

  const StaffShell({super.key, required this.onSwitchRole});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Staff Operations',
      'Coach Session Review',
      'Members',
      'DP Ledger'
    ];
    final screens = <Widget>[
      const StaffDashboardScreen(),
      const CoachSessionReviewScreen(),
      const MembersScreen(),
      const StaffLedgerScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[tab]),
        actions: [
          IconButton(
            tooltip: 'Đổi role demo',
            onPressed: () => widget.onSwitchRole(context),
            icon: const Icon(Icons.swap_horiz),
          )
        ],
      ),
      body: screens[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) => setState(() => tab = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.fact_check_outlined), label: 'Sessions'),
          NavigationDestination(
              icon: Icon(Icons.group_outlined), label: 'Members'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Ledger'),
        ],
      ),
    );
  }
}

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) =>
          ListView(padding: const EdgeInsets.all(20), children: [
        const Text('STAFF / COACH',
            style: TextStyle(color: AppColors.faint, letterSpacing: 1.2)),
        const Text('Vận hành buổi tập',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: StatBox(
                  value: appState.todayCheckedIn ? '1' : '0',
                  label: 'Đã check-in',
                  icon: '📷',
                  color: AppColors.teal)),
          const SizedBox(width: 12),
          Expanded(
              child: StatBox(
                  value: appState.todaySession.attendanceConfirmed ? '0' : '1',
                  label: 'Chờ xác nhận',
                  icon: '⏱',
                  color: AppColors.amber)),
        ]),
        const SizedBox(height: 16),
        Panel(
            child: ListTile(
                leading: const Icon(Icons.fact_check_outlined,
                    color: AppColors.accent),
                title: const Text('Coach Session Review'),
                subtitle: const Text(
                    'Xác nhận attendance và nhập completion cho từng học viên.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CoachSessionReviewPage())))),
      ]),
    );
  }
}

class CoachSessionReviewPage extends StatelessWidget {
  const CoachSessionReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Session Review')),
      body: const CoachSessionReviewScreen(),
    );
  }
}

class CoachSessionReviewScreen extends StatefulWidget {
  const CoachSessionReviewScreen({super.key});

  @override
  State<CoachSessionReviewScreen> createState() =>
      _CoachSessionReviewScreenState();
}

class _CoachSessionReviewScreenState extends State<CoachSessionReviewScreen> {
  double completion = 85;

  void confirmAttendance() {
    appState.confirmAttendance();
    showMessage(context, 'Coach đã xác nhận Attendance cho Minh Nguyễn.');
  }

  void submitCompletion() {
    appState.addSessionResult(completion.round());
    showMessage(
        context, 'System đã tính DP và tạo PointTransaction cho buổi tập.');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final session = appState.todaySession;
        final canConfirmAttendance =
            session.checkedIn && !session.attendanceConfirmed;
        final canSubmitCompletion =
            session.attendanceConfirmed && session.completionPercent == null;
        final estimatedDp = completion.round() >= appState.completionThreshold
            ? appState.sessionDpWeight
            : 0;
        return ListView(padding: const EdgeInsets.all(20), children: [
          const Text('COACH CONSOLE',
              style: TextStyle(color: AppColors.faint, letterSpacing: 1.2)),
          const Text('Xác nhận buổi tập',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Coach xử lý sau khi học viên check-in. DP chỉ phát sinh sau khi nhập % hoàn thành.',
              style: TextStyle(color: AppColors.dim)),
          const SizedBox(height: 16),
          Panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Session hôm nay',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${session.date} · ${session.type}\n${session.coach}',
                    style: const TextStyle(color: AppColors.dim)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  StatusPill(
                    label: session.checkedIn ? 'CHECKED-IN' : 'NO CHECK-IN',
                    color: session.checkedIn ? AppColors.teal : AppColors.faint,
                  ),
                  StatusPill(
                    label: session.attendanceConfirmed
                        ? 'ATTENDANCE CONFIRMED'
                        : 'ATTENDANCE PENDING',
                    color: session.attendanceConfirmed
                        ? AppColors.teal
                        : AppColors.amber,
                  ),
                  StatusPill(label: session.status, color: AppColors.accent),
                ]),
              ])),
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          Panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Danh sách học viên chờ Coach xác nhận',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CoachStudentReviewCard(
                  session: session,
                  completion: completion,
                  estimatedDp: estimatedDp,
                  canConfirmAttendance: canConfirmAttendance,
                  canSubmitCompletion: canSubmitCompletion,
                  onMockCheckin: appState.checkInToday,
                  onConfirmAttendance: confirmAttendance,
                  onCompletionChanged: (value) =>
                      setState(() => completion = value),
                  onSubmitCompletion: submitCompletion,
                  completionThreshold: appState.completionThreshold,
                ),
                const CoachQueueItem(
                  initials: 'A',
                  name: 'An Trần',
                  meta: '16:31 · Gói B · 10 buổi',
                  status: 'WAITING',
                  color: AppColors.amber,
                ),
                const CoachQueueItem(
                  initials: 'L',
                  name: 'Linh Phạm',
                  meta: '16:35 · Gói A · 3 buổi',
                  status: 'CONFIRMED',
                  color: AppColors.teal,
                ),
                const CoachQueueItem(
                  initials: 'K',
                  name: 'Khoa Lê',
                  meta: 'Chưa check-in',
                  status: 'NO-SHOW',
                  color: AppColors.faint,
                ),
              ])),
        ]);
      },
    );
  }
}

class StaffLedgerScreen extends StatelessWidget {
  const StaffLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) =>
          ListView(padding: const EdgeInsets.all(20), children: [
        const Text('DP Ledger',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const Text('Staff chỉ xem transaction được tạo bởi System/Admin.',
            style: TextStyle(color: AppColors.dim)),
        const SizedBox(height: 14),
        for (final entry in appState.pointTransactions)
          Panel(
              child: ListTile(
                  title: Text(entry.source),
                  subtitle:
                      Text('${entry.id} · ${entry.status} · ${entry.actor}'),
                  trailing: Text(
                      '${entry.amount >= 0 ? '+' : ''}${entry.amount} DP'))),
      ]),
    );
  }
}
