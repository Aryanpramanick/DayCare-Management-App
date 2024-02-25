//dayplan.dart
//Purpose: To allow a worker to display a child's dayplan which a parent can view

import 'package:daycare_mgmt_frontend/dayplanItem_class.dart';
import 'package:daycare_mgmt_frontend/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'globals.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:daycare_mgmt_frontend/worker_add_dayplan.dart';
import 'package:daycare_mgmt_frontend/worker_dayplan_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DayPlan extends StatefulWidget {
  const DayPlan({super.key});

  @override
  State<DayPlan> createState() => _State();
}

class _State extends State<DayPlan> {
  List<DayplanItem> items_dayplan = items;
  @override
  void initState() {
    items_dayplan = items;
    super.initState();
  }

  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _addTaskBar(),
          SizedBox(
            height: 10,
          ),
          _addDateBar(),
          SizedBox(
            height: 10,
          ),
          _showDayPlan(),
        ],
      ),
    );
  }

// Displays the list of dayplan items for the selected date added by the worker
  _showDayPlan() {
    return Expanded(
      flex: int.parse(items_dayplan.length.toString()),
      child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items_dayplan.length,
          itemBuilder: (context, index) {
            DayplanItem day_p = items_dayplan[index];
            if (day_p.date ==
                DateFormat('yyyy-MM-dd').format(_selectedDate).toString()) {
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            print("tapped");
                          },
                          child: TaskTile(day_p))
                    ],
                  ))));
            } else {
              return Container();
            }
          }),
    );
  }

// added the scrollable calender to select a date and get the dayplan items for that date
  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: Color(0xFF4e5ae8),
        selectedTextColor: Colors.white,
        dateTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        dayTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        monthTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        onDateChange: (date) async {
          await getItemsByWorker(
              userId, DateFormat('yyyy-MM-dd').format(date).toString());
          setState(() {
            _selectedDate = date;
            items_dayplan = items;
          });

          // New date selected
        },
      ),
    );
  }

// takes to the add dayplan page to add a new dayplan item
  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text("Today", style: HeadingStyle),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return addDayplan();
                }),
              );
            },
            child: Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF4e5ae8),
                ),
                child: Center(
                  child: Text("Add Activity",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                )),
          ),
        ],
      ),
    );
  }
}

/*
* getItemsByWorker - sends GET request to server at /api/dayplan/<worker_id>/<date>
* server response contains a list of dayplanItems for the current date
* will also update the globals variable dayplanItems
*   returns true if successful
*   returns false if unsuccessful
*/
Future<bool> getItemsByWorker(worker_id, date) async {
  List<String> itemsTitles = [];
  List<DayplanItem> items_D = [];

  //send GET request to server
  try {
    final httpPackageUrl = Uri.http(url, '/api/dayplan/$worker_id/$date');
    var httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': createAuth()});

    var tries = 0;
    while (httpPackageResponse.statusCode != 200 && tries < 5) {
      print("Retrying getItemsByWorker()");
      httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': createAuth()});
      tries++;
    }

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      //for debugging
      print(httpPackageResponse.body);

      // take list of dayplan items and add a new DayplanItem() to the list
      List<dynamic> parsedItems = jsonDecode(httpPackageResponse.body);
      int count = parsedItems.length;
      for (int i = 0; i < count; i++) {
        Map parsedItem = parsedItems.elementAt(i);
        items_D.add(DayplanItem(
          parsedItem['title'],
          parsedItem['note'],
          parsedItem['date'],
          parsedItem['startTime'],
          parsedItem['endTime'],
          parsedItem['dayCareWorker'],
          parsedItem['tabColor'],
        ));
        itemsTitles.add(parsedItem['title']);
      }
    } else {
      print(httpPackageResponse.statusCode);
      return false;
    }
  } catch (_) {
    print("Error in getItemsByWorker()");
    print(_);
    return false;
  }

  //only update todaysItems if the date is today
  if (date == DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()) {
    //update globals variable for todaysItems - used in dropdown menu for adding new activity
    todaysItems = itemsTitles;
  }
  items = items_D;
  return true;
}
