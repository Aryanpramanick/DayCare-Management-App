import 'dart:io';

import 'package:daycare_mgmt_frontend/worker_addactivity.dart' as addActivity;
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daycare_mgmt_frontend/globals.dart';

void main() {
  group('unit testing', () {
    test(
        'checkChildPermissionsTest: Multiple children are selected, one cannot share',
        () {
      Child anna = Child("Anna", 3, false, 0);
      List<Child> childrenList = [
        Child("Billy", 1, true, 0),
        Child("Sally", 2, true, 0),
        anna,
      ];

      List<Child> cannotShare = addActivity.checkChildPermissions(childrenList);

      expect(cannotShare, [anna]);
    });
    test('checkChildPermissionsTest: One child is selected without permissions',
        () {
      Child anna = Child("Anna", 3, false, 0);
      List<Child> childrenList = [
        anna,
      ];

      List<Child> cannotShare = addActivity.checkChildPermissions(childrenList);

      expect(cannotShare, []);
    });
    test('checkFileTypeTest: file is null', () {
      File? file;

      String type = addActivity.checkFileTypebyFile(file);

      expect(type, "null");
    });
    test('checkFileTypeTest: file is image', () {
      File file =
          File("daycare_mgmt_frontend\test\sample_media\layered-archi.png");
      String type = addActivity.checkFileTypebyFile(file);

      expect(type, "image");
    });
    test('checkFileTypeTest: file is video', () {
      File file = File(
          "daycare_mgmt_frontend\test\sample_media\Sample-MP4-Video-File-for-Testing.mp4");
      String type = addActivity.checkFileTypebyFile(file);

      expect(type, "video");
    });
  });
  //TODO: create a Test user for these tests
  group('widget tests', () {
    setUp(() {
      userId = 1;
      userType = "worker";
      childIds = [1];
    });
    testWidgets('addActivityTest: dayplan dropdown widget', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const addActivity.AddActivity());
      Finder dayplanDropdown = find.byKey(const Key('dayplanDropdown'));

      // Verify that the widget exists
      expect(dayplanDropdown, findsOneWidget);

      // Open the dropdown menu
      await tester.tap(dayplanDropdown);
      await tester.pumpAndSettle();
      final dropdownItem = find.text('DayPlan Item 1').first;

      // Tap on an item
      await tester.tap(dropdownItem);
      await tester.pumpAndSettle();
    });
    testWidgets('addActivityTest: description widget', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const addActivity.AddActivity());
      Finder descriptionField = find.byKey(const Key('description'));

      // Verify that the widget exists
      expect(descriptionField, findsOneWidget);

      // Edit text into the textfield.
      await tester.enterText(descriptionField, 'description blah blah');

      // Verify that text has been added to the textfield.
      expect(find.text('description blah blah'), findsOneWidget);
      expect(find.text('description not blah blah'), findsNothing);
    });
    testWidgets('addActivityTest: tagChildrenSelect widget', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const addActivity.AddActivity());
      Finder tagChildrenSelect =
          find.byKey(const Key('tagChildrenSelect')).last;

      // Verify that the widget exists
      expect(tagChildrenSelect, findsOneWidget);

      // Open the multiselect
      await tester.tap(tagChildrenSelect);
      await tester.pumpAndSettle();
      final cancelButton = find.text('CANCEL');

      // Tap on the cancel button
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
    });
    testWidgets('addActivityTest: button widgets', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const addActivity.AddActivity());
      Finder openCameraButton = find.byKey(const Key('openCameraButton'));
      Finder openGalleryButton = find.byKey(const Key('openGalleryButton'));
      Finder addActivityButton = find.byKey(const Key('addActivityButton'));

      // Verify that the widgets exist
      expect(openCameraButton, findsOneWidget);
      expect(openGalleryButton, findsOneWidget);
      expect(addActivityButton, findsOneWidget);
    });
  });
}
