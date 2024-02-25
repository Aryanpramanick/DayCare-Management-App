//workerLogin.dart
//Purpose: To allow a worker to log into the app

import 'dart:io';

import 'package:daycare_mgmt_frontend/parent_Login.dart';
import 'package:daycare_mgmt_frontend/worker_dayplan.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/attend_class.dart';
import 'package:flutter/material.dart';
import 'package:daycare_mgmt_frontend/parent_login.dart' as pl;
import 'package:daycare_mgmt_frontend/globals.dart' as globals;
import 'package:daycare_mgmt_frontend/worker_feed.dart' as wf;
import 'package:daycare_mgmt_frontend/worker_menubar.dart' as mb;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'child_class.dart';
import 'package:daycare_mgmt_frontend/worker_messages.dart';
import 'package:dio/dio.dart';
import 'auth.dart' as auth;
import 'globals.dart';

import 'package:daycare_mgmt_frontend/firebasewrapper.dart';

class workerLogin extends StatefulWidget {
  const workerLogin({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<workerLogin> {
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
                  child: Text(
                    'Worker Login',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.indieFlower().fontFamily,
                    ),
                  ),
                ),
                // Username text field
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
                // Password text feild
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
                // Switch to parent button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const parentLogin()),
                    );
                  },
                  child: const Text('Parent Login',
                      style: TextStyle(fontSize: 15, color: Colors.purple)),
                ),
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
                        })),
              ])
            ]),
          ),
        ));
  }

  /*
  * loginTasks() - runs all the tasks needed to login
  * 1. checks if username and password is valid
  * 2. gets user info - uid from worker id
  * 3. gets list of children in worker's care
  * 4. gets attendance for each child
  * 5. gets dayplan items for the current day
  * 6. gets feed activities for the worker
  * 7. gets parent info for messages
  */
  loginTasks() async {
    //start loading dialog
    loadDialog(context);

    globals.userType = 'worker';

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

    //get user info - uid from worker id
    success = await get__User();

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

    // get list of children in worker's care
    success = await getChildrenByWorker(globals.userId);
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Error Fetching Data: children");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // get attendance for each child
    success = await getAttendance(globals.childrenList);
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Error Fetching Data: attendance");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // get dayplan items for the current day
    success = await getItemsByWorker(
        userId, DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
    print("items: ");
    print(items);

    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Error Fetching Data: dayplan items");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    //get feed activities for the worker
    success = await wf.get_feed(userId);
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Error Fetching Data: activities");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // get parent info for messages
    success = await get_parent();
    if (success == false) {
      Navigator.of(context).pop(); // Remove loading dialog
      popUpDialog(context, popUpDialogType.Error, "Login Error",
          "Error Fetching Data: messages");
      setState(() {
        usernameController.text = "";
        passwordController.text = "";
      });
      return;
    }

    // all info retrieved successfully
    Navigator.pop(context); // Remove loading dialog
    if (success) {
      //sends to menubar
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const mb.MenuBar(
                  pageIndex: 2,
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
* server response contains worker id if successful
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
    "accountType": "worker"
  };
  var body = json.encode(login_creds);
  print(body);

  // Send request
  try {
    print("trying login()");
    final httpPackageUrl = Uri.http(globals.url, '/api/login');
    var httpPackageResponse = await http.post(httpPackageUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: body);

    var tries = 0;
    while (httpPackageResponse.statusCode != 200 && tries < 5) {
      print("Retrying login()");
      var httpPackageResponse = await http.post(httpPackageUrl,
          headers: {
            "Content-Type": "application/json",
          },
          body: body);
      tries++;
    }

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      print('Successfully logged in - got worker id');
      globals.isLoggedIn = true;

      //get parent id
      Map parsedChild = jsonDecode(httpPackageResponse.body);
      id = parsedChild["id"];
    } else {
      print(httpPackageResponse.statusCode);
      return false;
    }
  } catch (_) {
    print("Error in postlogin()");
    print(_);
    return false;
  }

  globals.userId = id;

  return true;
}

/*
 * getChildrenByWorker takes in a worker_id and sends a request to the 
 *    /api/worker/worker_id/children endpoint, which returns a list of children
 *    that are linked to the worker. This function parses the data, creating 
 *    a list of Child objects, which is later stored as a globals.dart variable
 * this function is asynchronous and thus causes the page to appear as if it is
 *    loading for a few seconds
 * 
 */
Future<bool> getChildrenByWorker(worker_id) async {
  List<Child> children = <Child>[];

  // Send request
  try {
    // [address]/api/worker/<id>/children
    final httpPackageUrl = Uri.http(
        globals.url, '/api/worker/' + worker_id.toString() + '/children');
    var httpPackageResponse = await http
        .get(httpPackageUrl, headers: {'authorization': auth.createAuth()});

    var tries = 0;
    while (httpPackageResponse.statusCode != 200 && tries < 5) {
      print("Retrying getChildrenByWorker()");
      httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': auth.createAuth()});
      tries++;
    }

    // Check response for success
    if (httpPackageResponse.statusCode == 200) {
      //for debugging
      print(httpPackageResponse.body);

      // take list of child models and add a new Child() with their
      //   first name, id, and share permissions to the children list
      List<dynamic> parsedChildren = jsonDecode(httpPackageResponse.body);
      int count = parsedChildren.length;
      for (int i = 0; i < count; i++) {
        Map parsedChild = parsedChildren.elementAt(i);
        Child newChild = Child(parsedChild['firstname'], parsedChild['id'],
            parsedChild['share_permissions'], parsedChild['dayCareWorker']);
        newChild.attend =
            Attend(0, parsedChild['id'], userId, DateTime.now(), false);
        children.add(newChild);
      }
    } else {
      print(httpPackageResponse.statusCode);
      return false;
    }
  } catch (_) {
    print("Error in getChildrenByWorker()");
    print(_);
    return false;
  }

  globals.childrenList = children;
  return true;
}

/*
* get___User - sends GET request to server at /api/worker/<worker_id>
* server response contains the user id of the worker
*   returns true if successful
*   returns false if unsuccessful
*/
Future<bool> get__User() async {
  int uuid = 0;
  try {
    final httpPackageUrl = Uri.http(url, 'api/worker/' + userId.toString());
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
