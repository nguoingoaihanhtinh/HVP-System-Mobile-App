/// `members.status` (DB §4.5).
enum MemberStatus { active, frozen, inactive }

/// `members.marks_status`. INACTIVE members keep FROZEN Marks.
enum MarksStatus { active, frozen }

extension MemberStatusLabel on MemberStatus {
  String get label => name.toUpperCase();
}

/// Row of `members` (1:1 with a user who has the MEMBER role).
///
/// Balances are not stored here: the ledger owns them (see PointLedger).
class Member {
  final String userId;
  final String memberCode;
  final String fullName;
  final DateTime joinedAt;
  MemberStatus status;
  MarksStatus marksStatus;

  /// UC17 gap reference.
  DateTime? lastCompletedSessionAt;

  /// UC16 reference. Login does NOT update it (Q-H8).
  DateTime? lastActivityAt;
  DateTime? inactiveAt;

  Member({
    required this.userId,
    required this.memberCode,
    required this.fullName,
    required this.joinedAt,
    this.status = MemberStatus.active,
    this.marksStatus = MarksStatus.active,
    this.lastCompletedSessionAt,
    this.lastActivityAt,
    this.inactiveAt,
  });

  bool get isRestricted => status != MemberStatus.active;
}
