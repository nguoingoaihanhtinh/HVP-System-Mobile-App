import '../../core/result.dart';
import '../models/user.dart';

class SignUpData {
  final String fullName;
  final String email;
  final String phone;
  final String? address;
  final String password;
  final String confirmPassword;

  const SignUpData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    this.address,
  });
}

/// Step 1 of UC3. [debugPin] is filled only by the mock (no SMS gateway).
class PinChallenge {
  final String requestId;
  final String maskedPhone;
  final DateTime expiresAt;
  final String? debugPin;

  const PinChallenge({
    required this.requestId,
    required this.maskedPhone,
    required this.expiresAt,
    this.debugPin,
  });
}

/// UC1–UC3. Implemented by the mock now and by the Node.js API later.
abstract class AuthRepository {
  AuthSession? get currentSession;

  /// UC1 BR3–BR5. MSG1 invalid input, MSG2 email taken, MSG3 on success.
  Future<Result<AppUser>> signUp(SignUpData data);

  /// UC2 BR10–BR13. [identifier] is an email or a username.
  Future<Result<AuthSession>> login(String identifier, String password);

  Future<void> logout();

  /// UC3 BR16–BR17. MSG9 unknown phone, MSG10 PIN sent.
  Future<Result<PinChallenge>> requestPasswordReset(String phone);

  /// UC3 BR18. Returns a one-time reset token. MSG11 wrong/expired PIN.
  Future<Result<String>> verifyPin(String requestId, String pin);

  /// UC3 BR22–BR23. MSG12 weak/mismatch, MSG13 on success.
  Future<Result<void>> resetPassword(
      String resetToken, String newPassword, String confirmPassword);
}
