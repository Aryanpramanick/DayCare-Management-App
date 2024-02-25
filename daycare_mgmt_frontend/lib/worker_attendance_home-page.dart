//attendance.dart
//Purpose: To allow a worker to take attendance of their assigned children

import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:daycare_mgmt_frontend/activity_class.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/worker_attendance.dart';
import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/attend_class.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

class AttendanceHome extends StatefulWidget {
  const AttendanceHome({super.key});

  @override
  State<AttendanceHome> createState() => _State();
}

//Worker should be able to complete an attendance
class _State extends State<AttendanceHome> {
  //List that holds the default values of the toggle button
  List feed = checkedActivityFeed;
  final DateFormat formatter = DateFormat('hh:mm aa');
  // list of children that are currently present
  List<Child> checkedList =
      childrenList.where((element) => element.present == true).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              'Attendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Text(
                'Checked In',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )),
          checkedList.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Text(
                    'No children checked in!',
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: checkedList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                checkedList[index].name,
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            trailing: TextButton(
                                onPressed: () async {
                                  // update the child's attend object
                                  for (int i = 0;
                                      i < childrenList.length;
                                      i++) {
                                    if (childrenList[i].id ==
                                        checkedList[index].id) {
                                      childrenList[i].present = false;
                                      childrenList[i].attend!.present = false;
                                      childrenList[i].attend!.time =
                                          DateTime.now();
                                      Attend attend =
                                          checkedList[index].attend!;

                                      loadDialog(context);
                                      bool attendsuccess =
                                          await attend.patchAttendance();
                                      await getAttendance(childrenList);
                                      bool activitysuccess =
                                          await createCheckoutActivity(
                                              checkedList[index]);
                                      Navigator.of(context)
                                          .pop(); // Remove loading dialog

                                      if (activitysuccess && attendsuccess) {
                                        //checks for if adding activites is successful
                                        await popUpDialog(
                                            context,
                                            popUpDialogType.Success,
                                            "Success",
                                            "Child was checked out.");
                                      } else {
                                        await popUpDialog(
                                            context,
                                            popUpDialogType.Error,
                                            "Error checking out child",
                                            "Unknown error");
                                      }
                                      break;
                                    }
                                  }
                                  checkedList[index].present = false;
                                  checkedList[index].attend!.present = false;
                                  checkedList[index].attend!.time =
                                      DateTime.now();

                                  setState(() {
                                    checkedList = childrenList
                                        .where((element) =>
                                            element.present == true)
                                        .toList();
                                  });
                                },
                                child: Text('Check out')),
                          ),
                        );
                      }),
                ),
          SizedBox(
            height: 25,
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                'History',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )),
          feed.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Text(
                    'No history yet!',
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: feed.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Text(feed[index].title,
                                          style: TextStyle(fontSize: 30))),
                                  subtitle: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      formatter.format(feed[index].time),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  trailing: Text(
                                      feed[index].makeTaggedStringWorker(),
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.grey)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final value = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Attendance()));
          setState(() {
            checkedList = checkedList;
          });
        },
        label: Text('Take Attendance'),
      ),
    );
  }
}

/*
* createCheckoutActivity: Creates a checkout activity for a child being checked out
*/
Future<bool> createCheckoutActivity(Child child) async {
  Activity activity = Activity(
    "Checked Out",
    DateTime.now(),
    userId,
    [child],
  );

  bool success = await activity.postActivity();
  checkedActivityFeed.insert(0, activity);

  return success;
}
