//addactivity.dart
//Purpose: To allow a worker to edit an activity

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:daycare_mgmt_frontend/camera_page.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/popups.dart';
import 'package:daycare_mgmt_frontend/worker_addactivity.dart';
import 'package:daycare_mgmt_frontend/worker_feed.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class EditActivity extends StatefulWidget {
  final Activity activity;

  const EditActivity({Key? key, required this.activity}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<EditActivity> {
  final _formkey = GlobalKey<FormState>();

  // children list displayed in multiselect box
  final _childrenList =
      childrenList.map((c) => MultiSelectItem<Child>(c, c.name)).toList();
  // children selected to be tagged in activity
  List<Child> initialValues = [];
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
    // set the initial values to that of the activity being edited
    descriptionTextInput.text = widget.activity.description!;
    initialValues = convertValues(widget.activity.tagged);
    selectedChildren = initialValues;
    addContainer();
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
      appBar: AppBar(
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formkey,
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: Text(
                  'Edit activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Dropdown for dayplan items
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: DropdownButtonFormField(
                  key: const Key('dayplanDropdown'),
                  isExpanded: true,
                  hint: Text(widget.activity.title,
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  items: dayplanItems
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 15),
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
              // children multiselect button
              Container(
                key: const Key('tagChildrenSelect'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  initialValue: initialValues,
                  listType: MultiSelectListType.CHIP,
                  onConfirm: (values) {
                    setState(() {
                      selectedChildren = values;
                      initialValues = values;
                    });
                  },
                ),
              ),

              /// description TextField
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
                      key: const Key('openCameraButton'),
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
                      key: const Key('openGalleryButton'),
                      onPressed: () async {
                        await openGallery();
                      },
                      icon: const Icon(
                        Icons.photo_library,
                        size: 50,
                      ),
                    ),
                  ),
                ]),
              ),
              // Section for photo/video preview
              Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                child: cameraPrev(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(left: 30),
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              heroTag: "deleteactivitybutton",
              backgroundColor: Colors.purpleAccent,
              child: const Icon(Icons.delete),
              onPressed: () async {
                await deleteActivity();
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
                heroTag: "updateactivitybutton",
                backgroundColor: Colors.purpleAccent,
                child: const Icon(Icons.check),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false
                  if (_formkey.currentState!.validate()) {
                    await editActivityTasks();
                  }
                }),
          ),
        ],
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

    //get rid of previous video player
    if (videoController != null) {
      videoController!.dispose();
    }

    //safety checking - no photo or video was taken
    if (fileBuffer == null) {
      return;
    }

    //for debugging
    print("in edit activity.");
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
    String type;
    // for when a new file is added
    if (file != null) {
      type = checkFileTypebyFile(file);
      if (type == 'image') {
        preview = Image.file(
          file!,
        );
        return;
      } else if (type == 'video') {
        videoController = VideoPlayerController.file(
          fileBuffer!,
        );
        // set controller, create video player below
      } else if (type == 'null') {
        preview = Container();
        return;
      }
    }
    // for when a file is loaded from the activity
    else {
      type = checkFileTypebyString(widget.activity.filestr);
      if (type == 'image') {
        preview = Image.network(
          widget.activity.filestr!,
        );
        return;
      } else if (type == 'video') {
        videoController = VideoPlayerController.network(
          widget.activity.filestr!,
        );
        //set controller, create video player below
      } else if (type == 'null') {
        preview = Container();
        return;
      }
    }

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = videoController!.initialize();

    // Use the controller to loop the video.
    videoController!.setLooping(true);
    preview = Stack(
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
    return;
  }

  /*
  * deleteActivity: confirms with the user if they want to delete the activity
  *   then deletes the activity from the database
  * and returns to the feed page
  */
  deleteActivity() async {
    // delete confirmation dialog
    int input = await popUpDialog(
      context,
      popUpDialogType.Warning,
      "Warning",
      "Are you sure you want to delete this activity?",
    );

    // if user confirms deletion (input == 1 on OK button)
    if (input == 1) {
      bool success = await widget.activity.deleteActivity();
      if (!success) {
        popUpDialog(
          context,
          popUpDialogType.Error,
          "Error",
          "Failed to delete activity",
        );
        return;
      }
      await popUpDialog(
        context,
        popUpDialogType.Success,
        "Success",
        "Activity deleted",
      );

      loadDialog(context);
      // return to feed page
      await get_feed(userId);
      Navigator.pop(context); // close loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const menubar.MenuBar(
            pageIndex: 2,
          ),
        ),
      );
    }
  }

  /*
  * editActivityTasks: calls patchActivity to update the activity in the database
  * and returns to the home page (feed)
  */
  editActivityTasks() async {
    bool success = await patchActivity();
    if (!success) {
      return;
    }
    await popUpDialog(
      context,
      popUpDialogType.Success,
      "Success",
      "Activity updated",
    );

    loadDialog(context);
    await get_feed(userId);
    Navigator.pop(context);
    // return to feed page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const menubar.MenuBar(
          pageIndex: 2,
        ),
      ),
    );
  }

  /*
  * patchActivity: checks that a dayplan activity is selected, 
  *   that at least one child is selected, and that the children selected
  *   are allowed to be tagged with others then patches it in the database 
  * returns true if successful, false otherwise
  */
  patchActivity() async {
    // check that a child is selected
    if (selectedChildren.isEmpty) {
      popUpDialog(context, popUpDialogType.Error, "Error adding activity",
          "Select at least one child to be tagged");
      return false;
    }

    // check that the children selected are allowed to be tagged with others
    List<Child> cannotShare = checkChildPermissions(selectedChildren);
    if (cannotShare.isNotEmpty) {
      popUpDialog(context, popUpDialogType.Error, "Error adding activity",
          cannotShare.first.name + " does not have sharing permissions");
      return false;
    }

    loadDialog(context);

    // if the dropdown value is null, then the user did not change the title
    if (dropdownValue == null) {
      dropdownValue = widget.activity.title;
    }
    // update the activity
    Activity changedActivity = Activity(dropdownValue!, widget.activity.time,
        globals.userId, selectedChildren as List<Child>);
    // use old activity id
    changedActivity.id = widget.activity.id;
    // get the description from the text field
    changedActivity.description = descriptionTextInput.text;
    // if file was changed, update it in the new activity
    // otherwise, use the old file
    File newFile;
    if (file != null) {
      newFile = file!;
      changedActivity.file = newFile;
    }

    bool success = await changedActivity.updateActivity();

    Navigator.of(context).pop(); // Remove loading dialog

    if (!success) {
      popUpDialog(context, popUpDialogType.Error, "Error adding activity",
          "Unknown error");
      return false;
    }

    return true;
  }

  /*
  * convertValues: takes in a list of tagged children from the activity to be edited
  *   and returns a list of the children objects that are in the childrenList
  *   so that the values in the multiselect can be the exact objects from
  *   the childrenList
  */
  List<Child> convertValues(List<Child> tagged) {
    List<Child> values = [];
    for (int i = 0; i < tagged.length; i++) {
      for (int j = 0; j < childrenList.length; j++) {
        if (tagged[i].id == childrenList[j].id) {
          values.add(childrenList[j]);
        }
      }
    }
    return values;
  }
}

/* 
*   checkFileTypebyString: takes in a file path and returns the type of file
*   returns 'image' if the file is an image
*   returns 'video' if the file is a video
*   returns 'null' if the file is not an image or video
*/
checkFileTypebyString(String? file) {
  if (file == null) {
    return 'null';
  }

  String? mimeStr = lookupMimeType(file);
  if (mimeStr == null) {
    return 'null';
  }
  var fileType = mimeStr.split('/');

  if (fileType[0] == 'image') {
    return 'image';
  } else if (fileType[0] == 'video') {
    return 'video';
  }
}
