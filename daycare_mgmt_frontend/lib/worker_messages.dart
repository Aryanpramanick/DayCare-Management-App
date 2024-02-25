//messages.dart
//Purpose: To allow a worker and parent to message each other

import 'dart:convert';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'auth.dart';
import 'worker_chatmessages.dart';
import 'package:http/http.dart' as http;
import 'package:daycare_mgmt_frontend/message_class.dart';
import 'package:daycare_mgmt_frontend/parent_class.dart';

class Messages_worker extends StatefulWidget {
  const Messages_worker({super.key});

  @override
  State<Messages_worker> createState() => _State();
}

@override
void initState() {
  get_parent();
}

//Worker and parent should be able to message each other
class _State extends State<Messages_worker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          _feat(),
          for (int i = 0; i < parent_name.length; i++) _delegate(context, i),
        ],
      ),
    );
  }

  Widget _delegate(BuildContext context, int index) {
    DateTime date1 = DateTime.now();
    String Firstname = Parent(
            firstname: parent_name[index].firstname,
            lastname: parent_name[index].lastname,
            parentId: parent_name[index].parentId,
            uuid: parent_name[index].uuid,
            time_stamp: parent_name[index].time_stamp,
            last_message: parent_name[index].last_message)
        .firstname;
    String Lastname = Parent(
            firstname: parent_name[index].firstname,
            lastname: parent_name[index].lastname,
            parentId: parent_name[index].parentId,
            uuid: parent_name[index].uuid,
            time_stamp: parent_name[index].time_stamp,
            last_message: parent_name[index].last_message)
        .lastname;
    int Uuid = Parent(
            firstname: parent_name[index].firstname,
            lastname: parent_name[index].lastname,
            parentId: parent_name[index].parentId,
            uuid: parent_name[index].uuid,
            time_stamp: parent_name[index].time_stamp,
            last_message: parent_name[index].last_message)
        .uuid;
    if (parent_name[index].time_stamp == "") {
      date1 = DateTime.now();
    } else {
      print((DateTime.parse(parent_name[index].time_stamp)));
      print((DateTime.parse(parent_name[index].time_stamp).runtimeType));
      date1 = DateTime.parse(parent_name[index].time_stamp);
    }

    String lastmes = parent_name[index].last_message;

    String name = Firstname + " " + Lastname;
    if (lastmes == "") {
      lastmes = "Click to chat for the first time!";
    }

    return _MessageTile(
        messageData: MessageData(
      sendername: name,
      sender: uid,
      receiver: Uuid,
      message: lastmes,
      messageDate: date1,
      dateMessage: Jiffy(date1).fromNow(),
      profilePicture: Helpers.randomPictureName(),
    ));
  }
}

// for each message, we need to display the profile picture, the name of the person who sent the message, the last message sent and the date and time of the last message sent
class _MessageTile extends StatelessWidget {
  const _MessageTile({Key? key, required this.messageData}) : super(key: key);
  final MessageData messageData;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // print("object uid");
        // print(uid);
        sender_uid = messageData.receiver;
        // print("object s_uid");
        // print(sender_uid);
        sender_name = messageData.sendername;
        uid = messageData.sender;
        await get_chat();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerChatMessages(),
          ),
        );
      },
      child: Container(
        // height: 100,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 70, 69, 69),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(messageData.profilePicture),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        messageData.sendername,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          wordSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Text(
                        messageData.message,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9899A5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        messageData.dateMessage.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: -0.2,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9899A5),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

//design header
class _feat extends StatelessWidget {
  const _feat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Text(
            'Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/*
* get_parent: sends request at /api/worker/{id}/parents to get the list of parents
*   that are associated with the worker
*  returns a list of Parent objects which includes last message data
*/
Future<bool> get_parent() async {
  List<Parent> P_name = <Parent>[];

  try {
    final httpPackageUrl =
        Uri.http(url, 'api/worker/' + userId.toString() + '/parents');
    var httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': createAuth()});

    var tries = 0;
    while (httpPackageResponse.statusCode != 200 && tries < 5) {
      print("Retrying get_parent()");
      final httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': createAuth()});
      tries++;
    }

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      // print(httpPackageResponse.body);

      // take list of activities and add a new Activity() to activity_feed
      List<dynamic> parsedMessages = jsonDecode(httpPackageResponse.body);

      print("successfully got parent info");
      print(parsedMessages);
      int count = parsedMessages.length;
      // count_c = count;
      for (int i = 0; i < count; i++) {
        Map parsedMessage = parsedMessages.elementAt(i);
        /* Class Constructor */
        P_name.add(Parent(
          firstname: parsedMessage['firstname'],
          lastname: parsedMessage['lastname'],
          parentId: parsedMessage['id'],
          uuid: parsedMessage['user'],
          time_stamp: parsedMessage['last_message_timestamp'],
          last_message: parsedMessage['last_message'],
        ));
      }
    } else {
      return false;
    }
  } catch (_) {
    print(_);
    print("Error connecting to server");
    return false;
  }

  parent_name = P_name;
  return true;
}
