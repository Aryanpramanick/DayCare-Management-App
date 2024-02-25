//parentLogin.dart
//Purpose: To allow a parent to log into the app

import 'package:daycare_mgmt_frontend/parent_chatmessages.dart';
import 'package:daycare_mgmt_frontend/parent_dayplan.dart';
import 'package:daycare_mgmt_frontend/parent_menubar.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/worker_chatmessages.dart';
import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/worker_login.dart' as wl;
import 'package:daycare_mgmt_frontend/parent_feed.dart' as pf;
import 'package:daycare_mgmt_frontend/globals.dart' as globals;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daycare_mgmt_frontend/parent_messages.dart' as pfp;
import 'package:intl/intl.dart';
import 'auth.dart' as auth;
import 'globals.dart';
import 'package:daycare_mgmt_frontend/firebasewrapper.dart';

class parentLogin extends StatefulWidget {
  const parentLogin({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<parentLogin> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _loginkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // theme: ThemeData(fontFamily: GoogleFonts.indieFlower().fontFamily),
        color: Colors.purple,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Form(
            key: _loginkey,
            child: Stack(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.network(
                            "https://img.freepik.com/premium-vector/minimal-dried-honesty-flower-invitation-card-design-template-dry-flowers-leaves-blossom-illustration_506811-540.jpg?w=360")
                        .image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ListView(children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(20),
                    child: Text('Parent Login',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.indieFlower().fontFamily,
                        ))),
                //Username text field
                Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                      key: Key('username'),
                      controller: usernameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Username'),
                    )),
                // Password text field
                Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      key: Key('password'),
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Password'),
                    )),
                // Switch to Worker Button
                TextButton(
                    onPressed: () {
                      //runApp(const MaterialApp(home: wl.workerLogin()));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const wl.workerLogin()),
                      );
                    },
                    child: const Text('Worker Login',
                        style: TextStyle(fontSize: 15, color: Colors.purple))),
                // Login Button
                Container(
                    height: 55,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple),
                      key: Key('login'),
                      child: Text('Login',
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily:
                                  GoogleFonts.indieFlower().fontFamily)),
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_loginkey.currentState!.validate()) {
                          await loginTasks();
                        }
                      },
                    )),
              ])
            ]),
          ),
        ));
  }

  loginTasks() async {
    loadDialog(context);

    globals.userType = 'parent';

    // check login credentials
    //checks if username and password is valid
    bool success =
        await postLogin(usernameController.text, passwordController.text);
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Invalid username or password");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    //get user info - uid from parent id
    success = await get___User();
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Error Fetching Data: user id");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // for debugging
    print("uid: $uid");

    //get user info - worker uid
    success = await get___wUser();
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Error Fetching Data: worker user id");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // for debugging
    print("sender_uid: $sender_uid");

    // for debugging
    // print("messages");
    // print(messages);

    // get child id from parentID
    success = await getChildId(globals.userId);
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Problem Fetching Data: child id");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // for debugging
    print(globals.childIds);
    success = await getChildList(globals.userId);
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Problem Fetching Data: child list");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // for debugging
    print("childList: ");
    print(globals.childList);

    success = await pf.get_feed();
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Problem Fetching Data: activity feed");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }
    // worker_dayplan_id = childrenList.first.wid;
    getItemsByWorkerr(childrenList.first.wid,
        DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());

    // for debugging
    print(globals.todaysActivityFeed);

    success = await pfp.get_worker();
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Problem Fetching Data: worker name");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // for debugging
    print(globals.worker_name);

    //all info retrieved successfully
    Navigator.of(context).pop(); // Remove loading dialog
    if (success) {
      //send to menubar
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ParentMenuBar(
                  pageIndex: 1,
                )),
      );
      //clears the textfield
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
    } else {
      //error message
      popUpDialog(
          context, popUpDialogType.Error, "Login Error", "Unknown Error");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }
    FirebaseWrapper().setupFirebase();
  }
}

