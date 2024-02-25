//globals.dart
//Purpose: To store variables which would be used throughout the session

import 'dart:io';
import 'package:daycare_mgmt_frontend/activity_class.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/parent_class.dart';
import 'package:daycare_mgmt_frontend/worker_class.dart';
import 'dayplanItem_class.dart';
import 'package:daycare_mgmt_frontend/message_class.dart';

// CYBERA IPV6 ADDRESS FOR SERVER
String url = "[2605:fd00:4:1001:f816:3eff:feb2:1cf7]:80"; // new
// String url = "[2605:fd00:4:1001:f816:3eff:fe37:cbdf]:80"; // old

// GLOBAL VARIABLES FOR LOGIN
bool isLoggedIn = false;
late String userType; // late initialization

// GLOBAL VARIABLES FOR USERS
int userId = 0; //parent or worker id
int uid = 0; //user id
int sender_uid = 0; // sender user id
String sender_name = ""; // sender name
List<int> childIds = [0]; //child id for parent
DayplanItem dayplanitem = DayplanItem('', '', '', '', '', userId, 0);
//list of children for parent or worker depending on userType
List<Child> childrenList = [];

// GLOBAL VARIABLES FOR ADD ACTIVITY
List<String> todaysItems = [];
File? fileBuffer;
File placeholder = File("video-placeholder.jpg");

// GLOBAL VARIABLES FOR MESSAGES
late List<Parent> parent_name; //list of parents names to appear in message page
late List<Worker> worker_name; //list of workers names to appear in message page
late List<Message> chatmessages = <Message>[];
late Message des_p = Message(
    text: "Click to chat for the first time!",
    date: DateTime.now().toString(),
    sender: uid,
    receiver: sender_uid); //message preview for message page

late String token; //token for firebase messaging

// GLOBAL VARIABLES FOR FEED
List<Activity> todaysActivityFeed = []; //starts as empty
List<int> activityFeedIds = []; //starts as empty
// this is for future use if want to add feature to show past activities
List<Activity> pastActivityFeed = []; //starts as empty

// GLOBAL VARIABLES FOR ATTENDANCE
List<Activity> checkedActivityFeed = []; //starts as empty

// GLOBAL VARIABLES FOR DAYPLAN
List<String> childList = []; // list of childrens names for dropdown
List<DayplanItem> items =
    []; // list of dayplan items that appears in current page (date)
