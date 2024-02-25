//activity.dart
//Purpose: Activity Class
//  * deals with storing activity data
//  * posting new activity to server

// import 'package:daycare_mgmt_frontend/addactivity.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:daycare_mgmt_frontend/auth.dart';
import 'package:http_parser/http_parser.dart';
import 'package:daycare_mgmt_frontend/child_class.dart' as childClass;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:daycare_mgmt_frontend/globals.dart';

class Activity {
  late int id;
  final String title;
  final DateTime time;
  final int author;
  final List<childClass.Child> tagged;
  List<int> liked = [];
  File? file; // image is nullable becuase it is optional
  String? filestr;
  String filetype = 'null';
  String? description; // description is nullable because it is optional
  String likedString = "";

  /* Class Constructor */
  Activity(this.title, this.time, this.author, this.tagged);

  /*
   * postActivity() sends a post request to the backend so that it is added
   *    to the database and will appear in the feeds, then sets the id returned
   *    as the activity id
   * returns: 
   *    true if the request recieves a successful response
   *    false if the request recieves an unsuccessful response
   * 
   */
  Future<bool> postActivity() async {
    // safety check on tagged children list (should never be null)
    if (tagged == null || tagged.isEmpty) {
      return false;
    }

    //for making request
    Dio dio = Dio();

    // turn tagged children list into list of tagged ids
    List<int> taggedIds = [];
    for (int i = 0; i < tagged.length; i++) {
      taggedIds.add(tagged.elementAt(i).id);
    }

    // set up for file
    String? filename;
    if (file != null) {
      String filename = file!.path.split('/').last;
    }

    // get body ready to send
    // format: {'title', 'file', 'description', 'time', 'dayCareWorker', 'taggedChildrenID', 'likedParentID'}
    Map<String, dynamic> map = {
      "title": title,
      "file": file == null
          ? null
          : await MultipartFile.fromFile(file!.path,
              filename: filename, contentType: MediaType('image', 'jpg')),
      "time": DateTime.now().toString(),
      "description":
          description ?? "", // if description is null, send empty string
      "dayCareWorker": author,
      "taggedChildrenID": taggedIds,
      "likedParentID": [],
    };
    FormData? activity_data;
    if (file != null) {
      activity_data = FormData.fromMap(map);
    }

    // Send request
    try {
      var path = 'http://' + url + '/api/activity';

      var response;
      if (file != null) {
        response = await dio.post(path,
            data: activity_data,
            options: Options(headers: {
              "Content-Type": "multipart/form-data",
              'authorization': createAuth()
            }));
      } else {
        var j = json.encode(map);
        print(j);
        response = await dio.post(path,
            data: j,
            options: Options(headers: {
              "Content-Type": "application/json",
              'authorization': createAuth()
            }));
      }

      // Check response for success
      if (response.statusCode == 201) {
        //for debugging
        print('Successfully added activity');
        return true;
      } else {
        //for debugging
        print(response.statusCode);
        return false;
      }
    } catch (_) {
      //for debugging
      print("Error in postActivity()");
      print(_);
      return false;
    }
  }

  /*
   * updateActivity() sends a patch request to the backend so that it is updated
   *    in the database and will appear in the feeds
   * returns: 
   *    true if the request recieves a successful response
   *    false if the request recieves an unsuccessful response
   * 
   */
  updateActivity() async {
    // safety check on tagged children list (should never be null)
    if (tagged == null || tagged.isEmpty) {
      return false;
    }

    //for making request
    Dio dio = Dio();

    // turn tagged children list into list of tagged ids
    List<int> taggedIds = [];
    for (int i = 0; i < tagged.length; i++) {
      taggedIds.add(tagged.elementAt(i).id);
    }

    // set up for file
    String? filename;
    if (file != null) {
      String filename = file!.path.split('/').last;
    }

    // get body ready to send
    // format: {'title', 'description', 'dayCareWorker', 'taggedChildrenID'}
    Map<String, dynamic> map = {
      "title": title,
      "dayCareWorker": author,
      "taggedChildrenID": taggedIds
    };

    if (file != null) {
      map["file"] = await MultipartFile.fromFile(file!.path,
          filename: filename, contentType: MediaType('image', 'jpg'));
    }

    if (description != null) {
      map["description"] =
          description ?? ""; // if description is null, send empty string
    }

    FormData? activity_data;
    if (file != null) {
      activity_data = FormData.fromMap(map);
    }

    //for debugging
    // print(body);

    // Send request
    try {
      var path = 'http://' + url + '/api/activity/$id';

      var response;
      if (file != null) {
        response = await dio.patch(path,
            data: activity_data,
            options: Options(headers: {
              "Content-Type": "multipart/form-data",
              'authorization': createAuth()
            }));
      } else {
        var j = json.encode(map);
        print(j);
        response = await dio.patch(path,
            data: j,
            options: Options(headers: {
              "Content-Type": "application/json",
              'authorization': createAuth()
            }));
      }

      // Check response for success
      if (response.statusCode == 200) {
        //for debugging
        print('Successfully updated activity');
      } else {
        //for debugging
        print(response.statusCode);
        return false;
      }
    } catch (_) {
      //for debugging
      print("Error in updateActivity()");
      print(_);
      return false;
    }

    return true;
  }

