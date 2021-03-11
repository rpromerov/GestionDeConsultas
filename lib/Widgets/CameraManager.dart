import 'dart:ffi';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraWidget extends StatefulWidget {
  CameraWidget({Key key}) : super(key: key);

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  CameraController cameraController;
  Future cameraControllerInit;
  CameraDescription camera;
  var isInit = false;
  XFile imageFile;

  Future<void> getCamera() async {
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  Future<Image> takePicture() async {
    if (isInit) {
      final image = await cameraController.takePicture();
      imageFile = image;
      return Image.file(File(image.path));
    }
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCamera().then((onValue) {
      cameraController = CameraController(camera, ResolutionPreset.high);

      cameraControllerInit = cameraController.initialize().then((_) {
        isInit = true;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: cameraControllerInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return AspectRatio(
              aspectRatio: cameraController.value.aspectRatio,
              child: CameraPreview(cameraController));
        } else {
          // Otherwise, display a loading indicator.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
