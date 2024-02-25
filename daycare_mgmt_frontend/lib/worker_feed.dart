//worker_feed.dart
//Purpose: To allow workers to view a feed

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:daycare_mgmt_frontend/image_page.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/video_page.dart';
import 'package:daycare_mgmt_frontend/worker_editactivity.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:daycare_mgmt_frontend/worker_menubar.dart' as menubar;
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/parent_login.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'activity_class.dart';
import 'auth.dart';

Timer? timerWorkerFeed;

class workerFeed extends StatefulWidget {
  const workerFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

//This file should allow parents to view a feed
class _State extends State<workerFeed> {
  // formats time to HH:mm and switched to 12 hour time
  final DateFormat formatter = DateFormat('hh:mm aa');
  List<Activity> feed = todaysActivityFeed;

  // variable and Getter for the photo/video preview
  Widget file = Container();
  Widget fileWidget() {
    return file;
  }

  //called every time page is pushed - new instance, or when setState() is called
  @override
  void initState() {
    super.initState();
    // check for new feed items every 30 seconds
    if (timerWorkerFeed == null) {
      print("starting timer");
      timerWorkerFeed = Timer.periodic(Duration(seconds: 30), (Timer t) async {
        await get_feed(userId);
        setState(() {
          feed = todaysActivityFeed;
        });
      });
    }
  }

  //called when removing page from navigation (such as when pop is called)
  @override
  void dispose() {
    //get rid of timer
    print("cancelling timer");
    timerWorkerFeed?.cancel();
    super.dispose();
  }

  //called when leaving page (like switching menu bar item)
  @override
  void deactivate() {
    print("deactivate worker feed");
    //get rid of timer
    print("cancelling timer");
    timerWorkerFeed?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: feed.length == 0
            ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No activities have happened yet today!",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            //go to addactivity page
                            context,
                            MaterialPageRoute(
                              builder: (context) => const menubar.MenuBar(
                                pageIndex: 3,
                              ),
                            ),
                          );
                        },
                        child: Text("Add one now?"))
                  ],
                ),
              )
            : ListView.builder(
                itemCount: feed.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(feed[index].title,
                                    style: TextStyle(fontSize: 30))),
                            subtitle: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                formatter.format(feed[index].time),
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            trailing: feed[index].title == "Checked In"
                                ? null
                                : IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      try {
                                        //go to edit activity page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditActivity(
                                                      activity: feed[index])),
                                        );
                                      } catch (e) {
                                        print(e);
                                      }
                                    }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: feed[index].description != null &&
                                        feed[index].description != ""
                                    ? Text(
                                        feed[index].description ?? "",
                                        style: TextStyle(
                                            fontSize: 25, color: Colors.grey),
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: feed[index].filetype == 'image'
                                ? GestureDetector(
                                    child: Image.network(
                                      feed[index].filestr!,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'error loading image',
                                          ),
                                        );
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ImageWidget(
                                                  url: feed[index].filestr!,
                                                )),
                                      );
                                    },
                                  )
                                : feed[index].filetype == 'video'
                                    ? GestureDetector(
                                        // show video placeholder image
                                        child: Image.network(
                                          "https://i.imgur.com/wgNuUPc.png",
                                        ),
                                        // play video on tap
                                        onTap: () async {
                                          try {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      VideoWidget(
                                                        url: feed[index]
                                                            .filestr!,
                                                      )),
                                            );
                                          } catch (e) {
                                            print(e);
                                            await popUpDialog(
                                                context,
                                                popUpDialogType.Error,
                                                "Video Player Error",
                                                "Trouble playing video on this device.");
                                          }
                                        },
                                      )
                                    : Container(),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  child: Text(
                                    feed[index].makeTaggedStringWorker(),
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                right: 5, top: 5, bottom: 5, left: 15),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                feed[index].liked.isNotEmpty
                                    ? Icon(
                                        Icons.favorite,
                                        size: 20,
                                        color: Colors.pink,
                                      )
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: feed[index].liked.length > 0
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5,
                                          child: Text(
                                            feed[index].likedString,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
      ),
    );
  }

  /*
  * This function is called when the user pulls down to refresh the feed
  * It cancels the timer, updates the feed, and restarts the timer
  */
  Future<void> _pullRefresh() async {
    // cancel timer so it does not make a request
    print("cancelling timer");
    timerWorkerFeed?.cancel();

    try {
      // update feed
      await get_feed(userId);

      //restart timer
      print("starting timer");
      timerWorkerFeed = Timer.periodic(Duration(seconds: 30), (Timer t) async {
        await get_feed(userId);
        setState(() {
          feed = todaysActivityFeed;
        });
      });

      setState(() {
        feed = todaysActivityFeed;
      });
    } catch (e) {
      print(e);
    }
  }
}

