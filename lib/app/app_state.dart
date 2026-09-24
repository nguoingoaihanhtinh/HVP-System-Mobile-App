import 'package:flutter/foundation.dart';

class PointEntry {
  final String id;
  final String source;
  final int amount;
  final String status;
  final String actor;

  const PointEntry(this.id, this.source, this.amount, this.status, this.actor);
}

class TrainingSession {
  final String date;
  final String type;
  final String coach;
  final bool checkedIn;
  bool attendanceConfirmed;
  int? completionPercent;
  int dpEarned;
  String status;

  TrainingSession({
    required this.date,
    required this.type,
    required this.coach,
    required this.checkedIn,
    required this.attendanceConfirmed,
    required this.completionPercent,
    required this.dpEarned,
    required this.status,
  });
}

class Lesson {
  String name;
  String description;
  String duration;
  List<String> subLessons;

  Lesson({
    required this.name,
    required this.description,
    required this.duration,
    required this.subLessons,
  });
}

class ScheduledClass {
  final String id;
  String lessonName;
  String date;
  String time;
  String instructor;
  List<String> members;

  ScheduledClass({
    required this.id,
    required this.lessonName,
    required this.date,
    required this.time,
    required this.instructor,
    required this.members,
  });
}

class AppState extends ChangeNotifier {
  int dpBalance = 350;
  int availableMarks = 350;
  int remainingSessions = 6;
  bool todayCheckedIn = false;
  int activeMemberCount = 124;
  int fullAttendanceRate = 82;
  int sessionsDeliveredThisWeek = 18;
  final List<Lesson> lessons = [
    Lesson(
      name: 'Boxing Fundamentals',
      description: 'Nền tảng tư thế, guard và kỹ thuật đấm cơ bản.',
      duration: '60 phút',
      subLessons: ['Stance & Guard', 'Jab-Cross'],
    ),
    Lesson(
      name: 'Footwork & Defense',
      description: 'Di chuyển, né đòn và phòng thủ cơ bản.',
      duration: '45 phút',
      subLessons: ['Pivot', 'Slip & Roll'],
    ),
  ];
  final List<String> rewards = ['Găng tay HVP · 250 DP', 'Áo tập HVP · 180 DP'];
  final List<String> managedChallenges = [
    '30-Day Discipline · ACTIVE · 100 DP',
    'Footwork Week · DRAFT · 50 DP',
  ];
  double completionThreshold = 70;
  int sessionDpWeight = 45;
  int attitudeDpWeight = 10;
  int challengeDpWeight = 50;
  int freezeDpWeight = 0;
  int freezePerMonth = 1;
  int freezeWeeklyMinimumSessions = 2;
  final List<ScheduledClass> scheduledClasses = [
    ScheduledClass(
      id: 'CLS-1001',
      lessonName: 'Boxing Fundamentals',
      date: '24/09/2026',
      time: '16:30 - 17:30',
      instructor: 'Coach Tuấn',
      members: ['Minh Nguyễn', 'An Trần', 'Linh Phạm'],
    ),
    ScheduledClass(
      id: 'CLS-1002',
      lessonName: 'Footwork & Defense',
      date: '26/09/2026',
      time: '18:00 - 19:00',
      instructor: 'Coach Linh',
      members: ['Minh Nguyễn', 'Khoa Lê'],
    ),
  ];
  final List<PointEntry> pointTransactions = [
    const PointEntry('PT-1004', 'SESSION', 45, 'CONFIRMED', 'System'),
    const PointEntry('PT-1003', 'ATTITUDE', 10, 'CONFIRMED', 'Coach Tuấn'),
    const PointEntry('PT-1002', 'ACADEMY', 70, 'CONFIRMED', 'Coach Tuấn'),
  ];
  final List<TrainingSession> sessions = [
    TrainingSession(
      date: '23/09/2026',
      type: 'Boxing Fundamentals',
      coach: 'Coach Tuấn',
      checkedIn: false,
      attendanceConfirmed: false,
      completionPercent: null,
      dpEarned: 0,
      status: 'Waiting for check-in',
    ),
    TrainingSession(
      date: '20/09/2026',
      type: 'Footwork & Defense',
      coach: 'Coach Linh',
      checkedIn: true,
      attendanceConfirmed: true,
      completionPercent: 90,
      dpEarned: 45,
      status: 'Completed',
    ),
    TrainingSession(
      date: '18/09/2026',
      type: 'Conditioning',
      coach: 'Coach Tuấn',
      checkedIn: true,
      attendanceConfirmed: true,
      completionPercent: 55,
      dpEarned: 0,
      status: 'Below threshold',
    ),
  ];

