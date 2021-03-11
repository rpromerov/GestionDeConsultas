import 'package:Cosemar/model/geoDataManager.dart';
import 'package:Cosemar/model/obra.dart';
import 'package:Cosemar/model/trip.dart';
import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LoginWidget.dart';
import 'package:Cosemar/screens/ReceptionScreen.dart';
import 'package:Cosemar/screens/TripsScreen.dart';
import 'package:Cosemar/screens/notificationScreen.dart';
import 'package:Cosemar/screens/receptionScreenGateway.dart';
import 'package:Cosemar/screens/tripDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../Widgets/nextTripCard.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/Dashboard';

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final geoDataManager = GeoDataManager();
  var didSetup = false;

  var isReceptionAvaible = false;

  var trips = List<Trip>();
  var obras = Map<String, Obra>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!didSetup) {
      final testNetworkManager = Provider.of<NetworkProvider>(context);
      testNetworkManager.populateTrips().then((value) {
        didSetup = true;
        if (testNetworkManager.trips.isNotEmpty) {
          trips = testNetworkManager.trips
              .where((trip) => trip.stateEnum == TripStates.pending)
              .toList()
              .take(3)
              .toList();
        }

        if (testNetworkManager.currentTrip.tripID != null) {
          testNetworkManager.checkReception().then((isAvaible) {
            setState(() {
              isReceptionAvaible = isAvaible;
            });
          });
        }
      });
    }
  }

  final globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final testNetworkManager = Provider.of<NetworkProvider>(context);
    var greetingCard = Card(
        elevation: 2,
        child: Container(
            height: mediaQuery.size.height * 0.08,
            margin: EdgeInsets.all(10),
            child: FittedBox(
              child: Text(
                'Bienvenido John Doe',
                style: textStyle.headline4,
              ),
            )));

    var currentTripCard = Card(
      child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
          height: mediaQuery.size.height * 0.15,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viaje actual',
                        style: textStyle.headline6.copyWith(fontSize: 25),
                      ),
                      Row(
                        children: [
                          testNetworkManager.currentTrip.tripID != null
                              ? Text(
                                  testNetworkManager.currentObra.nombre,
                                  style: TextStyle(fontSize: 24),
                                )
                              : Text(
                                  "No ha iniciado viajes",
                                  style: TextStyle(fontSize: 24),
                                )
                        ],
                      )
                    ],
                  ),
                ),
                RaisedButton(
                    color: testNetworkManager.currentTrip.tripID != null
                        ? Theme.of(context).accentColor
                        : Theme.of(context).disabledColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      if (testNetworkManager.currentTrip.tripID != null) {
                        Navigator.of(context).pushNamed(
                            TripDetailScreen.routeName,
                            arguments: testNetworkManager.currentTrip);
                      }
                    },
                    child: Text(
                      'Ver',
                      style: textStyle.button.copyWith(color: Colors.white),
                    ))
              ])),
    );

    var receptionButton = testNetworkManager.currentTrip.stateEnum ==
            TripStates.toDepot
        ? RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: isReceptionAvaible
                ? Theme.of(context).accentColor
                : Theme.of(context).disabledColor,
            onPressed: () {
              geoDataManager
                  .isReceptionAvaible(
                      testNetworkManager.currentDepot.coordinates['lat'],
                      testNetworkManager.currentDepot.coordinates['lon'])
                  .then((isAvaible) {
                setState(() {
                  isReceptionAvaible = isAvaible;
                });
                isAvaible
                    ? Navigator.of(context)
                        .pushNamed(ReceptionScreenGateway.routeName)
                    : globalKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          testNetworkManager.currentTrip.tripID != null
                              ? "Recepcion no disponible, distancia con la bodega es muy grande"
                              : "Recepcion no disponible, debe haber iniciado un viaje",
                          style: TextStyle(fontSize: 20),
                        ),
                      ));
              });
            },
            child: Container(
              padding: EdgeInsets.all(10),
              height: mediaQuery.size.height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Realizar recepción',
                    style: textStyle.button
                        .copyWith(fontSize: 20, color: Colors.white),
                  ),
                  Icon(Icons.arrow_forward, size: 25, color: Colors.white),
                ],
              ),
            ),
          )
        : RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: isReceptionAvaible
                ? Theme.of(context).accentColor
                : Theme.of(context).disabledColor,
            onPressed: () {
              geoDataManager
                  .isReceptionAvaible(testNetworkManager.currentObra.latitud,
                      testNetworkManager.currentObra.longitud)
                  .then((isAvaible) {
                setState(() {
                  isReceptionAvaible = isAvaible;
                });
                isAvaible
                    ? Navigator.of(context)
                        .pushNamed(ReceptionScreenGateway.routeName)
                    : globalKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          testNetworkManager.currentTrip.tripID != null
                              ? "Recepcion no disponible, distancia con el cliente es muy grande"
                              : "Recepcion no disponible, debe haber iniciado un viaje",
                          style: TextStyle(fontSize: 20),
                        ),
                      ));
              });
            },
            child: Container(
              padding: EdgeInsets.all(10),
              height: mediaQuery.size.height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Realizar recepción',
                    style: textStyle.button
                        .copyWith(fontSize: 20, color: Colors.white),
                  ),
                  Icon(Icons.arrow_forward, size: 25, color: Colors.white),
                ],
              ),
            ),
          );

    void logoutConfirmation(BuildContext ctx) {
      final confirmationAlert = AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text("¿Está seguro?"),
        actions: [
          FlatButton(
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => {Navigator.of(context).pop()},
          ),
          FlatButton(
            child: Text(
              "Salir",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => testNetworkManager.logOut(() => {
                  Navigator.of(context).pop(),
                  Navigator.of(context).pushReplacementNamed(Login.routeName)
                }),
          ),
        ],
      );
      showDialog(context: ctx, builder: (ctx) => confirmationAlert);
    }

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        centerTitle: true,
        title: Container(
            width: mediaQuery.size.width * 0.6,
            child: Image.asset('Assets/images/cosemarText.png')),
        leading: IconButton(
          icon: Icon(
            Icons.logout,
          ),
          onPressed: () => logoutConfirmation(context),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.replay_rounded),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(Login.routeName);
              })
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            //greetingCard,
            SizedBox(
              height: mediaQuery.size.height * 0.0,
            ),
            receptionButton,
            SizedBox(
              height: mediaQuery.size.height * 0.03,
            ),
            currentTripCard,
            SizedBox(height: mediaQuery.size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Proximos Viajes',
                  style: textStyle.headline6,
                ),
                OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(TripsScreen.routeName);
                    },
                    child: Text('Ver todos'))
              ],
            ),
            !didSetup
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    height: mediaQuery.size.height * 0.35,
                    child: Column(children: <Widget>[
                      for (var trip in trips)
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, TripDetailScreen.routeName,
                              arguments: trip),
                          child: NextTripCard(
                            mediaQuery: mediaQuery,
                            textStyle: textStyle,
                            destination: testNetworkManager
                                .fetchObraByID(trip.obraID)
                                .nombre,
                            origin: 'Cosemar',
                            time: DateFormat.jm()
                                .format(trip.programmedArrivalTime),
                            state: trip.stateEnum,
                          ),
                        ),
                    ]))
          ],
        ),
      ),
    );
  }
}