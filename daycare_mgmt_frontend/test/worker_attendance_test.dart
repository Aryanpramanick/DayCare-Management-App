import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/worker_attendance.dart';

void main() {
  testWidgets('Test Attendance', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Attendance()));

    Finder savebutton = find.byType(FloatingActionButton);

    // Verify that the widgets exist.
    expect(savebutton, findsOneWidget);
  });
}
