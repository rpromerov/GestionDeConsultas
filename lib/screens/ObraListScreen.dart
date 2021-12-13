import 'dart:ui';

import 'package:Cosemar/Widgets/loadingIndicator.dart';
import 'package:Cosemar/model/obra.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ObraListScreen extends StatefulWidget {
  static String routeName = '/ObraListScreen';
  ObraListScreen({Key key}) : super(key: key);

  @override
  _ObraListScreenState createState() => _ObraListScreenState();
}

class _ObraListScreenState extends State<ObraListScreen> {
  var viajes = <Obra>[];
  var originalViajes = <Obra>[];
  var onServerIndex = <int>[];
  NetworkProvider network;
  var serverIndexForCheck = <int>[];
  var didSetUp = false;
  var isSending = false;

  didChangeDependencies() {
    if (!didSetUp) {
      this.network = Provider.of<NetworkProvider>(context);

      print(network.currentTrip.obras == null);
      this.viajes = network.currentTrip.obras;
      this.originalViajes = network.currentTrip.obras;
      for (int i = 0; i < viajes.length; i++) {
        onServerIndex.add(viajes[i].onServerIndex);
        serverIndexForCheck.add(viajes[i].onServerIndex);
      }
      didSetUp = true;
    }

    super.didChangeDependencies();
  }

  bool serverIndexDidChange() {
    for (int i = 0; i < viajes.length; i++) {
      if (onServerIndex[i] != serverIndexForCheck[i]) {
        return true;
      }
    }
    return false;
  }

  void restoreIndices() {
    this.viajes.sort((o1, o2) {
      return o1.onServerIndex.compareTo(o2.onServerIndex);
    });
  }

  void updateIndices() {
    for (int i = 0; i < this.viajes.length; i++) {
      this.viajes[i].onServerIndex = i + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        restoreIndices();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Obras a visitar"),
        ),
        floatingActionButton: Container(
          width: 130,
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                backgroundColor: Colors.green),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Guardar",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 25,
                )
              ],
            ),
            onPressed: () {
              print("pressed");
              if (!serverIndexDidChange()) {
                Navigator.of(context).pop();
              }
              setState(() {
                isSending = true;
              });

              updateIndices();
              this.network.currentTrip.obras = viajes;
              this.network.updateObraIndex().whenComplete(() {
                Navigator.of(context).pushReplacementNamed(Login.routeName);
              });
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 15),
                  child: Text(
                    "Mantega presionado y arrastre el destino para reordenarlo",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    height: size.height * 0.75,
                    child: ReorderableListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        for (int index = 0; index < viajes.length; index++)
                          Container(
                            key: ValueKey('${viajes[index].id}'),
                            height: size.height * 0.15,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        viajes[index].nombre,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Icon(
                                        Icons.drag_handle,
                                        size: 30,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                      ],
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex--;
                        }
                        final oldPosition =
                            this.onServerIndex.removeAt(oldIndex);
                        this.onServerIndex.insert(newIndex, oldPosition);

                        print(this.viajes[newIndex].onServerIndex);
                        setState(() {
                          final item = viajes.removeAt(oldIndex);
                          viajes.insert(newIndex, item);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (isSending) LoadingIndicator()
          ],
        ),
      ),
    );
  }
}
