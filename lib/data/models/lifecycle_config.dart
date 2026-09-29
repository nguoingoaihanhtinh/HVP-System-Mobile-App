/// `system_configs` values used by UC14–UC17 and the ledger.
///
/// Defaults are the values in hvp_seed.sql. The backend will serve them.
class LifecycleConfig {
  final int dpMonthlyCap;
  final int marksMonthlyCap;
  final int renewalReminderDays;
  final int renewalReminderSessions;

  /// Outside the monthly cap (seed: EARLY_RENEWAL counts_toward_cap = false).
  final int earlyRenewalMarks;
  final int inactiveAfterMonths;

  /// 0 = no warning.
  final int inactiveWarningDays;
  final int comebackMinGapDays;
  final int comebackBonusDp;
  final bool comebackCountsTowardCap;
  final int resetPinTtlMinutes;
  final int resetPinMaxAttempts;

  const LifecycleConfig({
    this.dpMonthlyCap = 1200,
    this.marksMonthlyCap = 150,
    this.renewalReminderDays = 7,
    this.renewalReminderSessions = 2,
    this.earlyRenewalMarks = 50,
    this.inactiveAfterMonths = 12,
    this.inactiveWarningDays = 30,
    this.comebackMinGapDays = 14,
    this.comebackBonusDp = 50,
    this.comebackCountsTowardCap = true,
    this.resetPinTtlMinutes = 5,
    this.resetPinMaxAttempts = 5,
  });
}
