enum ContactChannel { phone, zalo, email, atClub }

extension ContactChannelLabel on ContactChannel {
  String get label => switch (this) {
        ContactChannel.phone => 'Điện thoại',
        ContactChannel.zalo => 'Zalo',
        ContactChannel.email => 'Email',
        ContactChannel.atClub => 'Tại CLB',
      };
}

enum RenewalStatus { pending, completed, cancelled }

extension RenewalStatusLabel on RenewalStatus {
  String get label => name.toUpperCase();
}

/// Row of `renewal_requests` (UC14). At most one PENDING per member.
class RenewalRequest {
  final String id;
  final String memberId;
  final String? currentMembershipId;
  final String desiredPackageTypeId;
  final ContactChannel contactChannel;
  final String? note;

  /// Form id reused on retry, so a double submit creates one request.
  final String clientRequestId;
  RenewalStatus status;
  int contactAttempts;
  String? handledBy;
  DateTime? handledAt;
  String? cancelReason;
  String? resultingMembershipId;
  final DateTime createdAt;

  RenewalRequest({
    required this.id,
    required this.memberId,
    required this.currentMembershipId,
    required this.desiredPackageTypeId,
    required this.contactChannel,
    required this.clientRequestId,
    required this.createdAt,
    this.note,
    this.status = RenewalStatus.pending,
    this.contactAttempts = 0,
  });
}
