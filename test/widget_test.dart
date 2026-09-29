// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:hvp_boxing_prototype/main.dart';

void main() {
  testWidgets('opens HVP Boxing splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HvpApp());
    expect(find.text('HVP BOXING'), findsOneWidget);
    // Let the splash timer fire so no timer is pending at the end.
    await tester.pump(const Duration(seconds: 1));
  });
}
