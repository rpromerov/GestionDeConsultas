import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:Cosemar/Widgets/CameraManager.dart';
import 'package:Cosemar/Widgets/ReceptionStepper.dart';
import 'package:Cosemar/Widgets/SignatureWidget.dart';
import 'package:Cosemar/Widgets/Stepper.dart';
import 'package:Cosemar/Widgets/loadingIndicator.dart';
import 'package:Cosemar/main.dart';
import 'package:Cosemar/model/equipment.dart';
import 'package:Cosemar/model/tarros.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:Cosemar/screens/tripDetailScreen.dart';
import 'package:dart_rut_validator/dart_rut_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:provider/provider.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class ClientReceptionScreenCamera extends StatefulWidget {
  static const String routeName = "/ClientReceptionScreenCamera";

  @override
  _ClientReceptionScreenStateCamera createState() =>
      _ClientReceptionScreenStateCamera();
}

class _ClientReceptionScreenStateCamera
    extends State<ClientReceptionScreenCamera> {
  GlobalKey _scaffold = GlobalKey();
  void showConfirmationDialog(BuildContext scaffoldContext) {
    final alert = AlertDialog(
      title: Text("Recepción enviada correctamente"),
      actions: [
        TextButton(
          child: Text("Ok"),
          onPressed: () {
            GlobalNavigator.navigatorKey.currentState
                .pushReplacementNamed(Login.routeName);
          },
        )
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: scaffoldContext,
      builder: (ctx) {
        return alert;
      },
    );
  }

  Map<String, String> _formInfo = Map();

  final _formKey = GlobalKey<FormState>();

  bool validarRut(String rut) {
    return true;
  }

  Future<String> encodeImage() async {
    final filePath = imagePath;
    final byteData = await File(filePath).readAsBytes();
    final compressedData =
        await FlutterImageCompress.compressWithList(byteData, quality: 60);
    final base64EncodedImage = base64Encode(compressedData);
    return base64EncodedImage;
  }

  Future<void> sendClientReception(BuildContext ctx) async {
    final network = Provider.of<NetworkProvider>(ctx, listen: false);
    final encodedImage = await encodeImage();
    network
        .sendClientReception(
            base64Firma: encodedImage,
            nombre: _formInfo['name'],
            rut: RUTValidator.deFormat(_formInfo['rut']),
            observaciones: _formInfo['observacion'],
            equipoRetiradoID: equipoARetirarID,
            kgRetirados: _formInfo['kilos'])
        .whenComplete(() {
      showConfirmationDialog(ctx);
    });
  }

  String imagePath;
  Image picture;
  var showPicture = false;
  var isLoading = false;
  var equipoARetirarID = '';
  final rutController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final networkManager = Provider.of<NetworkProvider>(context);
    final size = MediaQuery.of(context).size;
    final _signatureKey = GlobalKey<SignatureState>();
    final signatureWidget = Signature(
      key: _signatureKey,
    );

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
          child: SizedBox(
            width: 175,
            height: 50,
            child: showPicture
                ? ElevatedButton.icon(
                    icon: Icon(Icons.replay),
                    onPressed: () => retakePicture(),
                    label: Text("Tomar otra foto",
                        style: Theme.of(context).textTheme.button.copyWith(
                              fontSize: 15,
                              color: Colors.white,
                            )),
                  )
                : ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => takePicture(),
                    label: Text("Tomar foto",
                        style: Theme.of(context).textTheme.button.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            )),
                  ),
          ),
        ),
        Spacer()
      ],
    );
    var floatingButton = Container(
      width: 100,
      height: 50,
      child: RaisedButton(
        color: Colors.blueAccent,
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
          print("pressed");
          if (isLoading) {
            return;
          }
          print("passed");

          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            if (picture == null) {
              ScaffoldMessenger.of(_scaffold.currentContext)
                  .showSnackBar(SnackBar(
                content: Text("Debe haber tomado una foto"),
              ));
              return;
            }

            if (!isLoading) {
              setState(() {
                this.isLoading = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Enviando,puede tomar un momento'),
              ));
              print("sending");
              sendClientReception(context).whenComplete(() {});
            }
          }
        },
      ),
    );

    void onChangedApplyFormat(String text) {
      RUTValidator.formatFromTextController(rutController);
    }

    final dropdown = SizedBox(
        width: size.width * 0.9,
        child: SearchableDropdown.single(
          items:
              //networkManager.currentTrip.obras[0].equiposParaRetiro
              [].map((equipo) {
            return DropdownMenuItem(
              onTap: () {
                return;
              },
              value: equipo.equipmentID,
              child: Text(
                equipo.name,
                style: TextStyle(fontSize: 20),
              ),
            );
          }).toList(),
          onChanged: (equipoARetirarID) {
            this.equipoARetirarID = (equipoARetirarID as String);
            print(this.equipoARetirarID);
          },
          hint: "Equipo no seleccionado",
          isExpanded: true,
          label: Text('Equipo a retirar'),
          searchHint: Text("Seleccione el equipo a retirar"),
          displayClearIcon: true,
          onClear: () {
            equipoARetirarID = '';
          },
        ));

    var noticeShown = true;
    final notice = AlertDialog(
      actions: [
        TextButton(
          child: Text("Ok"),
          onPressed: () {
            noticeShown = true;
            Navigator.of(context).pop();
          },
        )
      ],
      title: Text("Atención"),
      content: SingleChildScrollView(
        child: Text(
            "Por favor informar a cliente que serán cobro adicional los tarros superados de lo contratado."),
      ),
    );

    final steppers = Card(
      elevation: 1,
      child: Column(
        children: [
          ReceptionStepper(
            stepperText: "TARRO 120LTS",
            intialValue: networkManager.currentTrip.obras[0].tarros.cantidad120,
            onDecrease: () {
              networkManager.currentTrip.obras[0].tarros.cantidad120 -= 1;
            },
            onIncrease: () {
              if (!noticeShown &&
                  networkManager.currentTrip.obras[0].tarros.cantidad120 >
                      networkManager.currentTrip.obras[0].tarros.allowance120) {
                showDialog(
                    builder: (context) => notice,
                    context: context,
                    barrierDismissible: false);
              }
              networkManager.currentTrip.obras[0].tarros.cantidad120 += 1;
            },
          ),
          ReceptionStepper(
            stepperText: "TARRO 240LTS",
            intialValue: networkManager.currentTrip.obras[0].tarros.cantidad240,
            onDecrease: () {
              networkManager.currentTrip.obras[0].tarros.cantidad240 -= 1;
            },
            onIncrease: () {
              if (!noticeShown &&
                  networkManager.currentTrip.obras[0].tarros.cantidad240 >
                      networkManager.currentTrip.obras[0].tarros.allowance240) {
                showDialog(
                    builder: (context) => notice,
                    context: context,
                    barrierDismissible: false);
              }
              networkManager.currentTrip.obras[0].tarros.cantidad240 += 1;
            },
          ),
          ReceptionStepper(
            stepperText: "TARRO 360LTS",
            intialValue: networkManager.currentTrip.obras[0].tarros.cantidad360,
            onDecrease: () {
              networkManager.currentTrip.obras[0].tarros.cantidad360 -= 1;
            },
            onIncrease: () {
              if (!noticeShown &&
                  networkManager.currentTrip.obras[0].tarros.cantidad360 >
                      networkManager.currentTrip.obras[0].tarros.allowance360) {
                showDialog(
                    builder: (context) => notice,
                    context: context,
                    barrierDismissible: false);
              }
              networkManager.currentTrip.obras[0].tarros.cantidad360 += 1;
            },
          ),
          ReceptionStepper(
            stepperText: "TARRO 770LTS",
            intialValue: networkManager.currentTrip.obras[0].tarros.cantidad770,
            onDecrease: () {
              networkManager.currentTrip.obras[0].tarros.cantidad770 -= 1;
            },
            onIncrease: () {
              if (!noticeShown &&
                  networkManager.currentTrip.obras[0].tarros.cantidad770 >
                      networkManager.currentTrip.obras[0].tarros.allowance770) {
                showDialog(
                    builder: (context) => notice,
                    context: context,
                    barrierDismissible: false);
              }
              networkManager.currentTrip.obras[0].tarros.cantidad770 += 1;
            },
          ),
          ReceptionStepper(
            stepperText: "TARRO 1000LTS",
            intialValue:
                networkManager.currentTrip.obras[0].tarros.cantidad1000,
            onDecrease: () {
              networkManager.currentTrip.obras[0].tarros.cantidad1000 -= 1;
            },
            onIncrease: () {
              if (!noticeShown &&
                  networkManager.currentTrip.obras[0].tarros.cantidad1000 >
                      networkManager
                          .currentTrip.obras[0].tarros.allowance1000) {
                showDialog(
                    builder: (context) => notice,
                    context: context,
                    barrierDismissible: false);
              }
              networkManager.currentTrip.obras[0].tarros.cantidad1000 += 1;
            },
          ),
          ReceptionStepper(
            stepperText: "TARRO 1100LTS",
            intialValue:
                networkManager.currentTrip.obras[0].tarros.cantidad1100,
            onDecrease: () {
              networkManager.currentTrip.obras[0].tarros.cantidad1100 -= 1;
            },
            onIncrease: () {
              if (!noticeShown &&
                  networkManager.currentTrip.obras[0].tarros.cantidad1100 >
                      networkManager
                          .currentTrip.obras[0].tarros.allowance1100) {
                showDialog(
                    builder: (context) => notice,
                    context: context,
                    barrierDismissible: false);
              }
              networkManager.currentTrip.obras[0].tarros.cantidad1100 += 1;
            },
          )
        ],
      ),
    );

    return Scaffold(
      key: _scaffold,
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
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: cameraButton),
                        SizedBox(
                          width: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                            width: 130,
                            child: floatingButton,
                          ),
                        )
                      ],
                    ),
                  ),
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
                          controller: rutController,
                          decoration: const InputDecoration(
                              labelText: "RUT",
                              hintText: "RUT de quien recibe."),
                          textInputAction: TextInputAction.next,
                          validator:
                              RUTValidator(validationErrorText: "Rut no válido")
                                  .validator,
                          onSaved: (rut) => _formInfo['rut'] = rut,
                          onChanged: onChangedApplyFormat,
                        ),
                        if (networkManager.currentTrip.tipoViaje != 2)
                          TextFormField(
                            initialValue: "",
                            decoration: const InputDecoration(
                                labelText: "Kilogramos retirados",
                                hintText:
                                    "Cuantos Kg se retiraron del cliente."),
                            textInputAction: TextInputAction.done,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (kg) => kg.isNotEmpty
                                ? null
                                : "Debe ingresar los kilogramos retirados",
                            onSaved: (kg) => _formInfo['kilos'] = kg,
                          ),
                        TextFormField(
                            validator: (value) => null,
                            decoration: const InputDecoration(
                              labelText: "Observaciones.",
                            ),
                            textInputAction:
                                networkManager.currentTrip.tipoViaje == 2
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                            onSaved: (observation) =>
                                _formInfo['observacion'] = observation),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (networkManager.currentTrip.tipoViaje != 2) dropdown,
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (showPicture) cameraStack,
                  if (networkManager.currentTrip.tipoViaje == 2) steppers,
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
    );
  }
}
