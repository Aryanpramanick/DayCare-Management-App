import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/worker_attendance_home-page.dart';

void main() {
  testWidgets('Test Attendance HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AttendanceHome()));

    Finder postbutton = find.byType(FloatingActionButton);

    // Verify that the widgets exist.
    expect(postbutton, findsOneWidget);
  });
}
