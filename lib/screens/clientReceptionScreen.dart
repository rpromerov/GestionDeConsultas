import 'dart:convert';
import 'dart:ui';

import 'package:Cosemar/Widgets/SignatureWidget.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:provider/provider.dart';

class ClientReceptionScreen extends StatefulWidget {
  const ClientReceptionScreen({Key key}) : super(key: key);

  @override
  _ClientReceptionScreenState createState() => _ClientReceptionScreenState();
}

class _ClientReceptionScreenState extends State<ClientReceptionScreen> {
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

  @override
  Widget build(BuildContext context) {
    final networkManager = Provider.of<NetworkProvider>(context);
    final size = MediaQuery.of(context).size;

    final _signatureKey = GlobalKey<SignatureState>();
    final signatureWidget = Signature(
      key: _signatureKey,
    );
    Future<String> base64Signature() async {
      final image = await _signatureKey.currentState.getData();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final asList = byteData.buffer.asUint8List();
      final encodedImage = base64Encode(asList);
      return encodedImage;
    }

    void _sendReception(BuildContext ctx) {
      final networkProvider = Provider.of<NetworkProvider>(ctx, listen: false);
      base64Signature().then((signature) {
        networkProvider.sendClientReception(
            nombre: _formInfo['name'],
            rut: _formInfo['rut'],
            observaciones: _formInfo['observacion'],
            base64Firma: signature);
        Navigator.of(context).pushReplacementNamed(Login.routeName);
      });
    }

    var signatureStack = Stack(children: [
      Container(
          decoration: BoxDecoration(
              border: Border.all(width: 1.5, color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          width: size.width * 0.9,
          height: size.height * 0.4,
          child: signatureWidget),
      Container(
        width: size.width * 0.9,
        height: size.height * 0.4,
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Spacer(),
            Text(
              'Acepto conforme',
              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 15),
            ),
          ],
        ),
      )
    ]);
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
            _sendReception(context);
          }
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Recepcion cliente"),
      ),
      body: Padding(
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
                          labelText: "RUT", hintText: "RUT de quien recibe."),
                      textInputAction: TextInputAction.next,
                      validator: (rut) {
                        if (rut.isNotEmpty) {
                          return validarRut(rut) ? null : "El rut no es valido";
                        } else {
                          return "Debe ingresar un rut";
                        }
                      },
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
              signatureStack
            ],
          ),
        ),
      ),
      floatingActionButton: floatingButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
