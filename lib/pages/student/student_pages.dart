import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class HomeShell extends StatefulWidget {
  final ValueChanged<BuildContext> onSwitchRole;

  const HomeShell({super.key, required this.onSwitchRole});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;

  void changeTab(int index) => setState(() => tab = index);

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(onTab: changeTab),
      const CheckinScreen(),
      const FighterRecordScreen(),
      const ActivityScreen(),
      ProfileScreen(onSwitchRole: widget.onSwitchRole),
    ];
    const titles = [
      'Home',
      'Check-in',
      'Fighter Record',
      'Activity',
      'Profile',
    ];
    return Scaffold(
      appBar: tab == 0
          ? null
          : AppBar(
              title: Text(titles[tab]),
            ),
      body: screens[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: changeTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Text('📷'), label: 'Check-in'),
          NavigationDestination(icon: Text('🏅'), label: 'Hạng'),
          NavigationDestination(
              icon: Icon(Icons.timeline_outlined), label: 'Activity'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onTab;
  const DashboardScreen({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          const Text('HỌC VIÊN · MINH',
              style: TextStyle(
                  color: AppColors.faint, fontSize: 11, letterSpacing: 1.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng quan',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
              IconButton(onPressed: null, icon: Icon(Icons.notifications_none)),
            ],
          ),
          const SizedBox(height: 18),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DISCIPLINE POINTS',
                    style: TextStyle(
                        color: AppColors.faint,
                        fontSize: 11,
                        letterSpacing: 1.4)),
                const SizedBox(height: 4),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${appState.dpBalance} DP',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal)),
                      const Text('THE UNKNOWN',
                          style: TextStyle(
                              color: AppColors.amber,
                              fontWeight: FontWeight.bold))
                    ]),
                const SizedBox(height: 12),
                const LinearProgressIndicator(value: .7, color: AppColors.teal),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${appState.dpBalance} DP hiện tại'),
                      const Text('500 DP · hạng kế tiếp')
                    ]),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        onPressed: () => onTab(1),
                        child: const Text('📷  CHECK-IN BUỔI TẬP'))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: StatBox(
                    value: '${appState.dpBalance}',
                    label: 'Điểm tích lũy',
                    icon: '⭐',
                    color: AppColors.teal)),
            const SizedBox(width: 12),
            const Expanded(
                child: StatBox(
                    value: '4',
                    label: 'Chuỗi buổi tập',
                    icon: '🔥',
                    color: AppColors.text))
          ]),
          const SizedBox(height: 24),
          Panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Membership Card',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    'Gói A · ACTIVE · hết hạn 20/09/2026\n${appState.remainingSessions} buổi còn lại · HVP Boxing Quận 7',
                    style: const TextStyle(color: AppColors.dim, height: 1.5)),
              ])),
          Panel(
              child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScheduleScreen())),
                  leading: const Icon(Icons.calendar_month_outlined,
                      color: AppColors.accent),
                  title: const Text('Buổi tập tiếp theo'),
                  subtitle: const Text(
                      'Thứ Tư, 24/09 · 16:30 - 17:30\nBoxing Fundamentals · Coach Tuấn'),
                  trailing: const Icon(Icons.chevron_right))),
          const SizedBox(height: 24),
          const Text('Trạng thái tuần này',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Panel(
              child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text('🔥', style: TextStyle(fontSize: 24)),
                  title: Text('Streak 4 tuần'),
                  subtitle: Text('Đã hoàn thành 2/3 buổi tuần này'),
                  trailing: Text('CÒN 1 BUỔI',
                      style: TextStyle(color: AppColors.amber, fontSize: 10)))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => onTab(2), child: const Text('XEM HẠNG'))),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen())),
                    child: const Text('THÔNG BÁO')))
          ]),
          Row(children: [
            Expanded(
                child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyDpScreen())),
                    child: const Text('MY DP'))),
            Expanded(
                child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TrainingHistoryScreen())),
                    child: const Text('MY TRAINING'))),
          ]),
          Row(children: [
            Expanded(
                child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StreakScreen())),
                    child: const Text('XEM STREAK'))),
            Expanded(
                child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChallengesScreen())),
                    child: const Text('CHALLENGES')))
          ]),
        ],
      ),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const sessions = [
      'Thứ Hai · 18/08',
      'Thứ Tư · 20/08',
      'Thứ Sáu · 22/08 · Hôm nay',
      'Thứ Hai · 25/08'
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch tập của tôi')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Panel(
            child: Text('⏳  Gói GÓI A còn 6 buổi, hết hạn 20/09/2026',
                style: TextStyle(color: AppColors.amber))),
        const SizedBox(height: 20),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('T2\n18'),
          Text('T3\n19'),
          Text('T4\n20'),
          Text('T5\n21'),
          Text('T6\n22'),
          Text('T7\n23'),
          Text('CN\n24')
        ]),
        const SizedBox(height: 20),
        const Text('Buổi tập trong tuần',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        for (var i = 0; i < sessions.length; i++)
          Panel(
              child: ListTile(
                  leading: Text(i < 2
                      ? '✓'
                      : i == 2
                          ? '⏱'
                          : '—'),
                  title: Text(sessions[i]),
                  subtitle: const Text('16:30 – 17:30 · HLV Tuấn'),
                  trailing: Text(
                      i < 2
                          ? 'ĐÃ TẬP'
                          : i == 2
                              ? 'CHƯA TẬP'
                              : 'SẮP TỚI',
                      style: const TextStyle(
                          color: AppColors.teal, fontSize: 10)))),
      ]),
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  final ValueChanged<int> onPoints;
  const WorkoutScreen({super.key, required this.onPoints});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final completed = <int>{};
  int? selectedChallenge;
  bool finished = false;

  int get percent => (completed.length / exercises.length * 100).round();

  int get points {
    var result = completed.length * 5;
    if (percent >= 50) result += 10;
    if (percent >= 80) result += 30;
    if (percent >= 100) result += 50;
    if (selectedChallenge != null) result += challenges[selectedChallenge!].pts;
    return result;
  }

  void toggleExercise(int index) {
    if (finished) return;
    setState(() {
      completed.contains(index)
          ? completed.remove(index)
          : completed.add(index);
    });
  }

  void finish() {
    if (completed.isEmpty || finished) return;
    setState(() => finished = true);
    widget.onPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Buổi tập · 16:30 – 17:30 · HLV Tuấn',
            style: TextStyle(color: AppColors.faint, fontSize: 11)),
        const Text('Bài tập hôm nay',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Panel(
            child: Row(children: [
          SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                  value: percent / 100, color: AppColors.teal, strokeWidth: 8)),
          const SizedBox(width: 18),
          Text(
              '$percent%\nĐã hoàn thành ${completed.length}/8 bài tập\n⭐ $points điểm',
              style: const TextStyle(height: 1.6))
        ])),
        const SizedBox(height: 16),
        const Text('Danh sách bài tập',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        for (var i = 0; i < exercises.length; i++)
          Panel(
              child: ListTile(
                  onTap: () => toggleExercise(i),
                  leading: Icon(
                      completed.contains(i)
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: completed.contains(i)
                          ? AppColors.teal
                          : AppColors.faint),
                  title: Text(exercises[i].name),
                  subtitle: Text(exercises[i].sub),
                  trailing: Text(exercises[i].icon))),
        const SizedBox(height: 10),
        const Text('Chọn thử thách hôm nay',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        RadioGroup<int>(
            groupValue: selectedChallenge,
            onChanged: (value) {
              if (finished) return;
              setState(() => selectedChallenge = value);
            },
            child: Column(children: [
              for (var i = 0; i < challenges.length; i++)
                Panel(
                    child: RadioListTile<int>(
                        value: i,
                        title:
                            Text('${challenges[i].icon} ${challenges[i].name}'),
                        subtitle: Text(challenges[i].desc),
                        secondary: Text('+${challenges[i].pts}đ'))),
            ])),
        const SizedBox(height: 14),
        Text('Tổng điểm dự kiến: $points điểm',
            style: const TextStyle(color: AppColors.teal)),
        FilledButton(
            onPressed: completed.isEmpty || finished ? null : finish,
            child: Text(finished ? 'ĐÃ HOÀN TẤT' : 'HOÀN TẤT BUỔI TẬP')),
        if (finished)
          const Panel(
              child: Column(children: [
            Text('🏆', style: TextStyle(fontSize: 32)),
            Text('Đã hoàn tất buổi tập!',
                style: TextStyle(
                    color: AppColors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Điểm đã được cộng vào Trang chủ.')
          ]))
      ],
    );
  }
}

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int seconds = 30;
  bool loading = false;
  bool success = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds = seconds == 1 ? 30 : seconds - 1);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> verify() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    appState.checkInToday();
    setState(() {
      loading = false;
      success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Buổi tập · 16:30 – 17:30',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.faint)),
      const Text('Quét mã tại quầy',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text(
          'Đưa camera hướng vào mã QR hiển thị tại quầy hoặc màn hình phòng tập để check-in.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.dim)),
      const SizedBox(height: 24),
      Center(
          child: CustomPaint(size: const Size(250, 250), painter: QrPainter())),
      const SizedBox(height: 18),
      Text('●  Mã tự làm mới sau $seconds s',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.faint)),
      const SizedBox(height: 22),
      FilledButton(
          onPressed:
              loading || success || appState.todayCheckedIn ? null : verify,
          child: Text(loading
              ? 'ĐANG XÁC THỰC...'
              : success || appState.todayCheckedIn
                  ? 'ĐÃ CHECK-IN'
                  : 'XÁC NHẬN CHECK-IN')),
      if (success)
        const Panel(
            child: Column(children: [
          Text('✅', style: TextStyle(fontSize: 30)),
          Text('Check-in thành công',
              style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text('Đã ghi nhận hiện diện. DP chờ Coach xác nhận buổi tập.')
        ]))
    ]);
  }
}

