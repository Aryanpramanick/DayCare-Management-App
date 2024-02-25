//messages.dart
//Purpose: To allow a worker and parent to message each other

import 'dart:async';
import 'dart:convert';
import 'package:daycare_mgmt_frontend/firebasewrapper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/parent_feed.dart' as pf;
import 'package:daycare_mgmt_frontend/globals.dart' as globals;
import 'package:daycare_mgmt_frontend/parent_menubar.dart' as menubar;
import 'package:daycare_mgmt_frontend/parent_login.dart';
import 'package:daycare_mgmt_frontend/parent_messages.dart';
import 'package:daycare_mgmt_frontend/worker_chatmessages.dart';
import 'package:daycare_mgmt_frontend/message_class.dart';
import 'auth.dart';
import 'globals.dart';

List<Message> messages = [];

class ParentChatMessages extends StatefulWidget {
  const ParentChatMessages({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ParentChatMessages> implements CallBackInterface {
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _scroll = true;

  @override
  void initState() {
    super.initState();
    FirebaseWrapper().registerCallback(this);
  }

  @override
  void dispose() {
    debugPrint("dispose");
    FirebaseWrapper().unregisterCallback(this);
    super.dispose();
  }

  @override
  void update() async {
    await get_pchat();
    setState(() {
      _scroll = true;
    });
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_scroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown());
      _scroll = false;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(sender_name),
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await get_worker();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => menubar.ParentMenuBar(
                    pageIndex: 2,
                  ),
                ),
              );
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              reverse: true,
              child: ListView.builder(
                itemCount: messages.length,
                shrinkWrap: true,
                controller: _scrollController,
                padding: EdgeInsets.only(top: 10, bottom: 60),
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                        alignment: (messages[index].sender == sender_uid
                            ? Alignment.topLeft
                            : Alignment.topRight),
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: (messages[index].sender == sender_uid
                                  ? Colors.grey.shade200
                                  : Colors.blue[200]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              child: Text(messages[index].text),
                              padding: EdgeInsets.all(10),
                            ))),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(10),
                height: 60,
                width: double.infinity,
                color: Color.fromARGB(255, 223, 152, 236),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        key: Key('message'),
                        controller: messageController,
                        decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    TextButton(
                      onPressed: () async {
                        Message NewMessage = Message(
                          text: messageController.text,
                          date: DateTime.now().toString(),
                          sender: uid,
                          receiver: sender_uid,
                        );
                        await post_pmessage(NewMessage);
                        await get_pchat();
                        setState(() {
                          messageController.clear();
                        });
                      },
                      child: const Text('Send',
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

post_pmessage(NewMessage) async {
  try {
    final httpPackageUrl = Uri.http(url, 'api/message');
    Map data = {
      'content': NewMessage.text,
      'sender': uid,
      'receiver': sender_uid,
    };
    print(jsonEncode(data));
    final httpPackageResponse = await http.post(httpPackageUrl,
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          'authorization': createAuth()
        });

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      print("successfully posted message");
    } else {
      print("failed to post message");
    }
  } catch (_) {
    print(_);
    print("Error connecting to server in get_feed()");
  }
}

/*
* get_pchat - sends GET request to server at /api/messages_between/{user_id}/{s_user_id}
* server response contains a list of messages between the parent and the worker
*   returns true if successful
*   returns false if unsuccessful
*/
get_pchat() async {
  List<Message> mes = <Message>[];

  try {
    final httpPackageUrl = Uri.http(url,
        'api/messages_between/' + uid.toString() + '/' + sender_uid.toString());
    final httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': createAuth()});

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      // print(httpPackageResponse.body);

      // take list of activities and add a new Activity() to activity_feed
      List<dynamic> parsedActivities = jsonDecode(httpPackageResponse.body);

      print("successfully got messages");

      int count = parsedActivities.length;
      for (int i = 0; i < count; i++) {
        Map parsedActivity = parsedActivities.elementAt(i);
        /* Class Constructor */
        // Activity(this.type, this.time, this.image, this.description, this.author,
        //     this.tagged);

        mes.add(Message(
          text: parsedActivity['content'],
          date: parsedActivity['timestamp'],
          sender: parsedActivity['sender'],
          receiver: parsedActivity['receiver'],
        ));
      }
    } else {}
  } catch (_) {
    print(_);
    print("Error connecting to server in get_feed()");
  }

  messages = mes;
}
