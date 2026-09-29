/// Fixed role catalogue (DB §4.7, QA#3: no per-function permissions).
enum Role { member, coach, headCoach, receptionist, admin }

/// Row of `users` + active `user_roles`.
class AppUser {
  final String id;
  final String username;
  String fullName;
  String email;
  String phone;

  /// Optional until DB conflict C13 (address on sign-up) is resolved.
  String? address;

  /// Mock only. The real backend stores a bcrypt/argon2 hash, never this.
  String passwordHash;
  final Set<Role> roles;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.roles,
    required this.createdAt,
    this.address,
  });

  bool get isMember => roles.contains(Role.member);
  bool get isStaff =>
      roles.contains(Role.coach) ||
      roles.contains(Role.headCoach) ||
      roles.contains(Role.receptionist);
  bool get isAdmin => roles.contains(Role.admin);
}

/// Result of UC2 login. The token is a placeholder until the Node.js API exists.
class AuthSession {
  final AppUser user;
  final String accessToken;
  final DateTime issuedAt;

  const AuthSession(
      {required this.user, required this.accessToken, required this.issuedAt});
}
