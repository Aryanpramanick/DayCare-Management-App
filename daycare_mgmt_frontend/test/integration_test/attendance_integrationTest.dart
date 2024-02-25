import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/worker_attendance.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // NEW

  testWidgets('attendance', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Attendance()));

    Finder checkField = find.byIcon(Icons.check);
    Finder sendButton = find.byType(FloatingActionButton);

    // Verify that widgets exist
    expect(checkField, findsOneWidget);
  });
}