class FighterRecordScreen extends StatelessWidget {
  const FighterRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) =>
          ListView(padding: const EdgeInsets.all(20), children: [
        const Text('UC7 · UC8',
            style: TextStyle(color: AppColors.faint, letterSpacing: 1.2)),
        const Text('Fighter Record',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Panel(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('HẠNG HIỆN TẠI',
              style: TextStyle(color: AppColors.faint, fontSize: 11)),
          const SizedBox(height: 6),
          const Text('THE UNKNOWN',
              style: TextStyle(
                  fontSize: 24,
                  color: AppColors.amber,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Text('DP BALANCE  ·  ${appState.dpBalance} / 500'),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: (appState.dpBalance / 500).clamp(0.0, 1.0).toDouble(),
              color: AppColors.amber),
          const SizedBox(height: 18),
          Text(
              appState.dpBalance >= 500
                  ? 'TRẠNG THÁI: APPROVAL REQUIRED'
                  : 'TRẠNG THÁI: IN PROGRESS',
              style: const TextStyle(
                  color: AppColors.teal, fontWeight: FontWeight.bold))
        ])),
        const SizedBox(height: 16),
        const Text('Điều kiện còn thiếu',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const Panel(
            child: Column(children: [
          ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.teal),
              title: Text('DP balance'),
              subtitle: Text('Đã đạt ngưỡng mục tiêu')),
          ListTile(
              leading: Icon(Icons.timelapse, color: AppColors.amber),
              title: Text('time-gate'),
              subtitle: Text('Cần duy trì hạng thêm 12 ngày')),
          ListTile(
              leading: Icon(Icons.school_outlined, color: AppColors.amber),
              title: Text('course-gate'),
              subtitle: Text('Hoàn thành khóa học bắt buộc'))
        ])),
        const SizedBox(height: 16),
        FilledButton(onPressed: null, child: const Text('YÊU CẦU RANK TRIAL')),
        const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('MSG27 · Bạn chưa đủ điều kiện để yêu cầu Rank Trial.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.faint, fontSize: 12))),
      ]),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Activity',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Panel(
          child: ListTile(
              leading: const Icon(Icons.history_edu_outlined),
              title: const Text('My Training'),
              subtitle: const Text('Check-in, attendance, completion %, DP'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TrainingHistoryScreen())))),
      Panel(
          child: ListTile(
              leading: const Icon(Icons.stars_outlined),
              title: const Text('My DP'),
              subtitle: const Text('Transaction ledger'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyDpScreen())))),
      Panel(
          child: ListTile(
              leading: const Icon(Icons.redeem_outlined),
              title: const Text('The Armory'),
              subtitle: const Text('Đổi Marks lấy phần thưởng'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ArmoryScreen())))),
    ]);
  }
}

