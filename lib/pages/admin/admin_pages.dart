import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../shared/member_page.dart';

class AdminShell extends StatefulWidget {
  final ValueChanged<BuildContext> onSwitchRole;

  const AdminShell({super.key, required this.onSwitchRole});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const AdminDashboardScreen(),
      const MembersScreen(),
      const AdminLedgerScreen(),
      const AdminManageHubScreen(),
      const AdminConfigurationScreen(),
    ];
    const titles = [
      'Admin',
      'Members',
      'DP Transactions',
      'Quản trị',
      'Cấu hình',
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
              icon: Icon(Icons.group_outlined), label: 'Members'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'DP'),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined), label: 'Manage'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Config'),
        ],
      ),
    );
  }
}

class AdminManageHubScreen extends StatelessWidget {
  const AdminManageHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Quản trị nội dung',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Tạo, chỉnh sửa và theo dõi các dữ liệu vận hành.',
          style: TextStyle(color: AppColors.dim)),
      const SizedBox(height: 16),
      AdminManageTile(
          icon: Icons.event_available_outlined,
          title: 'Buổi học',
          detail: '${appState.scheduledClasses.length} buổi đã lên lịch',
          onTap: () => open(const ClassManagementScreen())),
      const SizedBox(height: 10),
      AdminManageTile(
          icon: Icons.menu_book_outlined,
          title: 'Bài học',
          detail: '${appState.lessons.length} bài học',
          onTap: () => open(const LessonManagementScreen())),
      const SizedBox(height: 10),
      AdminManageTile(
          icon: Icons.emoji_events_outlined,
          title: 'Challenges',
          detail: '${appState.managedChallenges.length} challenge',
          onTap: () =>
              open(const ManagementScreen(type: ManagementType.challenges))),
      const SizedBox(height: 10),
      AdminManageTile(
          icon: Icons.inventory_2_outlined,
          title: 'Thưởng / Armory',
          detail: '${appState.rewards.length} phần thưởng',
          onTap: () =>
              open(const ManagementScreen(type: ManagementType.rewards))),
      const SizedBox(height: 10),
      AdminManageTile(
          icon: Icons.military_tech_outlined,
          title: 'Rank Trials',
          detail: 'Xem eligibility và phân quyền duyệt',
          onTap: () => open(const AdminRankScreen())),
    ]);
  }
}

class AdminManageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  const AdminManageTile({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Panel(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Icon(icon, color: AppColors.accent),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(detail),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class ClassManagementScreen extends StatelessWidget {
  const ClassManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý buổi học')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ClassEditorScreen())),
        icon: const Icon(Icons.add),
        label: const Text('TẠO BUỔI HỌC'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          children: [
            const Text('Lịch buổi học',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Assign giảng viên và học viên cho từng buổi.',
                style: TextStyle(color: AppColors.dim)),
            const SizedBox(height: 16),
            for (var index = 0;
                index < appState.scheduledClasses.length;
                index++) ...[
              ScheduledClassCard(
                  scheduledClass: appState.scheduledClasses[index],
                  index: index),
              const SizedBox(height: 10),
            ]
          ],
        ),
      ),
    );
  }
}

class ScheduledClassCard extends StatelessWidget {
  final ScheduledClass scheduledClass;
  final int index;

  const ScheduledClassCard(
      {super.key, required this.scheduledClass, required this.index});

  @override
  Widget build(BuildContext context) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
                child: Text(scheduledClass.lessonName,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold))),
            IconButton(
                tooltip: 'Chỉnh sửa',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ClassEditorScreen(index: index))),
                icon: const Icon(Icons.edit_outlined)),
            IconButton(
                tooltip: 'Xóa',
                onPressed: () => appState.removeScheduledClass(index),
                icon: const Icon(Icons.delete_outline)),
          ]),
          const SizedBox(height: 8),
          Text('${scheduledClass.date} · ${scheduledClass.time}',
              style: const TextStyle(color: AppColors.teal)),
          const SizedBox(height: 4),
          Text('Giảng viên: ${scheduledClass.instructor}'),
          const SizedBox(height: 8),
          Text('${scheduledClass.members.length} học viên được assign',
              style: const TextStyle(color: AppColors.dim)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final member in scheduledClass.members)
                StatusPill(label: member, color: AppColors.amber),
            ],
          )
        ]),
      );
}

