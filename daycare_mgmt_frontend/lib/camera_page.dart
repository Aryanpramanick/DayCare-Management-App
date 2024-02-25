import 'dart:io';
import 'package:camera/camera.dart';
import 'package:daycare_mgmt_frontend/globals.dart';
import 'package:daycare_mgmt_frontend/worker_addactivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/*
* This is the camera page. It is a stateful widget that uses the camera plugin to take a photo or video.
*/

class CameraPage extends StatefulWidget {
  final List<CameraDescription> camera;
  const CameraPage({required this.camera, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> cameraValue;
  XFile? _imageFile;
  bool isRecording = false;
  bool flash = false;
  bool front = true;
  int cameraPos = 0;
  bool ready = false;

  @override
  void initState() {
    _controller = CameraController(
      widget.camera[cameraPos],
      ResolutionPreset.max,
    );
    cameraValue = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                ready = true;
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: CameraPreview(_controller),
                );
              } else {
                return const SizedBox(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flash button
                  IconButton(
                    onPressed: () {
                      // If the camera is not ready, do nothing.
                      if (!ready) return;

                      // Change state of flash and set flash mode.
                      setState(() {
                        flash = !flash;
                      });
                      flash
                          ? _controller.setFlashMode(FlashMode.torch)
                          : _controller.setFlashMode(FlashMode.off);
                    },
                    // If the flash is on, show the flash on icon. Otherwise, show the flash off icon.
                    icon: flash
                        ? Icon(
                            Icons.flash_on,
                            color: Colors.white,
                            size: 40,
                          )
                        : Icon(
                            Icons.flash_off,
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                  // Take photo/video button
                  GestureDetector(
                    onTap: () async {
                      // If the camera is not ready, do nothing.
                      if (!ready) return;

                      // If the camera is not recording, take a photo. Otherwise, stop recording and take a video.
                      bool success = false;
                      if (!isRecording) {
                        success = await takePhoto();
                      } else {
                        setState(() {
                          isRecording = false;
                        });
                        success = await takeVideo();
                      }
                      print(success);
                      // Return to the previous page.
                      if (success) {
                        Navigator.pop(context);
                      }
                    },
                    onLongPress: () async {
                      // If the camera is not ready, do nothing.
                      if (!ready) return;

                      // Start recording.
                      try {
                        await _controller.startVideoRecording();
                        setState(() {
                          isRecording = true;
                        });
                      } catch (e) {
                        print("Camera Error: ");
                        print(e);
                      }
                    },
                    // If the camera is recording, show a red circle. Otherwise, show a white circle.
                    child: isRecording
                        ? Icon(Icons.radio_button_on,
                            color: Colors.red, size: 70)
                        : Icon(Icons.circle, color: Colors.white, size: 70),
                  ),
                  // Flip camera button
                  IconButton(
                    onPressed: () {
                      // If the camera is not ready, do nothing.
                      if (!ready) return;

                      // Change state of front and set camera position.
                      // 0 is the front camera and 1 is the back camera (selfie camera).
                      front = !front;
                      cameraPos = front ? 0 : 1;

                      _controller = CameraController(
                        widget.camera[cameraPos],
                        ResolutionPreset.max,
                      );
                      cameraValue = _controller.initialize();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  * takePhoto: takes a photo and saves it to the fileBuffer variable.
  */
  takePhoto() async {
    try {
      XFile imageFile = await _controller.takePicture();
      setState(() {
        _imageFile = imageFile;
      });
      print("took photo");
    } catch (e) {
      print("Camera Error: ");
      print(e);
      return false;
    }
    if (_imageFile != null) {
      File file = File(_imageFile!.path);
      fileBuffer = file;
      print("new pic");
      return true;
    }
    return false;
  }

  /*
  * takeVideo: takes a video and saves it to the fileBuffer variable.
  */
  takeVideo() async {
    try {
      XFile imageFile = await _controller.stopVideoRecording();
      setState(() {
        _imageFile = imageFile;
      });
      print("took video");
    } catch (e) {
      print("Camera Error: ");
      print(e);
      return false;
    }
    if (_imageFile != null) {
      File file = File(_imageFile!.path);
      fileBuffer = file;
      return true;
    }
    return false;
  }
}
