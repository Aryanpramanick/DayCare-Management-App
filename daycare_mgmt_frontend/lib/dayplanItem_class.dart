import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'globals.dart';
import 'package:flutter/material.dart';

class DayplanItem {
  String title;
  String note;
  String date; // YYYY-MM-DD
  String startTime; // HH:MM needs to be 24 hour time
  String endTime; // HH:MM needs to be 24 hour time
  int workerId;
  int tabColor;

  DayplanItem(this.title, this.note, this.date, this.startTime, this.endTime,
      this.workerId, this.tabColor);

  /*
    * postDayplanItem - sends a POST request to /api/dayplan to 
    *   add the new dayplan item to database
    * returns: 
    *    true if the request recieves a successful response
    *    false if the request recieves an unsuccessful response
    *
  */
  postDayplanItem() async {
    Map<String, dynamic> data = {
      'title': title,
      'note': note,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'dayCareWorker': workerId,
      'tabColor': tabColor,
    };
    var body = json.encode(data);

    //for debugging
    print(body);

    try {
      final httpPackageUrl = Uri.http(url, '/api/dayplan');
      final httpPackageResponse = await http.post(httpPackageUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'authorization': createAuth()
          },
          body: body);

      if (httpPackageResponse.statusCode == 201) {
        print("Dayplan item posted successfully");
        print(httpPackageResponse.body);
      } else {
        print(httpPackageResponse.statusCode);
        return false;
      }
    } catch (_) {
      print("Error in postDayplanItem()");
      print(_);
      return false;
    }
    return true;
  }
}

Color primaryColor =
    Color(0xFF4e5ae8); // color palette for adding dayplan items
Color pinkColor =
    Color.fromARGB(255, 255, 7, 81); // color palette for adding dayplan items
Color yellowColor =
    Color.fromARGB(255, 175, 132, 2); // color palette for adding dayplan items