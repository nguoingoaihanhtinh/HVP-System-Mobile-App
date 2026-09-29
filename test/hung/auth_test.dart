import 'package:flutter_test/flutter_test.dart';
import 'package:hvp_boxing_prototype/core/messages.dart';
import 'package:hvp_boxing_prototype/core/result.dart';
import 'package:hvp_boxing_prototype/data/repositories/auth_repository.dart';

import 'test_helpers.dart';

SignUpData _signUp({String email = 'new@hvp.demo', String password = 'abc12345'}) =>
    SignUpData(
      fullName: 'Học viên Mới',
      email: email,
      phone: '0988000111',
      password: password,
      confirmPassword: password,
    );

void main() {
  group('UC1 sign up', () {
    test('valid data creates a member (MSG3)', () async {
      final f = Fixture();
      final result = await f.auth.signUp(_signUp());
      expect((result as Ok).message, Msgs.accountCreated);
      expect(f.db.members.length, 3);
    });

    test('weak password is MSG1', () async {
      final f = Fixture();
      final result = await f.auth.signUp(_signUp(password: 'short'));
      expect((result as Err).message, Msgs.invalidInput);
    });

    test('taken email is MSG2', () async {
      final f = Fixture();
      final result = await f.auth.signUp(_signUp(email: 'Student@hvp.demo'));
      expect((result as Err).message, Msgs.emailTaken);
    });
  });

  group('UC2 login', () {
    test('empty fields are MSG5', () async {
      final f = Fixture();
      expect(((await f.auth.login('', 'x')) as Err).message, Msgs.loginMissing);
    });

    test('wrong password is MSG6', () async {
      final f = Fixture();
      expect(((await f.auth.login('minh', 'nope')) as Err).message,
          Msgs.loginFailed);
    });

    test('email or username logs in (MSG7)', () async {
      final f = Fixture();
      expect((await f.auth.login('minh', 'hvp12345')).isOk, isTrue);
      expect((await f.auth.login('STUDENT@hvp.demo', 'hvp12345')).isOk, isTrue);
      expect(f.auth.currentSession!.user.username, 'minh');
    });
  });

  group('UC3 forgot password', () {
    test('unknown phone is MSG9', () async {
      final f = Fixture();
      final result = await f.auth.requestPasswordReset('0999999999');
      expect((result as Err).message, Msgs.phoneNotRegistered);
    });

    test('PIN → new password → login with it', () async {
      final f = Fixture();
      final challenge = ((await f.auth.requestPasswordReset('0901234567'))
              as Ok<PinChallenge>)
          .value;

      final wrong = await f.auth.verifyPin(challenge.requestId, '000000');
      expect((wrong as Err).message, Msgs.pinInvalid);

      final token =
          ((await f.auth.verifyPin(challenge.requestId, challenge.debugPin!))
                  as Ok<String>)
              .value;
      final weak = await f.auth.resetPassword(token, 'abc', 'abc');
      expect((weak as Err).message, Msgs.passwordRule);

      final done = await f.auth.resetPassword(token, 'newpass123', 'newpass123');
      expect((done as Ok).message, Msgs.passwordUpdated);
      expect((await f.auth.login('minh', 'newpass123')).isOk, isTrue);
      expect((await f.auth.resetPassword(token, 'again1234', 'again1234')).isOk,
          isFalse);
    });

    test('expired PIN is MSG11', () async {
      final f = Fixture();
      final challenge = ((await f.auth.requestPasswordReset('0901234567'))
              as Ok<PinChallenge>)
          .value;
      f.db.clock.advance(const Duration(minutes: 6));
      final result =
          await f.auth.verifyPin(challenge.requestId, challenge.debugPin!);
      expect((result as Err).message, Msgs.pinInvalid);
    });
  });
}
