import 'package:Cosemar/Widgets/DetailButton.dart';
import 'package:Cosemar/Widgets/loadingIndicator.dart';
import 'package:Cosemar/model/equipment.dart';
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
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({Key key}) : super(key: key);
  static const routeName = '/tripDetailScreen';

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
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
              title: Text("Finalizar viaje"),
              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text("Finalizar Viaje"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    network.finishTrip().then((onValue) {
                      Navigator.pushReplacementNamed(context, Login.routeName);
                    });
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
      case TripStates.onDepot:
        return [navButton, finishButton];
      case TripStates.onClient:
        return [cancelButton];

      default:
        return [];
    }
  }

  var isLoading = false;

  void toggleLoading(bool s) {
    globalKey.currentState.setState(() {
      isLoading = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    final networkManager = Provider.of<NetworkProvider>(context);
    final Trip trip = ModalRoute.of(context).settings.arguments;
    final obra = networkManager.fetchObraByID(trip.obraID);
    final mediaQuery = MediaQuery.of(context);
    final detailButtonsList = detailButtons(trip.stateEnum, context);
    Widget navBarButton(
      TripStates tripState,
      String tripID,
    ) {
      switch (tripState) {
        case TripStates.pending:
          return FlatButton(
            onPressed: () {
              print("iniciando viaje...");
              toggleLoading(true);

              if (networkManager.currentTrip.tripID == null) {
                networkManager.startTrip(tripID).whenComplete(() {
                  showAlertDialog(
                    "Viaje iniciado correctamente",
                    context,
                  );
                  toggleLoading(false);
                });
              }
              toggleLoading(false);
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
                this.isLoading = true;
              });

              if (networkManager.currentTrip.tripID == tripID &&
                  networkManager.currentTrip != null) {
                networkManager.checkReception().then((isAvaible) {
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
                    this.isLoading = false;
                  });
                });
              } else {}
              setState(() {
                this.isLoading = false;
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
            children: [
              DetailText('Estado'),
              DetailText(trip.stateEnum.asString)
            ],
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
    Equipment currentEquipment = networkManager.currentTrip.equipment;
    var equipmentCard = Card(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DetailText("Equipo"),
        trip.stateEnum != TripStates.pending
            ? DetailText(trip.avaibleEquipment.isEmpty
                ? "Sin equipo"
                : trip.equipment.name)
            : SearchableDropdown(
                hint: trip.avaibleEquipment == null
                    ? "Sin equipo"
                    : trip.equipment.name,
                onChanged: (value) {
                  setState(() {
                    currentEquipment = value as Equipment;
                    networkManager.currentTrip.equipmentID =
                        currentEquipment.equipmentID;
                    networkManager.currentTrip.equipment = currentEquipment;
                  });
                },
                items: trip.avaibleEquipment.map((equipment) {
                  return DropdownMenuItem(
                    child: Text(
                      trip.avaibleEquipment.isEmpty
                          ? "Sin equipo"
                          : "${equipment.name}",
                      style: TextStyle(fontSize: 20),
                    ),
                    onTap: () {},
                    value: equipment,
                  );
                }).toList(),
              ),
      ],
    ));
    return Stack(children: [
      Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text('Detalle del viaje'),
          actions: [
            if (trip.stateEnum == TripStates.onClient ||
                trip.stateEnum == TripStates.toClient ||
                trip.stateEnum == TripStates.onLandfill ||
                trip.stateEnum == TripStates.deposing ||
                trip.stateEnum == TripStates.pending)
              navBarButton(trip.stateEnum, trip.tripID)
          ],
        ),
        body: Stack(children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  child: equipmentCard,
                ),
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
                                onPressed: () {
                                  setState(() {
                                    toggleLoading(!isLoading);
                                  });
                                  //launch("tel://${obra.telefono}");
                                },
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
                Container(
                  height:
                      mediaQuery.size.height * 0.2 * detailButtonsList.length,
                  child: ListView(
                    children: [...detailButtonsList],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
      //Loading indicator
      if (isLoading) LoadingIndicator()
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
