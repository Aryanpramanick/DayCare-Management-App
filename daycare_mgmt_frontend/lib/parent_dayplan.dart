//dayplan.dart
//Purpose: To allow a worker to display a child's dayplan which a parent can view

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:daycare_mgmt_frontend/dayplanItem_class.dart';
import 'package:daycare_mgmt_frontend/task_tile.dart';
import 'package:daycare_mgmt_frontend/worker_dayplan_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'auth.dart';
import 'child_class.dart';
import 'globals.dart';

class ParentDayPlan extends StatefulWidget {
  const ParentDayPlan({super.key});

  @override
  State<ParentDayPlan> createState() => _State();
}

class _State extends State<ParentDayPlan> {
  List<DayplanItem> items_dayplan = items;
  String dropdownValue = childList.first;
  int worker_dayplan_id = childrenList.first.wid;

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
          await getItemsByWorkerr(worker_dayplan_id,
              DateFormat('yyyy-MM-dd').format(date).toString());
          setState(() {
            _selectedDate = date;
            items_dayplan = items;
          });

          // New date selected
        },
      ),
    );
  }

  // Displays the child's name and the date selected
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
          // added a dropdown button to select a child
          DropdownButton(
            value: dropdownValue,
            icon: Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: TextStyle(color: Colors.purple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            items: childList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) async {
              for (int i = 0; i < childrenList.length; i++) {
                if (childrenList[i].name == value) {
                  worker_dayplan_id = childrenList[i].wid;
                }
              }
              await getItemsByWorkerr(worker_dayplan_id,
                  DateFormat('yyyy-MM-dd').format(_selectedDate).toString());
              setState(() {
                dropdownValue = value!;
                items_dayplan = items;
              });
            },
          ),
        ],
      ),
    );
  }
}

/* getItemsByWorker - sends GET request to server at /api/dayplan/<worker_id>/<date>
* server response contains a list of dayplanItems for the current date
*   returns true if successful
*   returns false if unsuccessful
*/
Future<bool> getItemsByWorkerr(worker_id, date) async {
  List<DayplanItem> item = [];

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
        item.add(DayplanItem(
            parsedItem['title'],
            parsedItem['note'],
            parsedItem['date'],
            parsedItem['startTime'],
            parsedItem['endTime'],
            parsedItem['dayCareWorker'],
            parsedItem['tabColor']));
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
  items = item;
  return true;
}

/* getChildList - sends GET request to server at /api/parent/<parent_id>/children
* server response contains a list of children for the current parent
*   sets childList to list of children's names and childrenList to list of children
*   returns true if successful
*   returns false if unsuccessful
*/
Future<bool> getChildList(int id) async {
  List<String> c_list = [];
  try {
    final httpPackageUrl =
        Uri.http(url, '/api/parent/' + id.toString() + '/children');
    final httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': createAuth()});

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      print('Successfully got child id');

      List<dynamic> parsedChildren = jsonDecode(httpPackageResponse.body);
      // lopp through children and add each id to childIds
      for (int i = 0; i < parsedChildren.length; i++) {
        Map parsedChild = parsedChildren[i];
        c_list.add(parsedChild["firstname"]);
        childrenList.add(Child(parsedChild["firstname"], parsedChild["id"],
            parsedChild["share_permissions"], parsedChild["dayCareWorker"]));
      }
    } else {
      print(httpPackageResponse.body);
      return false;
    }
  } catch (_) {
    print("Error in getChildId()");
    print(_);
    return false;
  }
  childList = c_list;
  return true;
}
