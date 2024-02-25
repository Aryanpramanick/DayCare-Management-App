//addactivity.dart
//Purpose: To allow a worker to register a new activity

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:daycare_mgmt_frontend/camera_page.dart';
import 'package:camera/camera.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
// import 'package:daycare_mgmt_frontend/video_page.dart';
import 'package:daycare_mgmt_frontend/worker_feed.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:daycare_mgmt_frontend/activity_class.dart';
import 'package:daycare_mgmt_frontend/child_class.dart';
import 'package:daycare_mgmt_frontend/worker_menubar.dart' as menubar;
import 'package:daycare_mgmt_frontend/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:convert';

// for video preview
VideoPlayerController? videoController;
Future<void>? _initializeVideoPlayerFuture;

class AddActivity extends StatefulWidget {
  const AddActivity({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<AddActivity> {
  final _formkey = GlobalKey<FormState>();

  // children list displayed in multiselect box
  final _childrenList =
      childrenList.map((c) => MultiSelectItem<Child>(c, c.name)).toList();
  // children selected to be tagged in activity
  List<Child> selectedChildren = [];
  // items from the worker's dayplan
  List<String> dayplanItems = globals.todaysItems;
  // chosen dayplan item
  String? dropdownValue;
  // for getting value of description
  final descriptionTextInput = TextEditingController();
  String description = "";

  // will be the image or video if added
  File? file;
  XFile? filePicker;

  // variable and Getter for the photo/video preview
  Widget preview = Container();
  Widget cameraPrev() {
    return preview;
  }

  @override
  void initState() {
    if (videoController != null) {
      videoController!.dispose();
    }
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    if (videoController != null) {
      videoController!.dispose();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    print("deactivating add activity");
    // if (videoController != null) {
    //   videoController!.dispose();
    // }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formkey,
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: Text(
                  'Add new activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Dropdown for dayplan items
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: DropdownButtonFormField(
                  key: Key('dayplanDropdown'),
                  validator: (value) =>
                      value == null ? 'Dayplan item is required' : null,
                  isExpanded: true,
                  hint: const Text("* Choose item from dayplan",
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  items: dayplanItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                ),
              ),

              Container(
                key: Key('tagChildrenSelect'),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: MultiSelectDialogField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Must tag at least 1 child';
                    }
                    return null;
                  },
                  title: Text("Tag children"),
                  buttonText:
                      Text("* Tag children", style: TextStyle(fontSize: 20)),
                  items: _childrenList,
                  listType: MultiSelectListType.CHIP,
                  // called when "ok" button is pressed
                  onConfirm: (values) {
                    setState(() {
                      selectedChildren = values;
                    });
                  },
                ),
              ),
              // description TextField
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: TextField(
                  key: Key('description'),
                  controller: descriptionTextInput,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                      labelStyle: TextStyle(fontSize: 20, color: Colors.black)),
                ),
              ),
              Container(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // camera button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: IconButton(
                      key: Key('openCameraButton'),
                      onPressed: () async {
                        await openCamera();
                      },
                      icon: const Icon(Icons.camera_alt, size: 50),
                    ),
                  ),
                  // gallery button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: IconButton(
                      key: Key('openGalleryButton'),
                      onPressed: () async {
                        await openGallery();
                      },
                      icon: const Icon(
                        Icons.photo_album,
                        size: 50,
                      ),
                    ),
                  ),
                ]),
              ),
              // Section for photo/video preview
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                child: cameraPrev(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addactivitybutton",
        backgroundColor: Colors.purpleAccent,
        child: Icon(Icons.check),
        onPressed: () async {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formkey.currentState!.validate()) {
            await addactivityTasks();
          }
        },
      ),
    );
  }

  /*
  * openCamera: opens the camera page and waits for a photo or video to be taken
  * then sets the fileBuffer to the new file and adds an image container to the 
  * preview section of the page
  * also checks the file size to make sure it is less than 50MB
  */
  openCamera() async {
    // search for cameras
    try {
      await availableCameras().then((cameras) async {
        // if no cameras found, return
        if (cameras.isEmpty) {
          return;
        }
        // if there is a camera, open camera page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPage(camera: cameras),
          ),
        );
      });
    } catch (e) {
      print(e);
      popUpDialog(context, popUpDialogType.Error, "Camera Error",
          "Trouble opening camera on this device.");
      return;
    }

    //safety checking - no photo or video was taken
    if (fileBuffer == null) {
      print("no new file was taken");
      return;
    }

    //get rid of previous video player
    if (videoController != null) {
      videoController!.dispose();
    }

    //for debugging
    print("in add activity.");
    print(fileBuffer!.path);

    var size = await getFileSize(fileBuffer!.path);

    //for debuggging
    print(size);

    //check is size is greater than 50MB
    if ((size["size"] >= 50 && size["suffix"] == "MB") ||
        size["suffix"] == "GB") {
      popUpDialog(context, popUpDialogType.Error, "Error attaching media",
          "File size too large");
      return;
    }

    setState(() {
      file = fileBuffer;
      addContainer();
    });
  }

  /*
  * openGallery: opens the gallery and allows the user to select a file
  * then adds the file to the preview section of the page
  * also checks the file size to make sure it is less than 50MB
  */
  openGallery() async {
    try {
      filePicker = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      print(e);
      popUpDialog(context, popUpDialogType.Error, "Gallery Error",
          "Trouble opening gallery on this device.");
      return;
    }

    if (filePicker != null) {
      //get rid of previous video player
      if (videoController != null) {
        videoController!.dispose();
      }
      var size = await getFileSize(filePicker!.path);

      //for debuggging
      print(size);

      //check is size is greater than 50MB
      if ((size["size"] >= 50 && size["suffix"] == "MB") ||
          size["suffix"] == "GB") {
        popUpDialog(context, popUpDialogType.Error, "Error attaching media",
            "File size too large");
        return;
      }

      setState(() {
        file = File(filePicker!.path);
        addContainer();
      });
    }
  }

  /*
  * addContainer: adds a container to the preview section of the page
  * depending on the type of file that is being previewed
  */
  addContainer() {
    String type = checkFileTypebyFile(file);

    // if file is of type image -> create Image() widget
    if (type == 'image') {
      preview = Image.file(
        file!,
      );
    }
    //else if file is of type video -> create VideoPlayer() widget
    else if (type == 'video') {
      videoController = VideoPlayerController.file(
        fileBuffer!,
      );
      // Initialize the controller and store the Future for later use.
      _initializeVideoPlayerFuture = videoController!.initialize();

      // Use the controller to loop the video.
      videoController!.setLooping(true);
      preview = Stack(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      child: AspectRatio(
                          aspectRatio: videoController!.value.aspectRatio,
                          child: VideoPlayer(videoController!)));
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Positioned.fill(
            child: TextButton(
              onPressed: () {
                // If the video is playing, pause it.
                if (videoController!.value.isPlaying) {
                  videoController!.pause();
                } else {
                  // If the video is paused, play it.
                  videoController!.play();
                }
              },
              child: Container(),
            ),
          ),
        ],
      );
    }
    // else if file is null -> return empty container
    else {
      preview = Container();
    }
  }

  /*
  * addActivityTasks: checks that a dayplan activity is selected, 
  *   that at least one child is selected, and that the children selected
  *   are allowed to be tagged with others
  * then posts the new activity to the database and returns to the home page (feed)
  */
  addactivityTasks() async {
    // check that a dayPlan activity is selected
    if (dropdownValue == null) {
      popUpDialog(context, popUpDialogType.Error, "Error adding activity",
          "Must select a dayplan activity");
      return;
    }

    // check that a child is selected
    if (selectedChildren.isEmpty) {
      popUpDialog(context, popUpDialogType.Error, "Error adding activity",
          "Select at least one child to be tagged");
      return;
    }
    // check that the children selected are allowed to be tagged with others
    List<Child> cannotShare = checkChildPermissions(selectedChildren);
    if (cannotShare.isNotEmpty) {
      popUpDialog(context, popUpDialogType.Error, "Error adding activity",
          cannotShare.first.name + " does not have sharing permissions");
      return;
    }

    loadDialog(context);

    // post the new activity
    Activity activity = Activity(dropdownValue!, DateTime.now(), globals.userId,
        selectedChildren as List<Child>);

    activity.file = file;
    activity.description = descriptionTextInput.text;

    bool success = await activity.postActivity();

    Navigator.of(context).pop(); // Remove loading dialog

    // if post is successful, go back to home page
    if (success) {
      await popUpDialog(
        context,
        popUpDialogType.Success,
        "Success",
        "Activity created",
      );

      loadDialog(context);
      await get_feed(userId);
      Navigator.of(context).pop(); // Remove loading dialog

      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const menubar.MenuBar(
            pageIndex: 2,
          ),
        ),
      );
    } else {
      await popUpDialog(context, popUpDialogType.Error, "Error",
          "Unknown error while trying to create activity");
      return;
    }
  }
}

