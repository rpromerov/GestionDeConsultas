import 'dart:io';

import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/CancelTripScreen.dart';
import 'package:Cosemar/screens/Dashboard.dart';
import 'package:Cosemar/screens/LandfillReceptionScreen.dart';
import 'package:Cosemar/screens/NotificationScreen.dart';
import 'package:Cosemar/screens/ObraListScreen.dart';
import 'package:Cosemar/screens/ReceptionScreen.dart';
import 'package:Cosemar/screens/TripsScreen.dart';
import 'package:Cosemar/screens/clientReceptionScreen.dart';
import 'package:Cosemar/screens/clientReceptionScreenCamera.dart';
import 'package:Cosemar/screens/receptionScreenGateway.dart';
import 'package:Cosemar/screens/tripDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/LoginWidget.dart';

class GlobalNavigator {
  static var navigatorKey = GlobalKey<NavigatorState>();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  runApp(new Main());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: NetworkProvider(),
      builder: (ctx, _) => MaterialApp(
        navigatorKey: GlobalNavigator.navigatorKey,
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
          ReceptionScreenGateway.routeName: (ctx) => ReceptionScreenGateway(),
          ClientReceptionScreenCamera.routeName: (ctx) =>
              ClientReceptionScreen(),
          ObraListScreen.routeName: (ctx) => ObraListScreen()
        },
      ),
    );
  }
}
