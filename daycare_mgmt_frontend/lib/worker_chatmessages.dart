//messages.dart
//Purpose: To allow a worker and parent to message each other

import 'dart:convert';
import 'package:daycare_mgmt_frontend/firebasewrapper.dart';
import 'package:daycare_mgmt_frontend/worker_messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:daycare_mgmt_frontend/parent_chatmessages.dart';
import 'package:daycare_mgmt_frontend/worker_menubar.dart' as menubar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'globals.dart';
import 'package:daycare_mgmt_frontend/message_class.dart';

List<Message> messages = [];

class WorkerChatMessages extends StatefulWidget {
  const WorkerChatMessages({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<WorkerChatMessages> implements CallBackInterface {
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _scroll = true;

  @override
  void initState() {
    super.initState();
    // check for new feed items every 10 seconds
    FirebaseWrapper().registerCallback(this);
  }

  @override
  void dispose() {
    FirebaseWrapper().unregisterCallback(this);
    super.dispose();
  }

  @override
  void update() async {
    await get_chat();
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
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await get_parent();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => menubar.MenuBar(
                    pageIndex: 4,
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
                controller: _scrollController,
                itemCount: messages.length,
                shrinkWrap: true,
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
                        await post_message(NewMessage);
                        await get_chat();
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

// gets all messages between the worker and parent from the database
get_chat() async {
  List<Message> mes = <Message>[];

  try {
    final httpPackageUrl = Uri.http(url,
        'api/messages_between/' + uid.toString() + '/' + sender_uid.toString());
    final httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': createAuth()});

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      // print(httpPackageResponse.body);

      // take list of messages and add a to parsedMessages
      List<dynamic> parsedMessages = jsonDecode(httpPackageResponse.body);

      print("successfully got messages");

      int count = parsedMessages.length;
      for (int i = 0; i < count; i++) {
        Map parsedMessage = parsedMessages.elementAt(i);
        /* Class Constructor */

        mes.add(Message(
          text: parsedMessage['content'],
          date: parsedMessage['timestamp'],
          sender: parsedMessage['sender'],
          receiver: parsedMessage['receiver'],
        ));
      }
    } else {}
  } catch (_) {
    print(_);
    print("Error connecting to server in get_feed()");
  }

  messages = mes;
}

// posts a message to the database as soon as the send button is pressed
post_message(NewMessage) async {
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
    print("Error connecting to server in post_message()");
  }
}
