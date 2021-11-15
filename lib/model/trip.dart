import 'dart:ffi';

import 'package:Cosemar/model/depot.dart';
import 'package:Cosemar/model/equipment.dart';
import 'package:Cosemar/model/obra.dart';
import 'package:Cosemar/model/tarros.dart';
import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:flutter/foundation.dart';

class Trip {
  String tripID;
  String depotId;
  String equipmentID;
  Equipment equipment;
  List<Equipment> avaibleEquipment;
  DateTime programmedArrivalTime;
  DateTime arrivalTime;
  DateTime programmedReturnTime;
  DateTime returnTime;
  DateTime programmedDepartureTime;
  double latitudSalida;
  double longitudSalida;
  double latitudVertedero;
  double longitudVertedero;
  double latitudDepot;
  double longitudDepot;
  Depot baseSalida;
  Depot vertedero;
  Depot deposito;
  int tipoViaje;
  Tarros tarros;
  TripStates get stateEnum {
    switch (tripState) {
      case 0:
        return TripStates.pending;
      case 1:
        return TripStates.onRoute;
      case 2:
        return TripStates.onClient;
      case 3:
        return TripStates.deposing;
      case 4:
        return TripStates.onLandfill;
      case 5:
        return TripStates.toDepot;
      case 6:
        return TripStates.onDepot;
      case 7:
        return TripStates.finished;
      case 8:
        return TripStates.delayed;
      case 97:

      case 99:
        return TripStates.canceled;
      default:
        return TripStates.pending;
    }
  }

  int tripState;

  List<Obra> obras = [];

  Trip(
      {this.tripID,
      this.programmedArrivalTime,
      this.arrivalTime,
      this.programmedReturnTime,
      this.returnTime,
      this.obras,
      this.tripState,
      this.programmedDepartureTime,
      this.depotId,
      this.equipmentID,
      this.latitudSalida,
      this.longitudSalida,
      this.latitudVertedero,
      this.longitudVertedero,
      this.latitudDepot,
      this.longitudDepot,
      this.avaibleEquipment,
      this.equipment,
      this.baseSalida,
      this.tipoViaje,
      this.vertedero,
      this.tarros,
      this.deposito});
}
