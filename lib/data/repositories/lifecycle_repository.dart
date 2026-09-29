import '../models/lifecycle_records.dart';
import '../models/point_transaction.dart';

/// Summary of one background-job run (for the demo screen and logs).
class JobReport {
  final String job;
  final int changed;
  final int skipped;
  final List<String> lines;

  const JobReport(
      {required this.job,
      required this.changed,
      required this.skipped,
      required this.lines});
}

enum ComebackDecision {
  granted,
  capped,
  noPreviousSession,
  gapTooShort,
  alreadyGranted,
}

class ComebackOutcome {
  final ComebackDecision decision;
  final int gapDays;
  final ComebackCycle? cycle;
  final LedgerPostResult? posted;

  const ComebackOutcome(this.decision,
      {this.gapDays = 0, this.cycle, this.posted});

  bool get rewarded =>
      decision == ComebackDecision.granted ||
      decision == ComebackDecision.capped;
}

/// UC15–UC17. On the real system these run on the backend (daily jobs and
/// the SESSION_COMPLETED event handler); the app only reads their results.
abstract class LifecycleRepository {
  /// UC15: freeze members whose package expired with no follow-on package.
  Future<JobReport> runExpiryJob();

  /// UC16: warn, then set INACTIVE after 12 months without activity.
  Future<JobReport> runInactiveJob();

  /// UC4 hook: a check-in consumes one session of the active package.
  void onCheckedIn(String memberId);

  /// UC17: SESSION_COMPLETED event for a new completed attendance.
  Future<ComebackOutcome> onSessionCompleted(String memberId);

  /// UC17: redeliver the last SESSION_COMPLETED event (idempotency demo).
  Future<ComebackOutcome> replayLastSessionCompleted(String memberId);

  List<MarksFreezeLog> freezeLogs(String memberId);

  List<ComebackCycle> comebackCycles(String memberId);

  List<AuditLog> auditLogs();
}
