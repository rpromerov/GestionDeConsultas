import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Cosemar/Widgets/CameraManager.dart';
import 'package:Cosemar/Widgets/SignatureWidget.dart';
import 'package:Cosemar/Widgets/loadingIndicator.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:dart_rut_validator/dart_rut_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:provider/provider.dart';

class ClientReceptionScreenCamera extends StatefulWidget {
  static const String routeName = "/ClientReceptionScreenCamera";
  const ClientReceptionScreenCamera({Key key}) : super(key: key);

  @override
  _ClientReceptionScreenStateCamera createState() =>
      _ClientReceptionScreenStateCamera();
}

class _ClientReceptionScreenStateCamera
    extends State<ClientReceptionScreenCamera> {
  void showAlertDialog(
    String message,
    BuildContext context,
  ) {
    final alert = AlertDialog(
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(Login.routeName),
          child: Text("Ok"),
        )
      ],
      title: Text("Recepcion iniciada correctamente"),
    );
    showDialog(builder: (ctx) => alert, context: context);
  }

  Map<String, String> _formInfo = Map();

  final _formKey = GlobalKey<FormState>();

  bool validarRut(String rut) {
    return true;
  }

  String imagePath;
  Image picture;
  var showPicture = false;
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    final networkManager = Provider.of<NetworkProvider>(context);
    final size = MediaQuery.of(context).size;
    final _signatureKey = GlobalKey<SignatureState>();
    final signatureWidget = Signature(
      key: _signatureKey,
    );
    final scaffoldKey = GlobalKey<ScaffoldState>();

    final cameraWidgetState = GlobalKey<CameraWidgetState>();

    // Future<void> takePicture() async {
    //   final image = await cameraWidgetState.currentState.takePicture();
    //   imagePath = cameraWidgetState.currentState.getImagePath();
    //   picture = image;
    //   setState(() {
    //     showPicture = true;
    //   });
    // }
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

    Future<String> encodeImage() async {
      final filePath = imagePath;
      final byteData = await File(filePath).readAsBytes();
      final base64EncodedImage = base64Encode(byteData);
      return base64EncodedImage;
    }

    Future<void> sendClientReception(BuildContext ctx) async {
      final network = Provider.of<NetworkProvider>(ctx, listen: false);
      final encodedImage = await encodeImage();
      network
          .sendClientReception(
              base64Firma: encodedImage,
              nombre: _formInfo['name'],
              rut: _formInfo['rut'],
              observaciones: _formInfo['observacion'])
          .then((_) {
        Navigator.of(context).pushReplacementNamed(Login.routeName);
      });
    }

    var cameraStack = Container(
      height: size.height * 0.6,
      width: size.width * 0.6,
      child: showPicture
          ? Image(
              image: picture.image,
              fit: BoxFit.fill,
            )
          : Container(),
    );

    var cameraButton = Row(
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
    );
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
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            if (picture == null) {
              scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Debe haber tomado una foto"),
              ));
              return;
            }
            setState(() {
              isLoading = true;
            });
            sendClientReception(context).then((val) {
              setState(() {
                isLoading = false;
              });
            });
          }
        },
      ),
    );
    final rutController = TextEditingController();
    void onChangedApplyFormat(String text) {
      RUTValidator.formatFromTextController(rutController);
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Recepcion cliente"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: "",
                          decoration: const InputDecoration(
                              labelText: "Nombre",
                              hintText: "Nombre de quien recibe."),
                          textInputAction: TextInputAction.next,
                          validator: (name) => name.isNotEmpty
                              ? null
                              : "Debe ingresar el nombre de quien recibe",
                          onSaved: (name) => _formInfo['name'] = name,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: "RUT",
                              hintText: "RUT de quien recibe."),
                          textInputAction: TextInputAction.next,
                          validator:
                              RUTValidator(validationErrorText: "Rut no válido")
                                  .validator,
                          onSaved: (rut) => _formInfo['rut'] = rut,
                        ),
                        TextFormField(
                            validator: (value) => null,
                            decoration: const InputDecoration(
                              labelText: "Observaciones.",
                            ),
                            textInputAction: TextInputAction.done,
                            onSaved: (observation) =>
                                _formInfo['observacion'] = observation),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  cameraButton,
                  cameraStack,
                  SizedBox(
                    height: size.height * 0.07,
                  )
                ],
              ),
            ),
          ),
          if (isLoading) LoadingIndicator(),
        ],
      ),
      floatingActionButton: floatingButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