class ProfileScreen extends StatelessWidget {
  final ValueChanged<BuildContext> onSwitchRole;

  const ProfileScreen({super.key, required this.onSwitchRole});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Panel(
          child: Column(children: [
        CircleAvatar(radius: 34, child: Text('M')),
        SizedBox(height: 12),
        Text('Minh Nguyễn',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('student@hvp.demo', style: TextStyle(color: AppColors.dim)),
      ])),
      const SizedBox(height: 12),
      const Panel(
          child: ListTile(
              leading: Icon(Icons.card_membership_outlined),
              title: Text('Gói A'),
              subtitle: Text('ACTIVE · HVP Boxing Quận 7'))),
      OutlinedButton(
        onPressed: () => onSwitchRole(context),
        child: const Text('ĐỔI ROLE DEMO'),
      )
    ]);
  }
}

class MyDpScreen extends StatelessWidget {
  const MyDpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My DP')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) =>
            ListView(padding: const EdgeInsets.all(20), children: [
          Panel(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                const Text('Current DP Balance'),
                Text('${appState.dpBalance}',
                    style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 30,
                        fontWeight: FontWeight.bold))
              ])),
          const SizedBox(height: 12),
          const Text('Transaction History',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          for (final entry in appState.pointTransactions)
            Panel(
                child: ListTile(
                    title: Text(entry.source),
                    subtitle:
                        Text('${entry.id} · ${entry.status} · ${entry.actor}'),
                    trailing: Text(
                        '${entry.amount >= 0 ? '+' : ''}${entry.amount} DP',
                        style: const TextStyle(color: AppColors.teal))))
        ]),
      ),
    );
  }
}

