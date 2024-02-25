import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/parent_chatmessages.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  testWidgets('Test ChatMessage UI', (WidgetTester tester) async {
    await tester.pumpWidget(const ParentChatMessages());

    Finder messageField = find.byKey(const Key('message'));
    Finder sendButton = find.byKey(const Key('send'));

    // Verify that the widgets exist.
    expect(messageField, findsOneWidget);
    expect(sendButton, findsOneWidget);

    // Edit text into the textfield.
    await tester.enterText(messageField, 'hey');

    // Emulate a tap
    await tester.tap(sendButton);

    // Trigger a frame.
    await tester.pumpAndSettle();

    // Verify message appeared
    expect(find.text('hey'), findsNWidgets(2));
  });
}
