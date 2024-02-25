import 'package:daycare_mgmt_frontend/auth.dart';
import 'package:daycare_mgmt_frontend/firebasewrapper.dart';
import 'package:daycare_mgmt_frontend/parent_dayplan.dart';
import 'package:daycare_mgmt_frontend/parent_feed.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/parent_login.dart';
import 'package:daycare_mgmt_frontend/parent_messages.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daycare_mgmt_frontend/parent_chatmessages.dart';

class ParentMenuBar extends StatefulWidget {
  final int pageIndex;
  const ParentMenuBar({super.key, required this.pageIndex});

  @override
  State<ParentMenuBar> createState() => _State();
}

class _State extends State<ParentMenuBar> {
  int _menuState = 1;
  final pages = [
    ParentDayPlan(),
    parentFeed(),
    Messages_parent(),
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
              // redirect to login page
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const parentLogin(),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "DayPlan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: "Messages",
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        currentIndex: _menuState,
        onTap: _changeMenuState,
      ),
    );
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
    chatmessages.clear();
    childrenList.clear();
    username = "";
    password = "";

    //dispose of resources
    timerParentFeed?.cancel();

    // TODO: dispose of all widgets

    print("logged out");
  }
}
