//child.dart
//Purpose: To create a class that repersents a child

import 'dart:convert';

import 'attend_class.dart';
import 'auth.dart';
import 'globals.dart';
import 'package:http/http.dart' as http;

class Child {
  late String name;
  late int id;
  late bool sharePermissions;
  bool present = false;
  Attend? attend;
  int wid;

  Child(this.name, this.id, this.sharePermissions, this.wid);

  /*
   * getChildInfo: makes a request to the server to get the child's info
   *     at /api/child/{id}
   * 
   */
  Future<bool> getChildInfo() async {
    try {
      final httpPackageUrl = Uri.http(url, '/api/child/' + id.toString());
      final httpPackageResponse = await http
          .get(httpPackageUrl, headers: {'authorization': createAuth()});

      if (httpPackageResponse.statusCode == 200) {
        // print("Child info received successfully");
        // print(httpPackageResponse.body);

        Map parsedChild = jsonDecode(httpPackageResponse.body);
        name = parsedChild['firstname'];
        sharePermissions = parsedChild['share_permissions'];
      } else {
        print(httpPackageResponse.statusCode);
        return false;
      }
    } catch (_) {
      print("Error in getChildInfo()");
      print(_);
      return false;
    }
    return true;
  }
}
