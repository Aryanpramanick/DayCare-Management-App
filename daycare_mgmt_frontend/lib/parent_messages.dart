import 'dart:convert';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/parent_chatmessages.dart';
import 'package:daycare_mgmt_frontend/worker_class.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:http/http.dart' as http;
import 'package:daycare_mgmt_frontend/message_class.dart';

import 'auth.dart';

class Messages_parent extends StatefulWidget {
  const Messages_parent({super.key});

  @override
  State<Messages_parent> createState() => _State();
}

//Worker and parent should be able to message each other
class _State extends State<Messages_parent> {
  @override
  void initState() {
    get_worker();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          _feat(),
          for (int i = 0; i < worker_name.length; i++) _delegate(context, i),
        ],
      ),
    );
  }

  Widget _delegate(BuildContext context, int index) {
    DateTime date2 = DateTime.now();
    final Faker faker = Faker();
    String Firstname = Worker(
            firstname: worker_name[index].firstname,
            lastname: worker_name[index].lastname,
            parentId: worker_name[index].parentId,
            uuid: worker_name[index].uuid,
            time_stamp: worker_name[index].time_stamp,
            last_message: worker_name[index].last_message)
        .firstname;
    String Lastname = Worker(
            firstname: worker_name[index].firstname,
            lastname: worker_name[index].lastname,
            parentId: worker_name[index].parentId,
            uuid: worker_name[index].uuid,
            time_stamp: worker_name[index].time_stamp,
            last_message: worker_name[index].last_message)
        .lastname;
    int Uuid = Worker(
            firstname: worker_name[index].firstname,
            lastname: worker_name[index].lastname,
            parentId: worker_name[index].parentId,
            uuid: worker_name[index].uuid,
            time_stamp: worker_name[index].time_stamp,
            last_message: worker_name[index].last_message)
        .uuid;
    if (worker_name[index].time_stamp == "") {
      worker_name[index].time_stamp = DateTime.now().toString();
    } else {
      print((DateTime.parse(worker_name[index].time_stamp)));
      print((DateTime.parse(worker_name[index].time_stamp).runtimeType));
      date2 = DateTime.parse(worker_name[index].time_stamp);
    }

    String lastmes = worker_name[index].last_message;

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
      messageDate: date2,
      dateMessage: Jiffy(date2).fromNow(),
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
        sender_name = messageData.sendername;
        // print("object s_uid");
        // print(sender_uid);
        uid = messageData.sender;
        await get_pchat();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParentChatMessages(),
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
* get_worker: sends request at /api/parent/{id}/workers to get the list of workers
*   that are associated with the parent
*  returns a list of Worker objects which includes last message data
*/
Future<bool> get_worker() async {
  List<Worker> workers = <Worker>[];

  try {
    final httpPackageUrl =
        Uri.http(url, 'api/parent/' + userId.toString() + '/workers');
    final httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': createAuth()});

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      List<dynamic> parsedWorkers = jsonDecode(httpPackageResponse.body);

      //for debugging
      print("successfully got worker info");
      print(parsedWorkers);

      int count = parsedWorkers.length;
      // count_c = count;
      for (int i = 0; i < count; i++) {
        Map parsedWorker = parsedWorkers.elementAt(i);

        workers.add(Worker(
          firstname: parsedWorker['firstname'],
          lastname: parsedWorker['lastname'],
          parentId: parsedWorker['id'],
          uuid: parsedWorker['user'],
          time_stamp: parsedWorker['last_message_timestamp'],
          last_message: parsedWorker['last_message'],
        ));
      }
    } else {
      return false;
    }
  } catch (_) {
    print("Error in get_worker()");
    print(_);
    return false;
  }

  worker_name = workers;
  return true;
}
