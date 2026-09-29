import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvp_boxing_prototype/app/app_state.dart';
import 'package:hvp_boxing_prototype/app/repositories.dart';
import 'package:hvp_boxing_prototype/core/clock.dart';
import 'package:hvp_boxing_prototype/core/messages.dart';
import 'package:hvp_boxing_prototype/data/mock/mock_db.dart';
import 'package:hvp_boxing_prototype/pages/auth/auth_pages.dart';
import 'package:hvp_boxing_prototype/pages/membership/membership_screen.dart';
import 'package:hvp_boxing_prototype/pages/student/student_pages.dart';

Widget _app(Widget home) => MaterialApp(home: home);

/// Lets an async submit finish. Avoids pumpAndSettle because CheckinScreen
/// repaints every second and would never settle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late MockDb db;

  setUp(() {
    db = MockDb(
        appState: AppState(),
        clock: SimulatedClock(base: DateTime(2026, 9, 29, 10)),
        latency: Duration.zero);
    Repositories.useMock(db: db);
  });

  testWidgets('login shows MSG5 then MSG6', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));

    await tester.tap(find.text('ĐĂNG NHẬP'));
    await _settle(tester);
    expect(find.text(Msgs.loginMissing.display), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'minh');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.text('ĐĂNG NHẬP'));
    await _settle(tester);
    expect(find.text(Msgs.loginFailed.display), findsOneWidget);
  });

  testWidgets('sign-up with a weak password shows MSG1', (tester) async {
    await tester.pumpWidget(_app(const SignupScreen()));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Học viên');
    await tester.enterText(fields.at(1), 'hv@hvp.demo');
    await tester.enterText(fields.at(2), '0988000111');
    await tester.enterText(fields.at(4), 'abc');
    await tester.enterText(fields.at(5), 'abc');
    await tester.ensureVisible(find.text('ĐĂNG KÝ'));
    await tester.tap(find.text('ĐĂNG KÝ'));
    await _settle(tester);
    expect(find.text(Msgs.invalidInput.display), findsOneWidget);
  });

  testWidgets('forgot password: phone → PIN → new password → login',
      (tester) async {
    await tester.pumpWidget(_app(const ForgotScreen()));

    await tester.enterText(find.byType(TextField), '0901234567');
    await tester.tap(find.text('GỬI MÃ PIN'));
    await _settle(tester);
    final snack = tester.widget<Text>(find.textContaining('PIN demo')).data!;
    final pin = RegExp(r'PIN demo: (\d{6})').firstMatch(snack)!.group(1)!;

    await tester.enterText(find.byType(TextField), pin);
    await tester.tap(find.text('XÁC NHẬN PIN'));
    await _settle(tester);

    await tester.enterText(find.byType(TextField).at(0), 'newpass123');
    await tester.enterText(find.byType(TextField).at(1), 'newpass123');
    await tester.tap(find.text('ĐẶT LẠI MẬT KHẨU'));
    await _settle(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text(Msgs.redirectLoginNewPassword.display), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('frozen member cannot check in and gets the renewal CTA',
      (tester) async {
    db.clock.advance(const Duration(days: 11));
    await Repositories.lifecycle.runExpiryJob();

    await tester.pumpWidget(_app(const Scaffold(body: CheckinScreen())));
    await tester.tap(find.text('XÁC NHẬN CHECK-IN'));
    await _settle(tester);
    expect(find.text(Msgs.restricted.display), findsOneWidget);

    await tester.tap(find.text('GIA HẠN'));
    await _settle(tester);
    expect(find.byType(MembershipScreen), findsOneWidget);
    expect(find.text('FROZEN'), findsOneWidget);
    expect(db.appState.todayCheckedIn, isFalse);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('membership screen sends a renewal request once', (tester) async {
    await tester.pumpWidget(_app(const MembershipScreen()));
    await tester.tap(find.text('GỬI YÊU CẦU GIA HẠN'));
    await _settle(tester);
    await tester.tap(find.text('GỬI YÊU CẦU'));
    await _settle(tester);

    expect(find.text('CHỜ XỬ LÝ'), findsOneWidget);
    expect(find.text('GỬI YÊU CẦU GIA HẠN'), findsNothing);
    expect(Repositories.membership.pendingRenewals(), hasLength(2));
    await tester.pump(const Duration(seconds: 5));
  });

  test('daysBetween ignores time of day', () {
    expect(daysBetween(DateTime(2026, 9, 1, 23), DateTime(2026, 9, 2, 1)), 1);
  });
}
