import 'dart:convert';
import 'dart:io';

import 'package:Cosemar/Widgets/CameraManager.dart';
import 'package:Cosemar/Widgets/loadingIndicator.dart';
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
  String imagePath;

  var isCameraControllerReady = false;

  @override
  void initState() {
    super.initState();
  }

  final cameraWidgetState = GlobalKey<CameraWidgetState>();
  Image picture;
  var showPicture = false;

  void takePicture() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (ctx) => CameraWidget(
                  key: cameraWidgetState,
                )))
        .then((val) {
      imagePath = cameraWidgetState.currentState.getImagePath();
      final file = File(imagePath);

      setState(() {
        picture = Image.file(file);
        showPicture = true;
      });
    });
  }

  void retakePicture() {
    picture = null;
    setState(() {
      showPicture = false;
    });
    takePicture();
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
    showDialog(
      context: ctx,
      builder: (ctx) {
        return alert;
      },
    );
  }

  Future<String> encodeImage() async {
    final filePath = imagePath;
    final byteData = await File(filePath).readAsBytes();
    final base64EncodedImage = base64Encode(byteData);
    return base64EncodedImage;
  }

  Future<void> sendLandfillReception(BuildContext ctx) async {
    final network = Provider.of<NetworkProvider>(ctx, listen: false);
    final encodedImage = await encodeImage();
    network
        .sendLandfillReception(
            base64Image: encodedImage,
            name: nameTextForm.text,
            observations: observationTextField.text,
            tons: tonTextFieldController.text.replaceAll(",", "."))
        .then((_) {
      Navigator.of(context).pushReplacementNamed(Login.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final network = Provider.of<NetworkProvider>(context);
    final size = MediaQuery.of(context).size;
    var isLoading = false;
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
        onPressed: () {
          isLoading = true;
          sendLandfillReception(context).then((v) {
            setState(() {
              isLoading = false;
            });
          });
        },
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                            controller: nameTextForm,
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
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
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
                            controller: observationTextField,
                            validator: (value) => null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
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
                      Spacer()
                    ],
                  ),
                  Container(
                    height: size.height * 0.6,
                    width: size.width * 0.6,
                    child: showPicture
                        ? Image(
                            image: picture.image,
                            fit: BoxFit.fill,
                          )
                        : Container(),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  )
                ],
              ),
            ),
          ),
          if (isLoading) LoadingIndicator()
        ],
      ),
    );
  }
}