class ClassEditorScreen extends StatefulWidget {
  final int? index;

  const ClassEditorScreen({super.key, this.index});

  @override
  State<ClassEditorScreen> createState() => _ClassEditorScreenState();
}

class _ClassEditorScreenState extends State<ClassEditorScreen> {
  static const instructors = ['Coach Tuấn', 'Coach Linh', 'Coach Nam'];
  static const members = ['Minh Nguyễn', 'An Trần', 'Linh Phạm', 'Khoa Lê'];
  late final TextEditingController date;
  late final TextEditingController time;
  late String lessonName;
  late String instructor;
  late Set<String> selectedMembers;

  ScheduledClass? get scheduledClass =>
      widget.index == null ? null : appState.scheduledClasses[widget.index!];

  @override
  void initState() {
    super.initState();
    final current = scheduledClass;
    lessonName = current?.lessonName ?? appState.lessons.first.name;
    instructor = current?.instructor ?? instructors.first;
    selectedMembers = Set<String>.from(current?.members ?? const []);
    date = TextEditingController(text: current?.date ?? '');
    time = TextEditingController(text: current?.time ?? '');
  }

  @override
  void dispose() {
    date.dispose();
    time.dispose();
    super.dispose();
  }

  void save() {
    if (date.text.trim().isEmpty ||
        time.text.trim().isEmpty ||
        selectedMembers.isEmpty) {
      showMessage(context, 'Nhập ngày, giờ và chọn ít nhất một học viên.');
      return;
    }
    final value = ScheduledClass(
      id: scheduledClass?.id ??
          'CLS-${1000 + appState.scheduledClasses.length + 1}',
      lessonName: lessonName,
      date: date.text.trim(),
      time: time.text.trim(),
      instructor: instructor,
      members: selectedMembers.toList(),
    );
    if (widget.index == null) {
      appState.addScheduledClass(value);
    } else {
      appState.updateScheduledClass(widget.index!, value);
    }
    Navigator.pop(context);
  }

  Future<void> pickMembers() async {
    final searchController = TextEditingController();
    final draft = Set<String>.from(selectedMembers);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final query = searchController.text.trim().toLowerCase();
          final filtered = members
              .where((member) => member.toLowerCase().contains(query))
              .toList();
          return Material(
            color: AppColors.ink,
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .72,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(children: [
                    Row(children: [
                      const Expanded(
                          child: Text('Chọn học viên',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                      Text('${draft.length} đã chọn',
                          style: const TextStyle(color: AppColors.teal)),
                    ]),
                    const SizedBox(height: 14),
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Tìm theo tên học viên',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('Không tìm thấy học viên'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final member = filtered[index];
                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: draft.contains(member),
                                  title: Text(member),
                                  subtitle: const Text('ACTIVE MEMBER'),
                                  onChanged: (selected) => setSheetState(() {
                                    if (selected ?? false) {
                                      draft.add(member);
                                    } else {
                                      draft.remove(member);
                                    }
                                  }),
                                );
                              },
                            ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() => selectedMembers = draft);
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('XÁC NHẬN HỌC VIÊN'),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.index == null ? 'Tạo buổi học' : 'Chỉnh sửa buổi học')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        DropdownButtonFormField<String>(
          initialValue: lessonName,
          decoration: const InputDecoration(labelText: 'Bài học'),
          items: [
            for (final lesson in appState.lessons)
              DropdownMenuItem(value: lesson.name, child: Text(lesson.name)),
          ],
          onChanged: (value) => setState(() => lessonName = value!),
        ),
        const SizedBox(height: 18),
        TextField(
            controller: date,
            decoration:
                const InputDecoration(labelText: 'Ngày, ví dụ: 24/09/2026')),
        const SizedBox(height: 18),
        TextField(
            controller: time,
            decoration:
                const InputDecoration(labelText: 'Giờ, ví dụ: 16:30 - 17:30')),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: instructor,
          decoration: const InputDecoration(labelText: 'Giảng viên'),
          items: [
            for (final value in instructors)
              DropdownMenuItem(value: value, child: Text(value)),
          ],
          onChanged: (value) => setState(() => instructor = value!),
        ),
        const SizedBox(height: 22),
        const Text('Assign học viên',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('Chọn một hoặc nhiều học viên cho buổi này.',
            style: TextStyle(color: AppColors.faint, fontSize: 12)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: pickMembers,
            icon: const Icon(Icons.group_add_outlined),
            label: Text(selectedMembers.isEmpty
                ? 'CHỌN HỌC VIÊN'
                : 'ĐÃ CHỌN ${selectedMembers.length} HỌC VIÊN'),
          ),
        ),
        if (selectedMembers.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final member in selectedMembers)
                StatusPill(label: member, color: AppColors.amber),
            ],
          ),
        ],
        const SizedBox(height: 28),
        FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('LƯU BUỔI HỌC')),
      ]),
    );
  }
}

