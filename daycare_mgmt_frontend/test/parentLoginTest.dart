import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/parent_login.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  testWidgets('Test Login UI', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const parentLogin());
    Finder usernameField = find.byKey(const Key('username'));
    Finder passwordField = find.byKey(const Key('password'));

    // Verify that the textfields exist.
    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    // Edit text into the textfield.
    await tester.enterText(usernameField, '123');
    await tester.enterText(passwordField, '1234');

    // Verify that text has been added to the textfield.
    expect(find.text('123'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);
    expect(find.text('1235tjok'), findsNothing);
  });
}
