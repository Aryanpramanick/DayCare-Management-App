//attendance.dart
//Purpose: To allow a worker to take attendance of their assigned children

import 'dart:collection';

import 'package:daycare_mgmt_frontend/activity_class.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/worker_attendance_home-page.dart';
import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/attend_class.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/worker_menubar.dart' as menubar;

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _State();
}

//Worker should be able to complete an attendance
class _State extends State<Attendance> {
  // list of children that are currently absent
  List<Child> checkedOutList =
      childrenList.where((element) => element.present == false).toList();
  //List that holds the default values of the toggle button
  late List<List<bool>> isSelected;

  @override
  void initState() {
    isSelected = List<List<bool>>.generate(
        checkedOutList.length, ((index) => [false, true]));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: ListView.builder(
          itemCount: checkedOutList.length,
          itemBuilder: (context, index) {
            return Card(
                child: Stack(children: <Widget>[
              ListTile(
                  title: Text(
                checkedOutList[index].name,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              )), //displays child name
              Align(
                alignment: Alignment.centerRight,
                child: ToggleButtons(
                    isSelected: isSelected[index],
                    children: const [
                      Icon(Icons.check),
                      Icon(Icons.cancel),
                    ],
                    onPressed: (int newindex) {
                      setState(() {
                        print(index);
                        print(newindex);
                        // newindex is the value of the button that was pressed
                        if (newindex == 0) {
                          // toggling between the buttons to set it to true
                          isSelected[index][0] = true;
                          isSelected[index][1] = false;
                          checkedOutList[index].present = true;
                          checkedOutList[index].attend!.present = true;
                          checkedOutList[index].attend!.time = DateTime.now();
                        } else {
                          isSelected[index][1] = true;
                          isSelected[index][0] = false;
                          checkedOutList[index].present = false;
                          checkedOutList[index].attend!.present = false;
                          checkedOutList[index].attend!.time = DateTime.now();
                        }
                      });
                    }),
              )
            ]));
          }),
      floatingActionButton: FloatingActionButton.extended(
          heroTag: 'submit',
          onPressed: () async {
            loadDialog(context);
            // update the global children list
            for (int i = 0; i < childrenList.length; i++) {
              for (int j = 0; j < checkedOutList.length; j++) {
                if (childrenList[i].id == checkedOutList[j].id) {
                  childrenList[i].present = checkedOutList[j].present;
                  childrenList[i].attend!.present =
                      checkedOutList[j].attend!.present;
                  childrenList[i].attend!.time = checkedOutList[j].attend!.time;
                }
              }
            }

            bool attendsuccess = await postAttendance();
            bool activitysuccess = true;

            if (attendsuccess) {
              //checks for if post request is successful
              // for loop to add check in activities
              print(isSelected);
              for (int i = 0; i < checkedOutList.length; i++) {
                if (checkedOutList[i].present == true) {
                  //create activity for each child that is present
                  bool tempsuccess =
                      await createCheckinActivity(checkedOutList[i]);
                  if (tempsuccess == false) {
                    activitysuccess = false;
                  }
                }
              }
              Navigator.of(context).pop(); // Remove loading dialog

              if (activitysuccess == false) {
                //checks for if adding activites is successful
                popUpDialog(context, popUpDialogType.Error,
                    "Error posting attendance activites", "Unknown error");
              }

              popUpDialog(context, popUpDialogType.Success, "Success",
                  "Attendance Posted");
            } else {
              Navigator.of(context).pop(); // Remove loading dialog
              popUpDialog(context, popUpDialogType.Error,
                  "Error posting attendance", "Unknown error");
            }

            setState(() {
              // checkedOutList = checkedOutList;
              checkedOutList = childrenList
                  .where((element) => element.present == false)
                  .toList();
              isSelected = List<List<bool>>.generate(
                  checkedOutList.length, ((index) => [false, true]));
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => menubar.MenuBar(
                  pageIndex: 1,
                ),
              ),
            );
          },
          label: Text("Save")),
    );
  }

/*
* createCheckinActivity() creates and posts the checkin activity for child
* **NOTE: call this function for all the present children as they are checked in
*/
  Future<bool> createCheckinActivity(Child child) async {
    Activity activity = Activity(
      "Checked In",
      DateTime.now(),
      userId,
      [child],
    );

    bool success = await activity.postActivity();
    checkedActivityFeed.insert(0, activity);
    return success;
  }
}