class LessonManagementScreen extends StatelessWidget {
  const LessonManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài học')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LessonEditorScreen())),
        icon: const Icon(Icons.add),
        label: const Text('TẠO BÀI HỌC'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          children: [
            const Text('Quản lý bài học',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Tên, mô tả, thời lượng và tối đa 3 bài học nhỏ.',
                style: TextStyle(color: AppColors.dim)),
            const SizedBox(height: 16),
            for (var index = 0; index < appState.lessons.length; index++) ...[
              LessonListCard(lesson: appState.lessons[index], index: index),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class LessonListCard extends StatelessWidget {
  final Lesson lesson;
  final int index;

  const LessonListCard({super.key, required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.menu_book_outlined, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
                child: Text(lesson.name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold))),
            IconButton(
                tooltip: 'Chỉnh sửa',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LessonEditorScreen(index: index))),
                icon: const Icon(Icons.edit_outlined)),
            IconButton(
                tooltip: 'Xóa',
                onPressed: () => appState.removeLesson(index),
                icon: const Icon(Icons.delete_outline)),
          ]),
          const SizedBox(height: 8),
          Text(lesson.description,
              style: const TextStyle(color: AppColors.dim)),
          const SizedBox(height: 8),
          Text('Thời gian: ${lesson.duration}',
              style: const TextStyle(color: AppColors.teal)),
          if (lesson.subLessons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final subLesson in lesson.subLessons)
                  StatusPill(label: subLesson, color: AppColors.amber),
              ],
            ),
          ]
        ]),
      );
}

class LessonEditorScreen extends StatefulWidget {
  final int? index;

  const LessonEditorScreen({super.key, this.index});

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  late final TextEditingController name;
  late final TextEditingController description;
  late final TextEditingController duration;
  late final List<TextEditingController> subLessons;

  Lesson? get lesson =>
      widget.index == null ? null : appState.lessons[widget.index!];

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: lesson?.name ?? '');
    description = TextEditingController(text: lesson?.description ?? '');
    duration = TextEditingController(text: lesson?.duration ?? '');
    final existing = lesson?.subLessons ?? [];
    subLessons = List.generate(
        existing.isEmpty ? 1 : existing.length,
        (index) => TextEditingController(
            text: index < existing.length ? existing[index] : ''));
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    duration.dispose();
    for (final controller in subLessons) {
      controller.dispose();
    }
    super.dispose();
  }

  void save() {
    if (name.text.trim().isEmpty ||
        description.text.trim().isEmpty ||
        duration.text.trim().isEmpty) {
      showMessage(context, 'Vui lòng nhập tên, mô tả và thời gian.');
      return;
    }
    final value = Lesson(
      name: name.text.trim(),
      description: description.text.trim(),
      duration: duration.text.trim(),
      subLessons: subLessons
          .map((controller) => controller.text.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );
    if (widget.index == null) {
      appState.addLesson(value);
    } else {
      appState.updateLesson(widget.index!, value);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.index == null ? 'Tạo bài học' : 'Chỉnh sửa bài học')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Tên bài học')),
          const SizedBox(height: 18),
          TextField(
              controller: description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Mô tả')),
          const SizedBox(height: 18),
          TextField(
              controller: duration,
              decoration: const InputDecoration(
                  labelText: 'Thời gian, ví dụ: 60 phút')),
          const SizedBox(height: 20),
          const Text('Bài học nhỏ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Tùy chọn, tối đa 3 mục.',
              style: TextStyle(color: AppColors.faint, fontSize: 12)),
          const SizedBox(height: 8),
          for (var index = 0; index < subLessons.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        controller: subLessons[index],
                        decoration: InputDecoration(
                            labelText: 'Bài học nhỏ ${index + 1}'))),
                if (subLessons.length > 1)
                  IconButton(
                      onPressed: () => setState(() {
                            subLessons[index].dispose();
                            subLessons.removeAt(index);
                          }),
                      icon: const Icon(Icons.remove_circle_outline)),
              ]),
            ),
          if (subLessons.length < 3)
            OutlinedButton.icon(
                onPressed: () =>
                    setState(() => subLessons.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('THÊM BÀI HỌC NHỎ')),
          const SizedBox(height: 20),
          FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('LƯU BÀI HỌC')),
        ],
      ),
    );
  }
}