/*
* get_feed - sends GET request to server at /api/worker/{id}/activities
* this function is called when the page is loaded and every 30 seconds
* it gets the activity feed from the server and updates the todaysActivityFeed list
*/
Future<bool> get_feed(int id) async {
  // for making request
  Dio dio = Dio();

  List<int> activityIds = [];
  List<Activity> activities = [];

  try {
    var path = 'http://' + url + '/api/worker/' + id.toString() + '/activities';
    var response = await dio.get(path,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
          'authorization': createAuth()
        }));
    print(response);
    var tries = 0;
    while (response.statusCode != 200 && tries < 3) {
      var response = await dio.get(path,
          options: Options(headers: {
            "Content-Type": "multipart/form-data",
            'authorization': createAuth()
          }));
      tries++;
    }

    // Check response for success
    if (response.statusCode == 200) {
      //for debugging
      // print(response.data);

      // take list of activities and add a new Activity() to activity_feed
      List<dynamic> parsedActivities = response.data;
      int count = parsedActivities.length;
      for (int i = 0; i < count; i++) {
        Map parsedActivity = parsedActivities.elementAt(i);

        //convert list of ids to list of Child
        List<Child> taggedChildren = <Child>[];
        int len = parsedActivity['taggedChildrenID'].length;
        for (int j = 0; j < len; j++) {
          int id = parsedActivity['taggedChildrenID'].elementAt(j);
          Child newChild = Child("", id, true, userId);
          await newChild.getChildInfo();
          taggedChildren.add(newChild);
        }

        // create new Activity with title, time, dayCareWorker, and taggedChildren
        Activity newActivity = Activity(
            parsedActivity['title'],
            DateTime.parse(parsedActivity['time']),
            parsedActivity['dayCareWorker'],
            taggedChildren);

        // set ID
        newActivity.id = parsedActivity['id'];

        // set liked list
        if (parsedActivity['likedParentID'] != null) {
          for (int j = 0; j < parsedActivity['likedParentID'].length; j++) {
            newActivity.liked.add(parsedActivity['likedParentID'].elementAt(j));
          }
          newActivity.likedString = await newActivity.makeLikedStringWorker();
        }

        // set description
        if (parsedActivity["description"] != null) {
          newActivity.description = parsedActivity['description'];
        }

        // set file str and type if there is a file
        if (parsedActivity['file'] != null) {
          //get file
          String? filestr;
          filestr = "http://" + url + parsedActivity['file'];

          newActivity.filestr = filestr;
          newActivity.filetype = checkFileTypebyString(filestr);
          print("is this a video file? " + newActivity.filetype);
        }

        // add activity to feed if it is from today
        if (newActivity.time.day == DateTime.now().day) {
          if (newActivity.title == 'Checked In' ||
              newActivity.title == 'Checked Out') {
            //add check in activities to seperate feed
            checkedActivityFeed.add(newActivity);
          } else {
            activityIds.add(newActivity.id);
            activities.add(newActivity);
          }
        } else {
          //if the activity is not from today, add it to the past activity feed
          pastActivityFeed.add(newActivity);
        }
      }

      //for debugging
      print("successfully got activities for feed");
    } else {
      return false;
    }
  } catch (_) {
    print("Error in get_feed()");
    print(_);
    return false;
  }

  activityFeedIds = activityIds;
  todaysActivityFeed = activities;
  print(todaysActivityFeed);
  // print(activityFeedIds);
  sortActivities(todaysActivityFeed);
  sortActivities(checkedActivityFeed);
  return true;
}

/*
*   This function takes in a list of activities and sorts them based on the time the activity was made
*   returns a list of activities sorted from most recent to least
*/
List<Activity> sortActivities(List<Activity> activities) {
  for (int i = 0; i < activities.length; i++) {
    for (int j = 0; j < activities.length - i - 1; j++) {
      if (activities[j].time.compareTo(activities[j + 1].time) < 0) {
        Activity temp = activities[j];
        activities[j] = activities[j + 1];
        activities[j + 1] = temp;
      }
    }
  }
  return activities;
}
