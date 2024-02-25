import 'dart:io';

import 'package:daycare_mgmt_frontend/activity_class.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/worker_feed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("unit testing", () {
    test("sortActivities: one activity", () {
      Activity activty1 = Activity(
          "Dayplan item", DateTime.now(), 1, [Child("name", 1, false, 0)]);

      List<Activity> activities = [activty1];
      List<Activity> expected = [activty1];

      expect(sortActivities(activities), expected);
    });
    test("sortActivities: multiple activity", () {
      Activity activty1 = Activity(
          "Dayplan item", DateTime.now(), 1, [Child("name", 1, false, 0)]);
      sleep(Duration(seconds: 3));
      Activity activty2 = Activity(
          "Dayplan item", DateTime.now(), 1, [Child("name", 1, false, 0)]);
      sleep(Duration(seconds: 3));
      Activity activty3 = Activity(
          "Dayplan item", DateTime.now(), 1, [Child("name", 1, false, 0)]);

      List<Activity> activities = [activty1, activty3, activty2];
      List<Activity> expected = [activty3, activty2, activty1];

      expect(sortActivities(activities), expected);
    });
  });

  group("widget testing", () {});
}
