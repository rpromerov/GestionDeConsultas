import 'dart:async';
import 'dart:ui';

import 'package:Cosemar/Widgets/SignatureWidget.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReceptionScreen extends StatefulWidget {
  static const routeName = '/ReceptionScreen';

  @override
  _ReceptionScreenState createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> {
  var isSending = false;

  var didSend = false;

  void _sendReception(BuildContext ctx) {
    setState(() {
      isSending = true;
    });

    Timer(Duration(seconds: 2), () {
      setState(() {
        didSend = true;
      });

      Timer(Duration(seconds: 1), () {
        Navigator.of(ctx).pushReplacementNamed(Dashboard.routeName);
        final networkProvider =
            Provider.of<NetworkProvider>(context, listen: false);
        networkProvider.testChangeTripState();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    var signatureStack = Stack(children: [
      Container(
          decoration: BoxDecoration(
              border: Border.all(width: 1.5, color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          width: mediaQuery.size.width * 0.9,
          height: mediaQuery.size.height * 0.6,
          child: SignatureWidget(
            signatureBoardOffset: 20,
          )),
      Container(
        width: mediaQuery.size.width * 0.9,
        height: mediaQuery.size.height * 0.6,
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
    return Container(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          width: 125,
          height: 50,
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Enviar',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(fontSize: 20),
                  ),
                  Icon(
                    Icons.file_upload,
                    size: 30,
                  ),
                ],
              ),
            ),
            onPressed: () {
              _sendReception(context);
            },
          ),
        ),
        appBar: AppBar(
          title: Text('Recepción'),
        ),
        body: Container(
          padding: EdgeInsets.all(5),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  signatureStack,
                  Center(
                      child: Text(
                    'Firma del cliente',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontSize: 20),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.black12,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt),
                              Text('Subir foto')
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: mediaQuery.size.width * 0.6,
                          height: 40,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black26),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Row(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Subir foto del manifiesto',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(fontSize: 18),
                                  ),
                                ),
                              ),
                              Spacer()
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              isSending || didSend
                  ? Center(
                      child: Stack(children: [
                        Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black54),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                child: !didSend
                                    ? CircularProgressIndicator()
                                    : Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 100,
                                      ),
                                width: 100,
                                height: 100,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              !didSend ? "Enviando..." : "Enviado",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            )
                          ],
                        ),
                      ]),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
