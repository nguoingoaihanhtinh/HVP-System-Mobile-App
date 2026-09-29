import 'dart:math';

import '../../core/idempotency.dart';
import '../../core/messages.dart';
import '../../core/result.dart';
import '../../core/validators.dart';
import '../models/member.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'mock_db.dart';

class _PasswordReset {
  final String id;
  final String userId;
  final String pin;
  final DateTime expiresAt;
  int attempts = 0;
  String? resetToken;
  bool used = false;

  _PasswordReset(this.id, this.userId, this.pin, this.expiresAt);
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this.db);

  final MockDb db;
  final _random = Random.secure();
  final Map<String, _PasswordReset> _resets = {};
  AuthSession? _session;

  /// Mirrors `auth_logs` (UC2 BR13).
  final List<String> authLogs = [];

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<Result<AppUser>> signUp(SignUpData data) async {
    await db.delay();
    final email = data.email.trim().toLowerCase();
    final valid = data.fullName.trim().isNotEmpty &&
        Validators.isEmail(email) &&
        Validators.isPhone(data.phone) &&
        Validators.isValidNewPassword(data.password, data.confirmPassword);
    if (!valid) return const Err(Msgs.invalidInput);
    if (db.users.any((user) => user.email.toLowerCase() == email)) {
      return const Err(Msgs.emailTaken);
    }
    final phone = Validators.normalizePhone(data.phone);
    if (db.users.any((user) => user.phone == phone)) {
      return const Err(Msgs.invalidInput);
    }

    final user = AppUser(
      id: newId('U'),
      username: email.split('@').first,
      fullName: data.fullName.trim(),
      email: email,
      phone: phone,
      address: (data.address?.trim().isEmpty ?? true) ? null : data.address,
      passwordHash: data.password,
      roles: {Role.member},
      createdAt: db.now,
    );
    db.users.add(user);
    db.members[user.id] = Member(
      userId: user.id,
      memberCode: 'HVP-${(db.members.length + 1).toString().padLeft(4, '0')}',
      fullName: user.fullName,
      joinedAt: db.now,
    );
    db.audit(user.id, 'USER_SIGNUP', 'users', user.id);
    db.notify(user.id, 'WELCOME', 'Chào mừng tới HVP Boxing',
        'Tài khoản của bạn đã sẵn sàng. Liên hệ lễ tân để kích hoạt gói tập.');
    db.commit();
    return Ok(user, message: Msgs.accountCreated);
  }

  @override
  Future<Result<AuthSession>> login(String identifier, String password) async {
    await db.delay();
    final id = identifier.trim().toLowerCase();
    if (id.isEmpty || password.isEmpty) return const Err(Msgs.loginMissing);

    final matches = db.users.where(
        (user) => user.email.toLowerCase() == id || user.username == id);
    final user = matches.isEmpty ? null : matches.first;
    if (user == null || user.passwordHash != password) {
      authLogs.add('${db.now.toIso8601String()} LOGIN_FAILED $id');
      return const Err(Msgs.loginFailed);
    }

    // Login does not count as activity for UC16 (Q-H8).
    _session = AuthSession(
        user: user, accessToken: 'mock.${newClientRequestId()}', issuedAt: db.now);
    authLogs.add('${db.now.toIso8601String()} LOGIN_SUCCESS ${user.id}');
    db.notify(user.id, 'LOGIN_ALERT', 'Đăng nhập mới',
        'Tài khoản của bạn vừa đăng nhập lúc ${db.now}.');
    db.commit();
    return Ok(_session!, message: Msgs.loginSuccess);
  }

  @override
  Future<void> logout() async {
    _session = null;
    db.commit();
  }

  @override
  Future<Result<PinChallenge>> requestPasswordReset(String phone) async {
    await db.delay();
    if (!Validators.isPhone(phone)) return const Err(Msgs.phoneNotRegistered);
    final normalized = Validators.normalizePhone(phone);
    final matches = db.users.where((user) => user.phone == normalized);
    if (matches.isEmpty) return const Err(Msgs.phoneNotRegistered);

    final pin = (_random.nextInt(900000) + 100000).toString();
    final request = _PasswordReset(newId('PR'), matches.first.id, pin,
        db.now.add(Duration(minutes: db.config.resetPinTtlMinutes)));
    _resets[request.id] = request;
    return Ok(
      PinChallenge(
        requestId: request.id,
        maskedPhone: '${normalized.substring(0, 3)}****${normalized.substring(7)}',
        expiresAt: request.expiresAt,
        debugPin: pin,
      ),
      message: Msgs.pinSent,
    );
  }

  @override
  Future<Result<String>> verifyPin(String requestId, String pin) async {
    await db.delay();
    final request = _resets[requestId];
    if (request == null ||
        request.used ||
        db.now.isAfter(request.expiresAt) ||
        request.attempts >= db.config.resetPinMaxAttempts) {
      return const Err(Msgs.pinInvalid);
    }
    if (request.pin != pin.trim()) {
      request.attempts++;
      return const Err(Msgs.pinInvalid);
    }
    request.resetToken = newClientRequestId();
    return Ok(request.resetToken!);
  }

  @override
  Future<Result<void>> resetPassword(
      String resetToken, String newPassword, String confirmPassword) async {
    await db.delay();
    final matches = _resets.values
        .where((request) => request.resetToken == resetToken && !request.used);
    if (matches.isEmpty) return const Err(Msgs.pinInvalid);
    if (!Validators.isValidNewPassword(newPassword, confirmPassword)) {
      return const Err(Msgs.passwordRule);
    }
    final request = matches.first;
    request.used = true;
    db.userById(request.userId)!.passwordHash = newPassword;
    db.audit(request.userId, 'PASSWORD_RESET', 'users', request.userId);
    db.notify(request.userId, 'PASSWORD_RESET', 'Mật khẩu đã thay đổi',
        'Mật khẩu của bạn vừa được đặt lại.');
    db.commit();
    return const Ok(null, message: Msgs.passwordUpdated);
  }
}
