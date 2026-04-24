// Basic widget test for eSewa Scheduler.

import 'package:flutter_test/flutter_test.dart';

import 'package:esewa_prototype/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const EsewaApp());
    // Verify the app renders with the dashboard title
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
