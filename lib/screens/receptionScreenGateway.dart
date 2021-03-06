import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LandfillReceptionScreen.dart';
import 'package:Cosemar/screens/clientReceptionScreen.dart';
import 'package:Cosemar/screens/clientReceptionScreenCamera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReceptionScreenGateway extends StatelessWidget {
  static const routeName = '/receptionScreen';

  ReceptionScreenGateway();
  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    if (networkProvider.currentTrip.stateEnum == TripStates.onRoute ||
        networkProvider.currentTrip.stateEnum == TripStates.onClient) {
      return ClientReceptionScreenCamera();
    } else {
      return LandfillReceptionScreen();
    }
  }
}
