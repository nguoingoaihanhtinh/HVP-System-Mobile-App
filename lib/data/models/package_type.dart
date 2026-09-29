/// Row of `package_types`.
class PackageType {
  final String id;
  final String code;
  final String name;

  /// null = open-ended.
  final int? durationDays;

  /// null = unlimited sessions.
  final int? totalSessions;
  final bool isTrial;

  /// Q-H5: a session-based package expires when it reaches 0 sessions.
  final bool expireOnZeroSessions;
  final int? priceVnd;
  final String description;

  const PackageType({
    required this.id,
    required this.code,
    required this.name,
    required this.durationDays,
    required this.totalSessions,
    required this.description,
    this.isTrial = false,
    this.expireOnZeroSessions = true,
    this.priceVnd,
  });
}