/*
*  Function to check the file type of a file
*  Returns a string of the file type
*/
checkFileTypebyFile(File? file) {
  if (file == null) {
    return 'null';
  }

  String? mimeStr = lookupMimeType(file.path);
  if (mimeStr == null) {
    print(file.path);
    return 'null';
  }
  var fileType = mimeStr.split('/');
  print(fileType);

  if (fileType[0] == 'image') {
    return 'image';
  } else if (fileType[0] == 'video') {
    return 'video';
  }
}

/*
* looks at the permissions of the children selected and 
* returns a list of children that cannot be tagged in activities 
* with other children
*/
List<Child> checkChildPermissions(List<Child> values) {
  List<Child> cannotShare = [];

  //no child has been selected
  if (values.isEmpty) {
    return cannotShare;
  }

  //one child has been selected - no need to check permissions
  if (values.length == 1) {
    return cannotShare;
  }

  //more than one child has been selected - check their sharing permissions
  for (int i = 0; i < values.length; i++) {
    if (!values[i].sharePermissions) {
      cannotShare.add(values[i]);
    }
  }

  return cannotShare;
}

/*
*  Function to get the size of a file
*/
getFileSize(String filepath) async {
  var file = File(filepath);
  int bytes = await file.length();
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return {"size": (bytes / pow(1024, i)), "suffix": suffixes[i]};
}
