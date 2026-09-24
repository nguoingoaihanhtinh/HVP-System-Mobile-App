import 'dart:math';

import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../theme/app_theme.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppColors.cardHi, AppColors.card]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class StatBox extends StatelessWidget {
  final String value, label, icon;
  final Color color;
  const StatBox(
      {super.key,
      required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon),
        Text(value,
            style: TextStyle(
                fontSize: 23, color: color, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: AppColors.faint, fontSize: 11))
      ]));
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        border: Border.all(color: color.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class CoachStudentReviewCard extends StatelessWidget {
  final TrainingSession session;
  final double completion;
  final int estimatedDp;
  final bool canConfirmAttendance;
  final bool canSubmitCompletion;
  final VoidCallback onMockCheckin;
  final VoidCallback onConfirmAttendance;
  final ValueChanged<double> onCompletionChanged;
  final VoidCallback onSubmitCompletion;
  final double completionThreshold;

  const CoachStudentReviewCard({
    super.key,
    required this.session,
    required this.completion,
    required this.estimatedDp,
    required this.canConfirmAttendance,
    required this.canSubmitCompletion,
    required this.onMockCheckin,
    required this.onConfirmAttendance,
    required this.onCompletionChanged,
    required this.onSubmitCompletion,
    required this.completionThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final status = session.attendanceConfirmed
        ? 'CONFIRMED'
        : session.checkedIn
            ? 'WAITING'
            : 'NO-SHOW';
    final color = session.attendanceConfirmed
        ? AppColors.teal
        : session.checkedIn
            ? AppColors.amber
            : AppColors.faint;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ink2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: .45)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(radius: 16, child: Text('M')),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Minh Nguyễn',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(
                    session.checkedIn
                        ? '16:28 · Gói A · ${appState.remainingSessions} buổi'
                        : 'Chưa check-in',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.faint, fontSize: 11)),
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(status,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ]),
        const Divider(height: 20),
        StepRow(
            done: session.checkedIn,
            title: '1. Student check-in',
            detail: session.checkedIn
                ? 'Đã ghi nhận hiện diện, chưa cộng DP.'
                : 'Chờ học viên quét QR trước khi Coach xác nhận.'),
        StepRow(
            done: session.attendanceConfirmed,
            title: '2. Coach xác nhận Attendance',
            detail: 'Coach xác nhận học viên thật sự tham gia buổi tập.'),
        StepRow(
            done: session.completionPercent != null,
            title: '3. Coach nhập % hoàn thành',
            detail: 'System tính DP nếu completion >= $completionThreshold%.'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: session.checkedIn ? null : onMockCheckin,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('MOCK STUDENT CHECK-IN'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canConfirmAttendance ? onConfirmAttendance : null,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('XÁC NHẬN ATTENDANCE'),
          ),
        ),
        const SizedBox(height: 12),
        Text('Completion: ${completion.round()}%'),
        Slider(
            value: completion,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${completion.round()}%',
            onChanged: canSubmitCompletion ? onCompletionChanged : null),
        Text('DP dự kiến: $estimatedDp DP'),
        const SizedBox(height: 6),
        Text(
            'Threshold hiện tại: $completionThreshold%. DP chỉ được tính sau bước này.',
            style: const TextStyle(color: AppColors.faint, fontSize: 12)),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: canSubmitCompletion ? onSubmitCompletion : null,
            icon: const Icon(Icons.add_card_outlined),
            label: const Text('NHẬP % HOÀN THÀNH VÀ TÍNH DP'),
          ),
        ),
        if (session.completionPercent != null) ...[
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.verified_outlined,
                color: AppColors.teal, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    'Đã xử lý: Completion ${session.completionPercent}% · DP earned ${session.dpEarned} · PointTransaction đã tạo.',
                    style:
                        const TextStyle(color: AppColors.dim, fontSize: 12))),
          ]),
        ]
      ]),
    );
  }
}

class CoachQueueItem extends StatelessWidget {
  final String initials;
  final String name;
  final String meta;
  final String status;
  final Color color;

  const CoachQueueItem({
    super.key,
    required this.initials,
    required this.name,
    required this.meta,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ink2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        CircleAvatar(radius: 16, child: Text(initials)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.faint, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(status,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class StepRow extends StatelessWidget {
  final bool done;
  final String title;
  final String detail;

  const StepRow(
      {super.key,
      required this.done,
      required this.title,
      required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? AppColors.teal : AppColors.faint),
      title: Text(title),
      subtitle: Text(detail),
    );
  }
}

class GymKpi extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const GymKpi({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.faint, fontSize: 10)),
        ]),
      );
}

class GymTrendChart extends StatelessWidget {
  const GymTrendChart({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GymTrendPainter(),
        child: const SizedBox.expand(),
      );
}

class GymTrendPainter extends CustomPainter {
  final List<double> checkins = const [.45, .62, .38, .76, .9, .58, .7];
  final List<double> completed = const [.28, .48, .25, .6, .72, .4, .56];

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .1)
      ..strokeWidth = 1;
    for (var line = 1; line <= 3; line++) {
      final y = size.height * line / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final groupWidth = size.width / checkins.length;
    final barWidth = groupWidth * .24;
    final checkinPaint = Paint()..color = AppColors.teal;
    final completePaint = Paint()..color = AppColors.accent;
    for (var index = 0; index < checkins.length; index++) {
      final left = index * groupWidth + groupWidth * .2;
      final checkinHeight = size.height * checkins[index];
      final completeHeight = size.height * completed[index];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                left, size.height - checkinHeight, barWidth, checkinHeight),
            const Radius.circular(4)),
        checkinPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(left + barWidth + 4, size.height - completeHeight,
                barWidth, completeHeight),
            const Radius.circular(4)),
        completePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GymTrendPainter oldDelegate) => false;
}

class QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.card;
    final white = Paint()..color = AppColors.text;
    canvas.drawRect(Offset.zero & size, background);
    final random = Random(8);
    final cell = size.width / 15;
    for (var y = 0; y < 15; y++) {
      for (var x = 0; x < 15; x++) {
        if (random.nextBool()) {
          canvas.drawRect(
              Rect.fromLTWH(x * cell, y * cell, cell - 2, cell - 2), white);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrPainter oldDelegate) => false;
}
