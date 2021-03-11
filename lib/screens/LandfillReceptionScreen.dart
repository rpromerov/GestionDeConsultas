import 'dart:convert';
import 'dart:io';

import 'package:Cosemar/Widgets/CameraManager.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class LandfillReceptionScreen extends StatefulWidget {
  @override
  _LandfillReceptionScreenState createState() =>
      _LandfillReceptionScreenState();
}

class _LandfillReceptionScreenState extends State<LandfillReceptionScreen> {
  final tonTextFieldController = TextEditingController();
  final nameTextForm = TextEditingController();
  final observationTextField = TextEditingController();
  final formState = GlobalKey<FormState>();

  var isCameraControllerReady = false;

  @override
  void initState() {
    super.initState();
  }

  final cameraWidgetState = GlobalKey<CameraWidgetState>();
  Image picture;
  var showPicture = false;

  Future<void> takePicture() async {
    final image = await cameraWidgetState.currentState.takePicture();
    picture = image;
    setState(() {
      showPicture = true;
    });
  }

  void retakePicture() {
    picture = null;
    setState(() {
      showPicture = false;
    });
  }

  void showConfirmationDialog(BuildContext ctx) {
    final alert = AlertDialog(
      title: Text("Recepcion enviada correctamente"),
      actions: [
        TextButton(
          child: Text("Ok"),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(Login.routeName);
          },
        )
      ],
    );
  }

  Future<String> encodeImage() async {
    final filePath = cameraWidgetState.currentState.imageFile.path;
    final byteData = await File(filePath).readAsBytes();
    final base64EncodedImage = base64Encode(byteData);
    return base64EncodedImage;
  }

  Future<void> sendLandfillReception(BuildContext ctx) async {
    final network = Provider.of<NetworkProvider>(ctx);
    final encodedImage = await encodeImage();
    network
        .sendLandfillReception(
            base64Image: encodedImage,
            name: nameTextForm.text,
            observations: observationTextField.text,
            tons: tonTextFieldController.text)
        .then((_) {
      showConfirmationDialog(ctx);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var floatingButton = Container(
      width: 125,
      height: 50,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.file_upload,
                size: 30,
                color: Colors.white,
              ),
              Text('Enviar',
                  style: Theme.of(context).textTheme.button.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      )),
            ],
          ),
        ),
        onPressed: () {},
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Recepción de vertedero"),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: floatingButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Form(
                  key: formState,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: "Nombre",
                            hintText: "Nombre de quien recibe"),
                        controller: tonTextFieldController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          return value.isNotEmpty
                              ? null
                              : "Debe ingresar un nombre";
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: "Toneladas de carga",
                            hintText: "Toneladas"),
                        controller: tonTextFieldController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return value.isNotEmpty
                              ? null
                              : "Debe ingresar las toneladas de carga indicadas en el recibo";
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Observaciones",
                        ),
                        controller: tonTextFieldController,
                        validator: (value) => null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: size.height * 0.6,
                width: size.width * 0.6,
                child: showPicture
                    ? Image(
                        image: picture.image,
                        fit: BoxFit.fill,
                      )
                    : CameraWidget(
                        key: cameraWidgetState,
                      ),
              ),
              Row(
                children: [
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: showPicture
                        ? ElevatedButton.icon(
                            icon: Icon(Icons.replay),
                            onPressed: () => retakePicture(),
                            label: Text("Tomar otra foto"),
                          )
                        : ElevatedButton.icon(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () => takePicture(),
                            label: Text("Tomar foto"),
                          ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.05,
              )
            ],
          ),
        ),
      ),
    );
  }
}
