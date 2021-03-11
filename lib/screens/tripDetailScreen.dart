import 'package:Cosemar/Widgets/DetailButton.dart';
import 'package:Cosemar/Widgets/loadingIndicator.dart';
import 'package:Cosemar/model/trip.dart';
import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/CancelTripScreen.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:Cosemar/screens/ReceptionScreen.dart';
import 'package:Cosemar/screens/receptionScreenGateway.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({Key key}) : super(key: key);
  static const routeName = '/tripDetailScreen';

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  var isLoading = false;
  void launchWaze(String address) async {
    var url = 'waze://?ll=$address,chile';
    var fallbackUrl = 'https://waze.com/ul?ll=$address,chile&navigate=yes';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  void launchGoogleMaps(String address) async {
    var url = 'google.navigation:q=$address,chile';
    var fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=$address,chile';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  String stateText(Trip trip) {
    switch (trip.stateEnum) {
      case TripStates.canceled:
        return "Cancelado";
        break;
      case TripStates.pending:
        return "Pendiente";

      default:
        return "Actual";
    }
  }

  void showAlertDialog(
    String message,
    BuildContext context,
  ) {
    final alert = AlertDialog(
      actions: [
        FlatButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(Login.routeName),
          child: Text("Ok"),
        )
      ],
      title: Text("Viaje Iniciado correctamente"),
    );
    showDialog(builder: (ctx) => alert, context: context);
  }

  var globalKey = GlobalKey<ScaffoldState>();

  Widget navBarButton(
      TripStates tripState, String tripID, BuildContext context) {
    final networkManager = Provider.of<NetworkProvider>(context);

    switch (tripState) {
      case TripStates.pending:
        return FlatButton(
          onPressed: () {
            print("iniciando viaje...");
            setState(() {
              isLoading = true;
            });

            if (networkManager.currentTrip.tripID == null) {
              networkManager.startTrip(tripID).whenComplete(() {
                showAlertDialog(
                  "Viaje iniciado correctamente",
                  context,
                );
                setState(() {
                  isLoading = false;
                });
              });
            }
            setState(() {
              isLoading = false;
            });
          },
          child: Row(
            children: [
              Text(
                'Iniciar',
                style: TextStyle(color: Colors.white),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              )
            ],
          ),
        );
        break;
      default:
        return FlatButton(
          onPressed: () {
            setState(() {
              isLoading = true;
            });

            if (networkManager.currentTrip.tripID == tripID &&
                networkManager.currentTrip != null) {
              networkManager.checkReception().then((isAvaible) {
                print(isAvaible);
                isAvaible
                    ? Navigator.of(context)
                        .pushNamed(ReceptionScreenGateway.routeName)
                    : globalKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          networkManager.currentTrip.tripID != null
                              ? "Recepcion no disponible, distancia con el cliente es muy grande"
                              : "Recepcion no disponible, debe haber iniciado un viaje",
                          style: TextStyle(fontSize: 20),
                        ),
                      ));

                setState(() {
                  isLoading = false;
                });
              });
            } else {}
            setState(() {
              isLoading = false;
            });
          },
          child: Row(
            children: [
              Text(
                'Recepcion',
                style: TextStyle(color: Colors.white),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              )
            ],
          ),
        );
    }
  }

  List<DetailButton> detailButtons(TripStates tripState, BuildContext ctx) {
    final network = Provider.of<NetworkProvider>(ctx);
    final obra = network.currentObra;
    final navButton = DetailButton(
      color: Colors.blueAccent,
      text: 'Navegar',
      icon: Icons.navigation,
      function: () {
        try {
          launchWaze("${obra.direccion},${obra.comuna}");
        } catch (error) {
          launchGoogleMaps("${obra.direccion},${obra.comuna}");
        }
      },
    );
    final cancelButton = DetailButton(
      color: Colors.redAccent,
      text: 'Cancelar Viaje',
      icon: Icons.cancel,
      function: () {
        Navigator.of(context).pushNamed(CancelTripScreen.routeName);
      },
    );
    final finishButton = DetailButton(
      color: Colors.green,
      text: 'Finalizar Viaje',
      icon: Icons.check,
      function: () {
        showDialog(
          context: ctx,
          builder: (ctx) {
            return AlertDialog(
              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text("Finalizar Viaje"),
                  onPressed: () {
                    network.finishTrip().then((onValue) {});
                  },
                )
              ],
            );
          },
        );
      },
    );

    switch (tripState) {
      case TripStates.onRoute:
        return [navButton];
        break;
      case TripStates.toDepot:
        return [navButton, finishButton];
      case TripStates.onClient:
        return [cancelButton];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkManager = Provider.of<NetworkProvider>(context);
    final Trip trip = ModalRoute.of(context).settings.arguments;
    final obra = networkManager.fetchObraByID(trip.obraID);
    final mediaQuery = MediaQuery.of(context);
    final detailButtonsList = detailButtons(trip.stateEnum, context);
    var tripDataCard = Card(
      elevation: 3,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [DetailText('Origen'), DetailText("Cosemar")],
          ),
          Divider(
            thickness: 1.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [DetailText('Destino'), DetailText(obra.nombre)],
          ),
          Divider(
            thickness: 1.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [DetailText('Estado'), DetailText(stateText(trip))],
          ),
          Divider(
            thickness: 1.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DetailText('Hora salida'),
              DetailText(DateFormat.jm().format(trip.programmedArrivalTime))
            ],
          ),
          Divider(
            thickness: 1.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DetailText('Hora llegada'),
              DetailText(DateFormat.jm().format(trip.programmedReturnTime))
            ],
          ),
        ],
      ),
    );
    return Stack(children: [
      Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text('Detalle del viaje'),
          actions: [navBarButton(trip.stateEnum, trip.tripID, context)],
        ),
        body: Stack(children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  child: tripDataCard,
                ),
                SizedBox(
                  height: 0,
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: Card(
                      elevation: 3,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10, left: 15),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 35,
                                ),
                                Text(
                                  'Contacto',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          Row(
                            children: [
                              DetailText('Nombre'),
                              DetailText(obra.nombreEncargado)
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          Row(
                            children: [
                              DetailText('Teléfono'),
                              Spacer(),
                              FlatButton(
                                onPressed: () =>
                                    launch("tel://${obra.telefono}"),
                                child: Container(
                                  child: Text(
                                    obra.telefono,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .copyWith(
                                          fontSize: 20,
                                          color: Colors.blue,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                DetailText('Dirección'),
                                DetailText('${obra.direccion},${obra.comuna}')
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                          )
                        ],
                      )),
                ),
                ListView(
                  children: [...detailButtonsList],
                )
              ],
            ),
          ),
        ]),
      ),
      //Loading indicator
      isLoading ? LoadingIndicator() : Container()
    ]);
  }
}

class DetailText extends StatelessWidget {
  final String text;
  DetailText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 20),
      ),
    );
  }
}
