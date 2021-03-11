import 'dart:ffi';

import 'package:Cosemar/model/obra.dart';
import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:flutter/foundation.dart';

class Trip {
  String tripID;
  String depotId;
  DateTime programmedArrivalTime;
  DateTime arrivalTime;
  DateTime programmedReturnTime;
  DateTime returnTime;
  DateTime programmedDepartureTime;
  TripStates get stateEnum {
    switch (tripState) {
      case 0:
        return TripStates.pending;
      case 1:
        return TripStates.ongoing;
      case 2:
        return TripStates.onRoute;
      case 3:
        return TripStates.onClient;
      case 4:
        return TripStates.departedClient;
      case 5:
        return TripStates.deposing;
      case 6:
        return TripStates.toDepot;
      case 7:
        return TripStates.finished;
      case 97:

      case 99:
        return TripStates.canceled;
      default:
        return TripStates.pending;
    }
  }

  int tripState;

  String obraID;
  Obra obra;

  Trip(
      {this.tripID,
      this.programmedArrivalTime,
      this.arrivalTime,
      this.programmedReturnTime,
      this.returnTime,
      this.obraID,
      this.obra,
      this.tripState,
      this.programmedDepartureTime,
      this.depotId});
}
