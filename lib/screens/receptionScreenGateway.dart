import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:Cosemar/providers/networkProvider.dart';
import 'package:Cosemar/screens/LandfillReceptionScreen.dart';
import 'package:Cosemar/screens/clientReceptionScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReceptionScreenGateway extends StatelessWidget {
  static const routeName = '/receptionScreen';
  const ReceptionScreenGateway({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    print(networkProvider.currentTrip.stateEnum);
    return Container(
      child: networkProvider.currentTrip.stateEnum == TripStates.deposing
          ? LandfillReceptionScreen()
          : ClientReceptionScreen(),
    );
  }
}
