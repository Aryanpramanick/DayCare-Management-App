import 'package:daycare_mgmt_frontend/dayplanItem_class.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/worker_add_dayplan_inputfield.dart';
import 'package:daycare_mgmt_frontend/worker_dayplan.dart';
import 'package:daycare_mgmt_frontend/worker_dayplan_controller.dart';
import 'package:daycare_mgmt_frontend/worker_dayplan_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:daycare_mgmt_frontend/worker_menubar.dart' as menubar;

DateTime now = DateTime.now();

class addDayplan extends StatefulWidget {
  const addDayplan({Key? key}) : super(key: key);

  @override
  State<addDayplan> createState() => _addDayplanState();
}

// add dayplan items to the dayplan page
class _addDayplanState extends State<addDayplan> {
  final _formkey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _startTime = DateFormat('hh:mm a').format(now).toString();
  String _endTime =
      DateFormat('hh:mm a').format(now.add(Duration(hours: 1))).toString();
  int _selectedColor = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formkey,
        child: Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Add activity to dayplan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  MyInputField(
                      title_d: "* Title",
                      hint_d: "Enter your title",
                      controler: _titleController),
                  MyInputField(
                      title_d: "* Note",
                      hint_d: "Enter your note",
                      controler: _noteController),
                  MyInputField(
                    title_d: "* Date",
                    hint_d: DateFormat.yMd().format(_selectedDate),
                    widget_d: IconButton(
                      icon: Icon(Icons.calendar_today_outlined,
                          color: Colors.grey),
                      onPressed: () {
                        _getDateFromUser();
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MyInputField(
                          title_d: "* Start Time",
                          hint_d: _startTime,
                          widget_d: IconButton(
                            icon: Icon(Icons.access_time_rounded,
                                color: Colors.grey),
                            onPressed: () {
                              _getTimeFromUser(isStarTime: true);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: MyInputField(
                          title_d: "* End Time",
                          hint_d: _endTime,
                          widget_d: IconButton(
                            icon: Icon(Icons.access_time_rounded,
                                color: Colors.grey),
                            onPressed: () {
                              _getTimeFromUser(isStarTime: false);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _colorPalette(),
                      GestureDetector(
                        onTap: () async {
                          if (_formkey.currentState!.validate()) {
                            _validateData();
                          }
                        },
                        child: Container(
                            width: 120,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF4e5ae8),
                            ),
                            child: Center(
                              child: Text("Create Activity",
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

/* 
* _validateData: checks if the data is valid for all input fields 
*/
  _validateData() async {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      await _addTaskToDb();
      await getItemsByWorker(
          userId, DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => menubar.MenuBar(
            pageIndex: 0,
          ),
        ),
      );
    } else if (_titleController.text.isEmpty) {
      popUpDialog(
          context, popUpDialogType.Error, "Required", "Title is required");
    } else if (_noteController.text.isEmpty) {
      popUpDialog(
          context, popUpDialogType.Error, "Required", "Note is required");
    }
  }

/*
 * _addTaskToDb() - creates a new dayplan item and adds it to the database
 */
  _addTaskToDb() async {
    dayplanitem = DayplanItem(
      _titleController.text,
      _noteController.text,
      DateFormat('yyyy-MM-dd').format(_selectedDate).toString(),
      twentyfourhourS(_startTime),
      twentyfourhourE(_endTime),
      userId,
      _selectedColor,
    );
    await dayplanitem.postDayplanItem();
  }

// color palette for the dayplan items
  _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style: titleStyle,
        ),
        SizedBox(
          height: 8,
        ),
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: index == 0
                      ? primaryColor
                      : index == 1
                          ? pinkColor
                          : yellowColor,
                  radius: 12,
                  child: _selectedColor == index
                      ? Icon(Icons.done, color: Colors.white, size: 16)
                      : Container(),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

// get the date from the user
  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2121));
    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
        print(_selectedDate);
      });
    }
  }

// get the time from the user
  _getTimeFromUser({required bool isStarTime}) async {
    var pickedTime = await _showTimePicker();

    if (pickedTime == null) {
      print("No time selected");
    } else if (isStarTime == true) {
      setState(() {
        String _formatedTime = pickedTime.format(context);
        _startTime = _formatedTime;
      });
    } else if (isStarTime == false) {
      setState(() {
        String _formatedTime = pickedTime.format(context);
        _endTime = _formatedTime;
      });
    }
  }

// show the time picker
  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(":")[0]),
        minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
      ),
    );
  }
}