  /*
   * deleteActivity() sends a delete request to the backend so that it is deleted
   *    in the database and will no longer appear in the feeds
   * returns: 
   *    true if the request recieves a successful response
   *    false if the request recieves an unsuccessful response
   * 
   */
  deleteActivity() async {
    try {
      final httpPackageUrl = Uri.http(url, '/api/activity/$id');
      final httpPackageResponse = await http
          .delete(httpPackageUrl, headers: {'authorization': createAuth()});

      if (httpPackageResponse.statusCode == 204) {
        print('Successfully deleted activity');
      } else {
        print('Failed to delete activity');
        return false;
      }
    } catch (_) {
      print("Error in deleteActivity()");
      print(_);
      return false;
    }
    return true;
  }

  /*
   * likeActivity() sends a patch request to the backend and adds the parent's id to
   *   the list of liked parents
   * returns: 
   *    true if the request recieves a successful response
   *    false if the request recieves an unsuccessful response
   * 
   */
  likeActivity(int parentID) async {
    if (liked.contains(parentID)) {
      return false;
    }
    // add parentID to liked list
    liked.add(parentID);

    try {
      final httpPackageUrl = Uri.http(url, '/api/activity/$id');
      final httpPackageResponse = await http.patch(httpPackageUrl,
          headers: {
            "Content-Type": "application/json",
            'authorization': createAuth()
          },
          body: json.encode({"likedParentID": liked}));

      if (httpPackageResponse.statusCode == 200) {
        print('Successfully liked activity');
      } else {
        print('Failed to like activity');
        return false;
      }
    } catch (_) {
      print("Error in likeActivity()");
      print(_);
      return false;
    }
    likedString = "Liked by " + liked.length.toString();
    return true;
  }

  /*
   * unlikeActivity() sends a patch request to the backend and removes the parent's id from
   *   the list of liked parents
   * returns: 
   *    true if the request recieves a successful response
   *    false if the request recieves an unsuccessful response
   * 
   */
  unlikeActivity(int parentID) async {
    if (!liked.contains(parentID)) {
      return false;
    }
    // remove parentID from liked list
    liked.remove(parentID);

    try {
      final httpPackageUrl = Uri.http(url, '/api/activity/$id');
      final httpPackageResponse = await http.patch(httpPackageUrl,
          headers: {
            "Content-Type": "application/json",
            'authorization': createAuth()
          },
          body: json.encode({"likedParentID": liked}));

      if (httpPackageResponse.statusCode == 200) {
        print('Successfully unliked activity');
      } else {
        print('Failed to unlike activity');
        return false;
      }
    } catch (_) {
      print("Error in unlikeActivity()");
      print(_);
      return false;
    }
    likedString = "Liked by " + liked.length.toString();
    return true;
  }

  /*
  * makeTaggedStringWorker() makes a string of the tagged children's names
  *   to be displayed in the activity feed
  */
  makeTaggedStringWorker() {
    String taggedString = "";
    for (int i = 0; i < tagged.length; i++) {
      taggedString = taggedString + tagged.elementAt(i).name;
      if (i != tagged.length - 1) {
        taggedString = taggedString + ", ";
      }
    }

    return taggedString;
  }

  /*
  * makeTaggedStringParent() makes a string of the tagged children's names
  *   to be displayed in the activity feed
  *   Note: only includes the parent's children, not other children for privacy
  */
  makeTaggedStringParent() {
    String taggedString = "";
    for (int i = 0; i < tagged.length; i++) {
      // check if child is in parent's list of children
      if (!childList.contains(tagged.elementAt(i).name)) {
        continue;
      }
      if (taggedString != "") {
        taggedString = taggedString + ", ";
      }
      taggedString = taggedString + tagged.elementAt(i).name;
    }

    return taggedString;
  }

  /*
  * makeLikedStringWorker() makes a string of the liked parents' names
  *   to be displayed in the activity feed
  */
  makeLikedStringWorker() async {
    String likedString = "";
    for (int i = 0; i < liked.length; i++) {
      if (i == 0) {
        likedString = "Liked by ";
      }

      // get parents name from id
      try {
        final httpPackageUrl =
            Uri.http(url, 'api/parent/' + liked.elementAt(i).toString());
        var httpPackageResponse = await http
            .get(httpPackageUrl, headers: {'authorization': createAuth()});

        // Check response for success
        if (httpPackageResponse.statusCode == 200) {
          Map parsedParent = jsonDecode(httpPackageResponse.body);
          likedString = likedString + parsedParent["firstname"];
        }
      } catch (_) {
        print("Error in makeLikedString()");
        print(_);
      }

      if (i != liked.length - 1) {
        likedString = likedString + ", ";
      }
    }

    return likedString;
  }
}
