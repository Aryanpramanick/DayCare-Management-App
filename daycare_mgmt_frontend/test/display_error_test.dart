import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/display_error.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  testWidgets('Test Display Error', (WidgetTester tester) async {
    Object? error = 404;
    await tester.pumpWidget(const MaterialApp(home: DisplayError(error: 404)));

    Finder errorMessage = find.byType(Text);

    // Verify that the widgets exist.
    expect(errorMessage, findsOneWidget);
    // Verify message appeared
    expect(find.text('Something went wrong: $error'), findsOneWidget);
  });
}
