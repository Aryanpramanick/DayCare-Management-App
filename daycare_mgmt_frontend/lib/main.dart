import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/parent_login.dart' as parent_login_page;
import 'package:daycare_mgmt_frontend/worker_addactivity.dart'
    as add_activity_page;
import 'package:daycare_mgmt_frontend/parent_feed.dart' as parent_feed_page;
import 'package:daycare_mgmt_frontend/parent_chatmessages.dart' as message;
import 'package:daycare_mgmt_frontend/worker_attendance_home-page.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Main Function
void main() {
  runApp(const MaterialApp(home: parent_login_page.parentLogin()));

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();
}
