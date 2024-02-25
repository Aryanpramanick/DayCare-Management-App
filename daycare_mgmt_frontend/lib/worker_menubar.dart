//menubar.dart
//Purpose: To display a menubar which contains various options

import 'package:daycare_mgmt_frontend/auth.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/firebasewrapper.dart';
import 'package:daycare_mgmt_frontend/worker_addactivity.dart';
import 'package:daycare_mgmt_frontend/worker_dayplan.dart';
import 'package:daycare_mgmt_frontend/worker_messages.dart';
import 'package:daycare_mgmt_frontend/worker_attendance_home-page.dart';
import 'package:daycare_mgmt_frontend/parent_login.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/worker_login.dart';
import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/worker_feed.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuBar extends StatefulWidget {
  final int pageIndex;

  const MenuBar({super.key, required this.pageIndex});

  @override
  State<MenuBar> createState() => _State();
}

class _State extends State<MenuBar> {
  int _menuState = 2;
  final pages = [
    DayPlan(),
    AttendanceHome(),
    workerFeed(),
    AddActivity(),
    Messages_worker(),
  ];
  @override
  void initState() {
    _menuState = widget.pageIndex;
    super.initState();
  }

  void _changeMenuState(int index) {
    setState(() {
      _menuState = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Daycare Management",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: GoogleFonts.indieFlower().fontFamily,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
          leading: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                //redirect to login page
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const workerLogin(),
                  ),
                );
                loadDialog(context);
                logout();
                Navigator.pop(context); //pop the loading dialog
              }),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.settings), onPressed: () {}),
          ],
          backgroundColor: Colors.purple,
        ),
        body: pages[_menuState],
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: "DayPlan"),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_outlined), label: "Attendance"),
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline), label: "AddActivity"),
            BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined), label: "Messages"),
          ],
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          currentIndex: _menuState,
          onTap: _changeMenuState,
        ));
  }

  logout() {
    //reset globals
    FirebaseWrapper().disposeFirebase();

    isLoggedIn = false;
    userId = 0;
    userType = "";
    todaysActivityFeed.clear();
    activityFeedIds.clear();
    items.clear();
    childrenList.clear();
    todaysItems.clear();
    chatmessages.clear();

    username = "";
    password = "";

    //dispose of resources
    timerWorkerFeed?.cancel();
    if (videoController != null) {
      print("disposing");
      videoController!.dispose();
    }

    // TODO: dispose of all widgets

    print("logged out");
  }
}
