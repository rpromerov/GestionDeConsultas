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
  var showPreview = false;

  Future<void> getCamera() async {
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  String getImagePath() {
    return imageFile.path;
  }

  Future<Image> takePicture() async {
    final image = await cameraController.takePicture();
    imageFile = image;
    return Image.file(File(image.path));
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
          return Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: showPreview
                        ? Image.file(File(imageFile.path))
                        : CameraPreview(cameraController)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Spacer(),
                    showPreview
                        ? Row(
                            children: [
                              Spacer(),
                              CameraButton(
                                  context,
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    color: Color(Colors.black.value),
                                  ),
                                  "Tomar de nuevo", () {
                                setState(() {
                                  showPreview = false;
                                });
                              }),
                              Container(
                                width: 5,
                              ),
                              CameraButton(
                                  context,
                                  Icon(Icons.check,
                                      color: Color(Colors.black.value)),
                                  "Listo", () {
                                Navigator.of(context).pop();
                              }),
                              Spacer()
                            ],
                          )
                        : Row(
                            children: [
                              Spacer(),
                              CameraButton(
                                  context,
                                  Icon(
                                    Icons.camera_alt,
                                    color: Color(Colors.black.value),
                                  ),
                                  "Tomar foto",
                                  () => takePicture().then((onValue) {
                                        setState(() {
                                          showPreview = true;
                                        });
                                      })),
                            ],
                          ),
                  ],
                ),
              )
            ],
          );
        } else {
          // Otherwise, display a loading indicator.
          return Stack(
            children: [
              Center(child: CircularProgressIndicator()),
              Container(
                width: 200,
                height: 200,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(100)),
              )
            ],
          );
        }
      },
    );
  }
}

class CameraButton extends StatelessWidget {
  final BuildContext ctx;
  final Icon icon;
  final String label;
  final Function onPressed;
  CameraButton(this.ctx, this.icon, this.label, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: icon,
      onPressed: () => onPressed(),
      label: Text(
        label,
        style: TextStyle(color: Color(Colors.black.value)),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
    );
  }
}