class TrainingHistoryScreen extends StatelessWidget {
  const TrainingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Training')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) =>
            ListView(padding: const EdgeInsets.all(20), children: [
          for (final session in appState.sessions)
            Panel(
                child: ListTile(
                    title: Text('${session.date} · ${session.type}'),
                    subtitle: Text(
                        '${session.coach}\nCheck-in: ${session.checkedIn ? 'Yes' : 'No'} · Attendance: ${session.attendanceConfirmed ? 'Confirmed' : 'Pending'}\nCompletion: ${session.completionPercent?.toString() ?? '-'}% · DP earned: ${session.dpEarned}'),
                    trailing: Text(session.status,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: AppColors.amber, fontSize: 11))))
        ]),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Thông báo')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          for (final notice in notices)
            Panel(
                child: ListTile(
                    leading:
                        Text(notice.icon, style: const TextStyle(fontSize: 24)),
                    title: Text(notice.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${notice.body}\n${notice.time}'))),
        ]));
  }
}

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Streak')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Panel(
              child: Column(children: [
            Text('🔥', style: TextStyle(fontSize: 38)),
            Text('4',
                style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal)),
            Text('TUẦN LIÊN TIẾP',
                style: TextStyle(color: AppColors.faint, letterSpacing: 1.2))
          ])),
          const SizedBox(height: 16),
          const Text('7 ngày gần nhất',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const Panel(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                Text('✓\nT2', textAlign: TextAlign.center),
                Text('✓\nT3', textAlign: TextAlign.center),
                Text('✓\nT4', textAlign: TextAlign.center),
                Text('🧊\nT5', textAlign: TextAlign.center),
                Text('•\nT6', textAlign: TextAlign.center),
                Text('•\nT7', textAlign: TextAlign.center),
                Text('•\nCN', textAlign: TextAlign.center)
              ])),
          const SizedBox(height: 16),
          const Panel(
              child: ListTile(
                  leading: Text('🧊', style: TextStyle(fontSize: 24)),
                  title: Text('Streak Freeze khả dụng'),
                  subtitle: Text('Còn 1 lượt trong tháng này'))),
          const SizedBox(height: 12),
          const Text('ĐỪNG ĐỂ CHUỖI DỪNG LẠI',
              style: TextStyle(
                  color: AppColors.amber, fontWeight: FontWeight.bold)),
          const Text('Bạn cần hoàn thành thêm 1 buổi trước khi tuần kết thúc.',
              style: TextStyle(color: AppColors.dim)),
        ]));
  }
}

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Challenges')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          for (final challenge in challenges)
            Panel(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('${challenge.icon}  ${challenge.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(challenge.desc,
                      style: const TextStyle(color: AppColors.dim)),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('+${challenge.pts} DP',
                            style: const TextStyle(color: AppColors.accent)),
                        OutlinedButton(
                            onPressed: () => showMessage(context,
                                'Challenge đã chuyển sang trạng thái JOINED'),
                            child: const Text('THAM GIA'))
                      ])
                ])),
        ]));
  }
}

class ArmoryScreen extends StatelessWidget {
  const ArmoryScreen({super.key});

  void redeem(BuildContext context, String reward, int cost) {
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('Xác nhận đổi quà'),
                content: Text('Đổi $reward với $cost Marks?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('HỦY')),
                  FilledButton(
                      onPressed: () {
                        appState.redeemReward(cost);
                        Navigator.pop(dialogContext);
                        showMessage(context,
                            'MSG3 · Đơn đổi quà đã được tạo, vui lòng đến quầy nhận quà.');
                      },
                      child: const Text('ĐỔI NGAY'))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    const rewards = {
      'Găng tay HVP': 250,
      'Áo tập HVP': 180,
      'Bình nước': 120,
      'Khăn boxing': 80
    };
    return Scaffold(
      appBar: AppBar(title: const Text('The Armory')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) =>
            ListView(padding: const EdgeInsets.all(20), children: [
          const Text('THE ARMORY',
              style: TextStyle(color: AppColors.faint, letterSpacing: 1.3)),
          const Text('Đổi thưởng',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Panel(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                const Text('SỐ DƯ MARKS'),
                Text('${appState.availableMarks}',
                    style: const TextStyle(
                        fontSize: 28,
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold))
              ])),
          const SizedBox(height: 16),
          for (final entry in rewards.entries)
            Panel(
                child: ListTile(
                    leading: const Text('🎁', style: TextStyle(fontSize: 28)),
                    title: Text(entry.key),
                    subtitle: Text('${entry.value} Marks'),
                    trailing: FilledButton(
                        onPressed: entry.value <= appState.availableMarks
                            ? () => redeem(context, entry.key, entry.value)
                            : null,
                        child: const Text('ĐỔI')))),
        ]),
      ),
    );
  }
}
