import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/worker_Login.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // NEW

  testWidgets('worker login', (tester) async {
    await tester.pumpWidget(MaterialApp(home: workerLogin()));

    Finder usernameField = find.byKey(const Key('username'));
    Finder passwordField = find.byKey(const Key('password'));
    Finder sendButton = find.byKey(const Key('login'));

    // Verify that widgets exist
    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(sendButton, findsOneWidget);

    // Edit text into the textfield.
    await tester.enterText(usernameField, 'workerDemo1');
    await tester.enterText(passwordField, 'abc');

    // Emulate a tap
    await tester.tap(sendButton);

    // Trigger a frame.
    await tester.pumpAndSettle();

    //check if login fails
    expect(isLoggedIn, false);

    //check if text got deleted
    expect(find.text('workerDemo1'), findsNothing);
    expect(find.text('abc'), findsNothing);
  });
}