enum ManagementType { challenges, rewards }

class ManagementScreen extends StatefulWidget {
  final ManagementType type;

  const ManagementScreen({super.key, required this.type});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<String> get items => switch (widget.type) {
        ManagementType.challenges => appState.managedChallenges,
        ManagementType.rewards => appState.rewards,
      };

  String get title => switch (widget.type) {
        ManagementType.challenges => 'CRUD Challenges',
        ManagementType.rewards => 'CRUD Thưởng',
      };

  String get hint => switch (widget.type) {
        ManagementType.challenges => 'Tên challenge · trạng thái · DP',
        ManagementType.rewards => 'Tên thưởng · required DP',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) =>
            ListView(padding: const EdgeInsets.all(20), children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'Prototype local state. Thay đổi chỉ tồn tại trong phiên chạy.',
              style: TextStyle(color: AppColors.dim)),
          const SizedBox(height: 16),
          Panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: hint)),
                const SizedBox(height: 10),
                FilledButton.icon(
                    onPressed: () {
                      appState.addManagedItem(items, controller.text);
                      controller.clear();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('TẠO MỚI')),
              ])),
          const SizedBox(height: 16),
          for (var index = 0; index < items.length; index++)
            Panel(
                child: ListTile(
                    title: Text(items[index]),
                    subtitle: Text(widget.type == ManagementType.challenges
                        ? 'Create · View · Edit · Activate · Close'
                        : 'ACTIVE · Có thể chỉnh sửa hoặc xóa'),
                    trailing: Wrap(spacing: 2, children: [
                      IconButton(
                          tooltip: 'Edit',
                          onPressed: () => _edit(index),
                          icon: const Icon(Icons.edit_outlined)),
                      IconButton(
                          tooltip: 'Delete',
                          onPressed: () =>
                              appState.removeManagedItem(items, index),
                          icon: const Icon(Icons.delete_outline)),
                    ]))),
        ]),
      ),
    );
  }

  Future<void> _edit(int index) async {
    controller.text = items[index];
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY')),
          FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  appState.updateManagedItem(items, index, controller.text);
                }
                controller.clear();
                Navigator.pop(context);
              },
              child: const Text('LƯU')),
        ],
      ),
    );
  }
}

class AdminConfigurationScreen extends StatefulWidget {
  const AdminConfigurationScreen({super.key});

  @override
  State<AdminConfigurationScreen> createState() =>
      _AdminConfigurationScreenState();
}

class _AdminConfigurationScreenState extends State<AdminConfigurationScreen> {
  late final TextEditingController threshold;
  late final TextEditingController sessionWeight;
  late final TextEditingController attitudeWeight;
  late final TextEditingController challengeWeight;
  late final TextEditingController freezeWeight;
  late final TextEditingController freezePerMonth;
  late final TextEditingController weeklyMinimum;

