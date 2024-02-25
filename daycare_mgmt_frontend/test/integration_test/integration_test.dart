import 'dart:io';

import 'package:daycare_mgmt_frontend/worker_addactivity.dart' as addActivity;
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

void main() {
  group('addActivity tests', () {
    setUp(() {
      userId = 1;
      userType = 'worker';
      List<Child> childrenList = [
        Child('Child 1', 1, true, 0),
        Child('Child 2', 2, false, 0)
      ];
    });
    testWidgets("post new activity with no input", (tester) async {
      await tester.pumpWidget(const addActivity.AddActivity());

      Finder descriptionField = find.byKey(const Key('description'));
      Finder dayplanDropdown = find.byKey(const Key('dayplanDropdown'));
      Finder addActivityButton = find.byKey(const Key('addActivityButton'));

      await tester.tap(dayplanDropdown);
      await tester.pumpAndSettle();
      final dropdownItem = find.text('DayPlan Item 1').first;
      await tester.tap(dropdownItem);
      await tester.pumpAndSettle();

      await tester.enterText(descriptionField, 'description blah blah');

      Finder tagChildrenSelect =
          find.byKey(const Key('tagChildrenSelect')).last;
      await tester.tap(tagChildrenSelect);
      await tester.pumpAndSettle();
      final child =
          find.widgetWithText(tagChildrenSelect.runtimeType, "Child 1");
      await tester.tap(child);
      await tester.pumpAndSettle();
      Finder okButton = find.text('OK');
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      await tester.tap(addActivityButton);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
