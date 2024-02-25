import 'dart:io';

import 'package:daycare_mgmt_frontend/activity_class.dart' as activityClass;
import 'package:daycare_mgmt_frontend/child_class.dart' as childClass;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unit testing', () {
    test('Activity is created with file and description as null', () {
      DateTime time = DateTime.now();
      List<childClass.Child> childrenList = [
        childClass.Child('Child 1', 1, true, 0),
        childClass.Child('Child 2', 2, true, 0)
      ];

      activityClass.Activity activity =
          activityClass.Activity("type", time, 1, childrenList);

      expect(activity.time, time);
      expect(activity.file, null);
      expect(activity.description, null);
      expect(activity.tagged, childrenList);
    });
    test('Activity is created with image and description not null', () {
      DateTime time = DateTime.now();
      List<childClass.Child> childrenList = [
        childClass.Child('Child 1', 1, true, 0),
        childClass.Child('Child 2', 2, true, 0)
      ];
      File sample =
          File("daycare_mgmt_frontend\test\sample_media\layered-archi.png");

      activityClass.Activity activity =
          activityClass.Activity("type", time, 1, childrenList);
      activity.file = sample;
      activity.description = "description";

      expect(activity.time, time);
      expect(activity.file == null, false);
      expect(activity.file, sample);
      expect(activity.description, "description");
      expect(activity.tagged, childrenList);
    });
    test('makeTaggedString: one child', () {
      DateTime time = DateTime.now();
      List<childClass.Child> childrenList = [
        childClass.Child('Child 1', 1, true, 0)
      ];
      activityClass.Activity activity =
          activityClass.Activity("type", time, 1, childrenList);

      expect(activity.makeTaggedStringWorker(), "Child 1");
    });
    test('makeTaggedString: multiple children', () {
      DateTime time = DateTime.now();
      List<childClass.Child> childrenList = [
        childClass.Child('Child 1', 1, true, 0),
        childClass.Child('Child 2', 2, true, 0)
      ];
      activityClass.Activity activity =
          activityClass.Activity("type", time, 1, childrenList);

      expect(activity.makeTaggedStringWorker(), "Child 1, Child 2");
    });
  });
}
