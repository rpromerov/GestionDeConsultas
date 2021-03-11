import 'package:Cosemar/Widgets/DetailButton.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:Cosemar/screens/tripDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CancelTripScreen extends StatefulWidget {
  static const routeName = "/cancelTripScreen";
  const CancelTripScreen({Key key}) : super(key: key);

  @override
  _CancelTripScreenState createState() => _CancelTripScreenState();
}

class _CancelTripScreenState extends State<CancelTripScreen> {
  void showAlertDialog(Function onConfirm, BuildContext ctx) {
    final alert = AlertDialog(
      title: Text("Confirmación"),
      content:
          Text("Cancelará de manera permanente el viaje\n¿Desea continuar?"),
      actions: [
        FlatButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text("Retroceder"),
        ),
        FlatButton(
          onPressed: onConfirm,
          child: Text(
            "Cancelar viaje",
            style: TextStyle(color: Colors.redAccent),
          ),
        )
      ],
    );
    showDialog(context: ctx, builder: (ctx) => alert);
  }

  final commentaryField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Cancelar viaje"),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Container(
                  height: mediaQuery.size.height * 0.3,
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    maxLines: 5,
                    decoration:
                        InputDecoration(labelText: "Ingrese comentario"),
                    controller: commentaryField,
                  ),
                ),
              ),
              SizedBox(
                height: mediaQuery.size.height * 0.3,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: DetailButton(
                  color: Colors.redAccent,
                  text: 'Cancelar Viaje',
                  icon: Icons.cancel,
                  function: () {
                    showAlertDialog(() {
                      networkProvider
                          .cancelTrip(networkProvider.currentTrip.tripID);
                      Navigator.of(context)
                          .pushReplacementNamed(Login.routeName);
                    }, context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