  @override
  void initState() {
    super.initState();
    threshold = TextEditingController(text: '${appState.completionThreshold}');
    sessionWeight = TextEditingController(text: '${appState.sessionDpWeight}');
    attitudeWeight =
        TextEditingController(text: '${appState.attitudeDpWeight}');
    challengeWeight =
        TextEditingController(text: '${appState.challengeDpWeight}');
    freezeWeight = TextEditingController(text: '${appState.freezeDpWeight}');
    freezePerMonth = TextEditingController(text: '${appState.freezePerMonth}');
    weeklyMinimum =
        TextEditingController(text: '${appState.freezeWeeklyMinimumSessions}');
  }

  @override
  void dispose() {
    threshold.dispose();
    sessionWeight.dispose();
    attitudeWeight.dispose();
    challengeWeight.dispose();
    freezeWeight.dispose();
    freezePerMonth.dispose();
    weeklyMinimum.dispose();
    super.dispose();
  }

  int _int(TextEditingController controller, int fallback) =>
      int.tryParse(controller.text.trim()) ?? fallback;

  void save() {
    appState.updateDpConfiguration(
      threshold: double.tryParse(threshold.text.trim()) ??
          appState.completionThreshold,
      sessionWeight: _int(sessionWeight, appState.sessionDpWeight),
      attitudeWeight: _int(attitudeWeight, appState.attitudeDpWeight),
      challengeWeight: _int(challengeWeight, appState.challengeDpWeight),
      freezeWeight: _int(freezeWeight, appState.freezeDpWeight),
    );
    appState.updateFreezeConfiguration(
      perMonth: _int(freezePerMonth, appState.freezePerMonth),
      weeklyMinimumSessions:
          _int(weeklyMinimum, appState.freezeWeeklyMinimumSessions),
    );
    showMessage(context, 'Cấu hình prototype đã được lưu.');
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration field(String label) => InputDecoration(labelText: label);
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('System Configuration',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('DP Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
            controller: threshold,
            keyboardType: TextInputType.number,
            decoration: field('Completion threshold (%)')),
        const SizedBox(height: 15),
        TextField(
            controller: sessionWeight,
            keyboardType: TextInputType.number,
            decoration: field('Session DP weight')),
        const SizedBox(height: 15),
        TextField(
            controller: attitudeWeight,
            keyboardType: TextInputType.number,
            decoration: field('Attitude DP weight')),
        const SizedBox(height: 15),
        TextField(
            controller: challengeWeight,
            keyboardType: TextInputType.number,
            decoration: field('Challenge DP reward')),
        const SizedBox(height: 15),
        TextField(
            controller: freezeWeight,
            keyboardType: TextInputType.number,
            decoration: field('Freeze DP weight')),
      ])),
      const SizedBox(height: 12),
      Panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Streak Freeze Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
            controller: freezePerMonth,
            keyboardType: TextInputType.number,
            decoration: field('Max Freeze usage / month')),
        const SizedBox(height: 15),
        TextField(
            controller: weeklyMinimum,
            keyboardType: TextInputType.number,
            decoration: field('Weekly minimum sessions')),
      ])),
      const SizedBox(height: 16),
      FilledButton.icon(
          onPressed: save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('LƯU CẤU HÌNH')),
    ]);
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) =>
          ListView(padding: const EdgeInsets.all(20), children: [
        const Text('ADMIN · HVP BOXING',
            style: TextStyle(color: AppColors.faint, letterSpacing: 1.2)),
        const Text('Operations Dashboard',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: StatBox(
                  value: appState.todayCheckedIn ? '1' : '0',
                  label: 'Check-in hôm nay',
                  icon: '📷',
                  color: AppColors.teal)),
          const SizedBox(width: 12),
          Expanded(
              child: StatBox(
                  value: '${appState.dpBalance}',
                  label: 'DP của Minh',
                  icon: '⭐',
                  color: AppColors.amber)),
        ]),
        const SizedBox(height: 16),
        Panel(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tình hình phòng tập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Check-in 7 ngày gần nhất',
              style: TextStyle(color: AppColors.dim, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: GymKpi(
                    value: '${appState.activeMemberCount}',
                    label: 'Học viên active',
                    color: AppColors.teal)),
            const SizedBox(width: 8),
            Expanded(
                child: GymKpi(
                    value: '${appState.fullAttendanceRate}%',
                    label: 'Đi học đầy đủ',
                    color: AppColors.amber)),
            const SizedBox(width: 8),
            Expanded(
                child: GymKpi(
                    value: '${appState.sessionsDeliveredThisWeek}',
                    label: 'Buổi tuần này',
                    color: AppColors.accent)),
          ]),
          const SizedBox(height: 14),
          const SizedBox(height: 150, child: GymTrendChart()),
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('T2',
                    style: TextStyle(color: AppColors.faint, fontSize: 11)),
                Text('T3',
                    style: TextStyle(color: AppColors.faint, fontSize: 11)),
                Text('T4',
                    style: TextStyle(color: AppColors.faint, fontSize: 11)),
                Text('T5',
                    style: TextStyle(color: AppColors.faint, fontSize: 11)),
                Text('T6',
                    style: TextStyle(color: AppColors.faint, fontSize: 11)),
                Text('T7',
                    style: TextStyle(color: AppColors.faint, fontSize: 11)),
                Text('CN',
                    style: TextStyle(color: AppColors.faint, fontSize: 11)),
              ]),
          const SizedBox(height: 12),
          const Row(children: [
            Icon(Icons.circle, size: 10, color: AppColors.teal),
            SizedBox(width: 6),
            Text('Check-in'),
            SizedBox(width: 18),
            Icon(Icons.circle, size: 10, color: AppColors.accent),
            SizedBox(width: 6),
            Text('Buổi hoàn thành'),
          ]),
        ])),
        const Panel(
            child: Text(
                'Core flow: Check-in → Coach xác nhận Attendance → Coach nhập % hoàn thành → System tính DP → PointTransaction → Rank Engine.')),
      ]),
    );
  }
}