/*
* postLogin - sends login POST request to server at /api/login
* server response contains parent id if successful
*   returns true if login successful
*   returns false if login unsuccessful
*/
Future<bool> postLogin(String username, String password) async {
  int id = 0;

  auth.username = username;
  auth.password = password;

  Map login_creds = {
    "username": username,
    "password": password,
    "accountType": "parent"
  };
  var body = json.encode(login_creds);
  print(body);

  // Send request
  try {
    final httpPackageUrl = Uri.http(globals.url, '/api/login');
    final httpPackageResponse = await http.post(httpPackageUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: body);

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      print('Successfully logged in - got parent id');
      globals.isLoggedIn = true;

      //get parent id
      Map parsedChild = jsonDecode(httpPackageResponse.body);
      id = parsedChild["id"];
    } else {
      print(httpPackageResponse.statusCode);
      return false;
    }
  } catch (_) {
    print("Error in postLogin()");
    print(_);
    return false;
  }

  globals.userId = id;
  return true;
}

/*
* getChildId - sends GET request to server at /api/parent/{parent_id}/children
* globals variable is updated to the list of childids if successful
*   returns true if successful
*   returns false if unsuccessful
*/
Future<bool> getChildId(int id) async {
  List<int> ids = [];
  try {
    final httpPackageUrl =
        Uri.http(globals.url, '/api/parent/' + id.toString() + '/children');
    final httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': auth.createAuth()});

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      print('Successfully got child id');

      List<dynamic> parsedChildren = jsonDecode(httpPackageResponse.body);
      // lopp through children and add each id to childIds
      for (int i = 0; i < parsedChildren.length; i++) {
        Map parsedChild = parsedChildren[i];
        ids.add(parsedChild["id"]);
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

  globals.childIds = ids;
  return true;
}

/* 
* get___wUser - sends GET request to server at /api/parent/{parent_id}/workers
* server response contains a list of worker ids associated with parent (aka their children)
*   returns true if successful
*   returns false if unsuccessful
 */

Future<bool> get___wUser() async {
  List<int> ids = [];
  try {
    final httpPackageUrl =
        Uri.http(url, 'api/parent/' + userId.toString() + '/workers');
    var httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': auth.createAuth()});

    var tries = 0;
    while (httpPackageResponse.statusCode != 200 && tries < 5) {
      print("Retrying get___wUser()");
      httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': auth.createAuth()});
      tries++;
    }

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      // print(httpPackageResponse.body);

      List<dynamic> parsedWorkers = jsonDecode(httpPackageResponse.body);
      // loop through parsedWorkers and add each worker id to uuids
      for (int i = 0; i < parsedWorkers.length; i++) {
        Map parsedWorker = parsedWorkers[i];
        ids.add(parsedWorker["user"]);
      }
      sender_uid = ids[0];
    } else {
      return false;
    }
  } catch (_) {
    print("Error in get__wUser()");
    print(_);
    return false;
  }
  return true;
}

/*
* get___User - sends GET request to server at /api/parent/{parent_id}
* server response contains the user id of the parent
*   returns true if successful
*   returns false if unsuccessful
*/
Future<bool> get___User() async {
  int uuid = 0;
  try {
    final httpPackageUrl = Uri.http(url, 'api/parent/' + userId.toString());
    var httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': auth.createAuth()});

    var tries = 0;
    while (httpPackageResponse.statusCode != 200 && tries < 5) {
      print("Retrying get_user()");
      httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': auth.createAuth()});
      tries++;
    }

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      // print(httpPackageResponse.body);

      Map parsedChild = jsonDecode(httpPackageResponse.body);
      uuid = parsedChild["user"];
    } else {
      return false;
    }
  } catch (_) {
    print("Error in get__User()");
    print(_);
    return false;
  }
  uid = uuid;
  return true;
}
