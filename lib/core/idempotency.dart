import 'package:uuid/uuid.dart';

import 'clock.dart';

/// Idempotency key formats from HVP_Database_Design.md §4.2.
///
/// The backend stores them under a unique constraint, so a replayed event or
/// a double tap returns the existing row instead of creating a second one.
class IdempotencyKeys {
  static String renewal(String oldMembershipId) => 'renewal:$oldMembershipId';

  static String comeback(String memberId, String previousAttendanceId) =>
      'comeback:$memberId:$previousAttendanceId';

  static String freeze(String membershipId) => 'freeze:$membershipId';

  static String unfreeze(String newMembershipId) =>
      'unfreeze:$newMembershipId';

  static String inactiveWarning(String memberId, DateTime inactiveDate) =>
      'INACTIVE_WARNING:$memberId:${ymd(inactiveDate)}';

  static String accountInactive(String memberId, DateTime inactiveDate) =>
      'ACCOUNT_INACTIVE:$memberId:${ymd(inactiveDate)}';

  static String renewalRequest(String clientRequestId) =>
      'renewal-request:$clientRequestId';
}

const _uuid = Uuid();

/// One id per form. Retries of the same submit reuse it.
String newClientRequestId() => _uuid.v4();

String newId(String prefix) => '$prefix-${_uuid.v4().substring(0, 8)}';
