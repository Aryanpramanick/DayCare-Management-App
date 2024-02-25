//attend_class.dart
//Purpose: Attend Class
//  * deals with storing data relating to the attendance status of a child

import 'package:daycare_mgmt_frontend/worker_login.dart';
import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';

import 'package:daycare_mgmt_frontend/activity_class.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
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
import 'dart:collection';

import 'package:intl/intl.dart';

import 'auth.dart';

class Attend {
  int id;
  int childID;
  int workerID;
  bool present;
  DateTime time;

  Attend(this.id, this.childID, this.workerID, this.time, this.present);

  Future<bool> patchAttendance() async {
    //for making request
    Dio dio = Dio();

    // create a map to send in the patch request
    Map<String, dynamic> map = {'time': time.toString(), 'present': present};

    try {
      var path = 'http://' + url + '/api/attendance/' + id.toString();
      var response = await dio.patch(path,
          data: map,
          options: Options(headers: {
            "Content-Type": "application/json",
            'authorization': createAuth()
          })); // patch request

      // Check response for success
      if (response.statusCode == 200) {
        //for debugging
        print('Successfully patched attendance' + id.toString());
      } else {
        //for debugging
        print(response.statusCode);
        return false;
      }
    } catch (_) {
      print("Error in patchAttendance()");
      print(_);
      return false;
    }
    return true;
  }
}

/*
   * postAttendance() checks if the attendance exists already then
   *   if it does not exist, it creates a new attendance object and 
   *  sends a post request to add it to the database
   *  if it does exist, it sends a patch request to update the attendance object
   * returns: 
   *    true if the request recieves a successful response
   *    false if the request recieves an unsuccessful response
   */
Future<bool> postAttendance() async {
  //for making request
  Dio dio = Dio();

  List<Map> attendance = [];
  Map<String, dynamic> map = new HashMap();

  // creates a map to send in the post request
  for (int i = 0; i < childrenList.length; i++) {
    // create a new attend object
    Attend attend = childrenList[i].attend!;
    // set the current time and present status
    attend.time = DateTime.now();
    attend.present = childrenList[i].present;

    // update attend object in the child object
    childrenList[i].attend = attend;

    if (attend.id == 0) {
      // if the attend object has not been added to the database yet
      // send a post request to add it to the database
      map = {
        'worker': attend.workerID,
        'child': attend.childID,
        'time': attend.time.toString(),
        'present': attend.present
      };
      attendance.add(map);
    } else {
      // if the attend object has already been added to the database
      // send a patch request to update it in the database
      await attend.patchAttendance();
    }
  }

  //FormData? activity_data = FormData.fromMap(attendance);
  print(attendance.toString());

  try {
    var path = 'http://' + url + '/api/attendance';
    var response = await dio.post(path,
        data: attendance,
        options: Options(headers: {
          "Content-Type": "application/json",
          'authorization': createAuth()
        })); // post request

    // Check response for success
    if (response.statusCode == 201) {
      //for debugging
      print('Successfully posted attendance');
    } else {
      //for debugging
      print(response.statusCode);
      await getAttendance(childrenList);
      return false;
    }
  } catch (_) {
    print("Error in postAttendance()");
    print(_);
    await getAttendance(childrenList);
    return false;
  }
  await getAttendance(childrenList);
  return true;
}

/*
* getAttendance() gets the attendance data from the backend
*    and stores it in the childrenList
* returns:
*    true if the request recieves a successful response
*    false if the request recieves an unsuccessful response
*/
Future<bool> getAttendance(List<Child> children) async {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  Dio dio = Dio();

  try {
    var path = 'http://' +
        url +
        '/api/attendance/' +
        userId.toString() +
        '/' +
        formatter.format(DateTime.now());
    var response = await dio.get(path,
        options: Options(headers: {'authorization': createAuth()}));

    if (response.statusCode == 200) {
      List<dynamic> parsedAttendance = response.data;

      for (int i = 0; i < parsedAttendance.length; i++) {
        Map item = parsedAttendance.elementAt(i);

        // create new attend with id, child, worker, time, and present
        Attend attend = Attend(
          item['id'],
          item['child'],
          item['worker'],
          DateTime.parse(item['time']),
          item['present'],
        );

        // if date is not today then skip
        if (attend.time.day != DateTime.now().day) {
          continue;
        }

        // add attend to childrenList
        for (int c = 0; c < childrenList.length; c++) {
          if (childrenList[c].id == attend.childID) {
            childrenList[c].attend = attend;
            if (attend.present == true) {
              childrenList[c].present = true;
            } else {
              childrenList[c].present = false;
            }
          }
        }
      }

      print('Attendance Success');

      return true;
    } else {
      print('Error in getting attendance');
      return false;
    }
  } catch (_) {
    print('Error in getAttendance()');
    print(_);
    return false;
  }
}