class AdminLedgerScreen extends StatefulWidget {
  const AdminLedgerScreen({super.key});

  @override
  State<AdminLedgerScreen> createState() => _AdminLedgerScreenState();
}

class _AdminLedgerScreenState extends State<AdminLedgerScreen> {
  final amountController = TextEditingController(text: '10');
  final reasonController = TextEditingController(text: 'Coach attitude bonus');

  @override
  void dispose() {
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void addAdjustment() {
    final amount = int.tryParse(amountController.text.trim());
    if (amount == null) {
      showMessage(context, 'Amount không hợp lệ.');
      return;
    }
    appState.addManualAdjustment(amount, reasonController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) =>
          ListView(padding: const EdgeInsets.all(20), children: [
        Panel(
            child: Column(children: [
          TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'DP adjustment')),
          const SizedBox(height: 10),
          TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: addAdjustment,
              child: const Text('CREATE MANUAL ADJUSTMENT')),
        ])),
        const SizedBox(height: 14),
        const Text('PointTransaction Ledger',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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

class AdminRankScreen extends StatelessWidget {
  const AdminRankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rank Trials')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) =>
            ListView(padding: const EdgeInsets.all(20), children: [
          Panel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Rank Engine Review',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                    'Minh Nguyễn · THE UNKNOWN · ${appState.dpBalance}/500 DP'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                    value:
                        (appState.dpBalance / 500).clamp(0.0, 1.0).toDouble(),
                    color: AppColors.amber),
                const SizedBox(height: 12),
                const Text('Eligibility gates'),
                const ListTile(
                    leading: Icon(Icons.check_circle, color: AppColors.teal),
                    title: Text('Time Gate'),
                    subtitle: Text('Mock: đạt thời gian tối thiểu')),
                ListTile(
                    leading: Icon(
                        appState.dpBalance >= 500
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                        color: appState.dpBalance >= 500
                            ? AppColors.teal
                            : AppColors.accent),
                    title: const Text('DP Gate'),
                    subtitle: const Text('Mock target: 500 DP')),
                const ListTile(
                    leading:
                        Icon(Icons.pending_actions, color: AppColors.amber),
                    title: Text('Trial Gate'),
                    subtitle: Text('Chờ Rank Trial / approval')),
              ])),
          FilledButton(
              onPressed: appState.dpBalance >= 500
                  ? () => showMessage(
                      context, 'Rank approval mock đã được ghi nhận.')
                  : null,
              child: const Text('APPROVE RANK')),
        ]),
      ),
    );
  }
}
