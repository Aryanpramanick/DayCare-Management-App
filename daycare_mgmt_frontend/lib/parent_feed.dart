//parent_feed.dart
//Purpose: To allow parents to view a feed

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:daycare_mgmt_frontend/image_page.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/video_page.dart';
import 'package:daycare_mgmt_frontend/worker_editactivity.dart';
import 'package:daycare_mgmt_frontend/worker_feed.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/parent_login.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'activity_class.dart';
import 'package:daycare_mgmt_frontend/parent_chatmessages.dart' as m;

import 'auth.dart';

Timer? timerParentFeed;

// for videos in feed
int videoIndex = 0;

class parentFeed extends StatefulWidget {
  const parentFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

//This file should allow parents to view a feed
class _State extends State<parentFeed> {
  // formats time to HH:mm and switched to 12 hour time
  final DateFormat formatter = DateFormat('hh:mm aa');
  List<Activity> feed = todaysActivityFeed;

  @override
  void initState() {
    super.initState();
    // check for new feed items every 30 seconds
    if (timerParentFeed == null) {
      print("starting timer");
      timerParentFeed = Timer.periodic(Duration(seconds: 30), (Timer t) async {
        await get_feed();
        setState(() {
          feed = todaysActivityFeed;
        });
      });
    }
  }

  @override
  void dispose() {
    //get rid of timer
    print("cancelling timer");
    timerParentFeed?.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    print("deactivating parent feed");
    //get rid of timer
    print("cancelling timer");
    timerParentFeed?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: feed.length == 0
            ? ListView(
                children: [
                  Container(
                    width: context.width,
                    height: context.height / 1.3,
                    alignment: Alignment.center,
                    child: Text(
                      "No activities have happened yet today!",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: feed.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            // leading: CircleAvatar(),
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
                            trailing: IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  // if the user has liked the post, make the heart pink
                                  color: feed[index].liked.contains(userId)
                                      ? Colors.pink
                                      : Colors.grey,
                                  size: 40,
                                ),
                                onPressed: () async {
                                  if (feed[index].liked.contains(userId)) {
                                    await feed[index].unlikeActivity(userId);
                                  } else {
                                    await feed[index].likeActivity(userId);
                                  }
                                  setState(() {});
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
                                    feed[index].makeTaggedStringParent(),
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
    timerParentFeed?.cancel();

    try {
      // update feed
      await get_feed();

      //restart timer
      print("starting timer");
      timerParentFeed = Timer.periodic(Duration(seconds: 30), (Timer t) async {
        await get_feed();
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
* get_feed - sends GET request to server at /api/child/{childId}/activities
* for each children in childIds
* this function is called when the page is loaded and every 30 seconds
* it gets the activity feed from the server and updates the todaysActivityFeed list
*/
Future<bool> get_feed() async {
  // for making request
  Dio dio = Dio();

  List<int> activityIds = [];
  List<Activity> activities = [];

  for (int i = 0; i < childIds.length; i++) {
    int childId = childIds[i];
    print("getting feed for child: " + childId.toString());
    try {
      var path =
          'http://' + url + '/api/child/' + childId.toString() + '/activities';
      final response = await dio.get(path,
          options: Options(headers: {'authorization': createAuth()}));
      print(response.statusCode);

      // Check response for success
      if (response.statusCode == 200) {
        //for debugging
        print(response.data);

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
            Child newChild = Child("", id, true, 0);
            await newChild.getChildInfo();
            taggedChildren.add(newChild);
          }

          //get file
          String? filestr;
          if (parsedActivity['file'] != null) {
            filestr = "http://" + url + parsedActivity['file'];
            //for debugging
            // print(filestr);
          }

          // create new activity with title, time, dayCareWorker, and taggedChildren (all required)
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
              newActivity.liked
                  .add(parsedActivity['likedParentID'].elementAt(j));
            }
            newActivity.likedString =
                "Liked by " + newActivity.liked.length.toString();
          }

          // set description
          if (parsedActivity['description'] != null) {
            newActivity.description = parsedActivity['description'];
          }

          // set file str and type if there is a file
          if (parsedActivity['file'] != null) {
            newActivity.filestr = filestr;
            newActivity.filetype = checkFileTypebyString(filestr);
            print("is this a video file? " + newActivity.filetype);
          }

          // add activity to feed if it is from today
          if (newActivity.time.day == DateTime.now().day) {
            // if activity is already in the feed, do not add it again
            if (activityIds.contains(newActivity.id) == false) {
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
  }

  activityFeedIds = activityIds;
  todaysActivityFeed = activities;

  print(activityFeedIds);
  sortActivities(todaysActivityFeed);
  return true;
}
