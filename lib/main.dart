import 'dart:io';

import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/CancelTripScreen.dart';
import 'package:Cosemar/screens/Dashboard.dart';
import 'package:Cosemar/screens/LandfillReceptionScreen.dart';
import 'package:Cosemar/screens/NotificationScreen.dart';
import 'package:Cosemar/screens/ReceptionScreen.dart';
import 'package:Cosemar/screens/TripsScreen.dart';
import 'package:Cosemar/screens/receptionScreenGateway.dart';
import 'package:Cosemar/screens/tripDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/LoginWidget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: NetworkProvider(),
      builder: (ctx, _) => MaterialApp(
        title: 'Cosemar',
        home: Login(),
        theme: ThemeData(primarySwatch: Colors.green),
        routes: {
          Dashboard.routeName: (ctx) => Dashboard(),
          TripsScreen.routeName: (ctx) => TripsScreen(),
          NotificationScreen.routeName: (ctx) => NotificationScreen(),
          TripDetailScreen.routeName: (ctx) => TripDetailScreen(),
          ReceptionScreen.routeName: (ctx) => ReceptionScreen(),
          Login.routeName: (ctx) => Login(),
          CancelTripScreen.routeName: (ctx) => CancelTripScreen(),
          ReceptionScreenGateway.routeName: (ctx) => ReceptionScreenGateway()
        },
      ),
    );
  }
}