  TrainingSession get todaySession => sessions.first;

  void checkInToday() {
    if (todayCheckedIn) return;
    todayCheckedIn = true;
    remainingSessions -= 1;
    todaySession.status = 'Waiting for coach confirmation';
    sessions[0] = TrainingSession(
      date: todaySession.date,
      type: todaySession.type,
      coach: todaySession.coach,
      checkedIn: true,
      attendanceConfirmed: todaySession.attendanceConfirmed,
      completionPercent: todaySession.completionPercent,
      dpEarned: todaySession.dpEarned,
      status: todaySession.status,
    );
    notifyListeners();
  }

  void addManualAdjustment(int amount, String reason) {
    dpBalance += amount;
    availableMarks += amount;
    pointTransactions.insert(
      0,
      PointEntry(
        'ADJ-${pointTransactions.length + 1000}',
        'MANUAL_ADJUSTMENT: $reason',
        amount,
        'CONFIRMED',
        'Admin',
      ),
    );
    notifyListeners();
  }

  void addManagedItem(List<String> items, String name) {
    if (name.trim().isEmpty) return;
    items.add(name.trim());
    notifyListeners();
  }

  void addLesson(Lesson lesson) {
    lessons.add(lesson);
    notifyListeners();
  }

  void updateLesson(int index, Lesson lesson) {
    lessons[index] = lesson;
    notifyListeners();
  }

  void removeLesson(int index) {
    lessons.removeAt(index);
    notifyListeners();
  }

  void addScheduledClass(ScheduledClass scheduledClass) {
    scheduledClasses.add(scheduledClass);
    notifyListeners();
  }

  void updateScheduledClass(int index, ScheduledClass scheduledClass) {
    scheduledClasses[index] = scheduledClass;
    notifyListeners();
  }

  void removeScheduledClass(int index) {
    scheduledClasses.removeAt(index);
    notifyListeners();
  }

  void removeManagedItem(List<String> items, int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void updateManagedItem(List<String> items, int index, String value) {
    if (value.trim().isEmpty) return;
    items[index] = value.trim();
    notifyListeners();
  }

  void updateDpConfiguration({
    required double threshold,
    required int sessionWeight,
    required int attitudeWeight,
    required int challengeWeight,
    required int freezeWeight,
  }) {
    completionThreshold = threshold;
    sessionDpWeight = sessionWeight;
    attitudeDpWeight = attitudeWeight;
    challengeDpWeight = challengeWeight;
    freezeDpWeight = freezeWeight;
    notifyListeners();
  }

  void updateFreezeConfiguration({
    required int perMonth,
    required int weeklyMinimumSessions,
  }) {
    freezePerMonth = perMonth;
    freezeWeeklyMinimumSessions = weeklyMinimumSessions;
    notifyListeners();
  }

  void redeemReward(int cost) {
    if (cost > availableMarks) return;
    availableMarks -= cost;
    notifyListeners();
  }

  void confirmAttendance() {
    if (!todaySession.checkedIn) return;
    todaySession.attendanceConfirmed = true;
    todaySession.status = 'Attendance confirmed';
    notifyListeners();
  }

  void addSessionResult(int completionPercent) {
    if (!todaySession.checkedIn || !todaySession.attendanceConfirmed) return;
    if (todaySession.completionPercent != null) return;
    // MOCK VALUE FOR UI PROTOTYPE ONLY.
    // Replace with configured value from backend.
    final amount =
        completionPercent >= completionThreshold ? sessionDpWeight : 0;
    dpBalance += amount;
    availableMarks += amount;
    todaySession.completionPercent = completionPercent;
    todaySession.dpEarned = amount;
    todaySession.status = completionPercent >= completionThreshold
        ? 'Completed'
        : 'Below threshold';
    pointTransactions.insert(
      0,
      PointEntry(
        'PT-${pointTransactions.length + 1000}',
        'SESSION · ${todaySession.type} · $completionPercent%',
        amount,
        'CONFIRMED',
        'System',
      ),
    );
    notifyListeners();
  }
}

final appState = AppState();
