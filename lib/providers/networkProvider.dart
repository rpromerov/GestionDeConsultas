import 'dart:async';
import 'dart:convert';

import 'package:Cosemar/model/depot.dart';
import 'package:Cosemar/model/equipment.dart';
import 'package:Cosemar/model/geoDataManager.dart';
import 'package:Cosemar/model/http_exception.dart';
import 'package:Cosemar/model/obra.dart';
import 'package:Cosemar/model/trip.dart';
import 'package:Cosemar/model/tripStatesEnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, base64, ascii;
import 'package:intl/intl.dart';

enum ConnectionStatus { connecting, disconnected, connected }

class NetworkProvider with ChangeNotifier {
  static String serverIp = "https://200.111.110.142:5000";
  static String get getServerIp {
    return serverIp;
  }

  NetworkProvider() {
    this.backgroundUpdate();
  }

  String _token = null;
  String _userName = null;
  String _userEmail = null;
  String _userUniqueName = null;
  String _driverID = null;
  var saveEmail = false;
  DateTime _tokenExpirationDate = null;
  var testDidFinishTrip = false;

  List<Equipment> avaibleEquipments = [];
  List<Trip> trips = [];
  var obras = Map<String, Obra>();
  var depots = Map<String, Depot>();

  var currentTrip = Trip();
  var currentObra = Obra();
  var currentDepot = Depot();

  void testChangeTripState() {
    testDidFinishTrip = true;
    notifyListeners();
  }

  String get token {
    return _token;
  }

  String get userName {
    return _userName;
  }

  String get userEmail {
    return _userEmail;
  }

  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  final geoData = GeoDataManager();

  bool isReceptionAvaible = false;

  bool checkIfLate(DateTime time) {
    if (DateTime.now().isAfter(
        trips.first.programmedDepartureTime.add(Duration(minutes: 5)))) {
      return true;
    }
    return false;
  }

  void backgroundUpdate() {
    const distanceLimit = 850;
    Timer.periodic(Duration(minutes: 1), (timer) async {
      print("fired timer");
      if (currentTrip == null) {
        final trip = trips.firstWhere((trip) {
          return trip.stateEnum == TripStates.pending ||
              trip.stateEnum == TripStates.delayed;
        });
        if (trip.stateEnum == TripStates.pending) {
          if (checkIfLate(trip.programmedDepartureTime)) {
            trip.tripState = TripStates.delayed.asInt;
            this.markTripAsLate(trip.tripID);
            notifyListeners();
          }
        }
        if (await geoData.getDistance(trip.latitudSalida, trip.longitudSalida) >
            200) {
          startTrip(trip.tripID);
          notifyListeners();
        }
      } else {
        switch (currentTrip.stateEnum) {
          case TripStates.onRoute:
            if (await geoData.getDistance(
                    currentObra.latitud, currentObra.longitud) <
                distanceLimit) {
              setTripToOnClient(currentTrip.tripID);
              currentTrip.tripState = TripStates.onClient.asInt;
              notifyListeners();
            }
            break;
          case TripStates.onClient:
            // if (await geoData.getDistance(
            //         currentObra.latitud, currentObra.longitud) >
            //     distanceLimit) {
            //   setTripToDepartingClient(currentTrip.tripID);
            //   currentTrip.tripState = TripStates.deposing.asInt;
            //   notifyListeners();
            // }
            break;
          case TripStates.deposing:
            print("deposing...");
            print(
                "${currentTrip.latitudVertedero},${currentTrip.longitudVertedero}");
            if (await geoData.getDistance(currentTrip.latitudVertedero,
                    currentTrip.longitudVertedero) <
                distanceLimit) {
              this.setTripToOnLandfill(currentTrip.tripID);
              currentTrip.tripState = TripStates.onLandfill.asInt;
              notifyListeners();
            }
            break;
          case TripStates.toDepot:
            if (await geoData.getDistance(
                    currentTrip.latitudDepot, currentTrip.longitudDepot) <
                distanceLimit) {
              this.setTripToOnDepot(currentTrip.tripID);
              currentTrip.tripState = TripStates.onDepot.asInt;
              notifyListeners();
            }
            break;
          default:
            break;
        }
      }
    });
  }

  void markTripAsLate(String tripID) async {
    final requestURL = "$getServerIp/api/Viaje/$tripID";
    final encodedState =
        jsonEncode({'IdEstadoViaje': TripStates.delayed.asInt});
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
  }

  void setTripToOnClient(String tripID) async {
    final requestURL = "$getServerIp/api/Viaje/$tripID";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.onClient.asInt,
      'llegadaCliente': encodeTime(null)
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
  }

  void setTripToDepartingClient(String tripID) async {
    final requestURL = "$getServerIp/api/Viaje/$tripID";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.deposing,
      'salidaCliente': encodeTime(null)
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
  }

  void setTripToOnLandfill(String tripID) async {
    final requestURL = "$getServerIp/api/Viaje/$tripID";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.onLandfill.asInt,
      'llegadaDispoFinal': encodeTime(null)
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
  }

  void setTripToToDepot(String tripID) async {
    final requestURL = "$getServerIp/api/Viaje/$tripID";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.toDepot.asInt,
      'salidaDispoFinal': encodeTime(null)
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
  }

  void setTripToOnDepot(String tripID) async {
    final requestURL = "$getServerIp/api/Viaje/$tripID";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.onDepot.asInt,
      'llegadaBodega': encodeTime(null)
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
  }

  Future<bool> checkReception() async {
    if (currentTrip == null) {
      return false;
    }
    return await geoData.isReceptionAvaible(
        currentTrip.stateEnum == TripStates.onLandfill
            ? currentTrip.latitudVertedero
            : currentObra.latitud,
        currentTrip.stateEnum == TripStates.onLandfill
            ? currentTrip.longitudVertedero
            : currentObra.longitud);
  }

  Future<void> changeState(String tripID, TripStates state) async {
    final requestURL = "$getServerIp/api/Viaje/$tripID";
    final encodedState = jsonEncode({
      'IdEstadoViaje': state.asInt,
      'inicio': encodeTime(null),
      'equipamiento': currentTrip.equipmentID
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
  }

  Future<void> cancelTrip(String tripID) async {
    final requestURL = "$serverIp/api/Viaje/$tripID";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.canceled.asInt,
      'llegadaBodega': encodeTime(null)
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
    currentTrip.tripState = 99;
    currentTrip = Trip();
    currentObra = Obra();
    notifyListeners();
  }

  Future<void> startTrip(String tripID) async {
    final trip = trips.firstWhere((trip) => tripID == trip.tripID);
    print("Starting trip...");
    try {
      await changeState(tripID, TripStates.onRoute);
      currentTrip = trip;
      currentObra = obras[currentTrip.obraID];
      currentTrip.tripState = TripStates.onRoute.asInt;
    } catch (e) {
      throw HttpException("Error actualizando");
    }

    notifyListeners();
  }

  Future<void> finishTrip() async {
    final requestURL = "$getServerIp/api/Viaje/${currentTrip.tripID}";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.finished.asInt,
      'llegadaBodega': encodeTime(null)
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
    trips.firstWhere((trip) => currentTrip.tripID == trip.tripID).tripState =
        TripStates.finished.asInt;
    currentTrip = Trip();
    currentDepot = Depot();
    currentObra = Obra();
  }

  Future<void> onClientReceptionSent() async {
    currentTrip.tripState = TripStates.deposing.asInt;
    final requestURL = "$serverIp/api/Viaje/${currentTrip.tripID}";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.deposing.asInt,
      'salidaCliente': encodeTime(null),
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
    currentTrip.tripState = TripStates.deposing.asInt;

    notifyListeners();
  }

  Future<void> onLandfillReceptionSent() async {
    currentTrip.tripState = TripStates.deposing.asInt;
    final requestURL = "$serverIp/api/Viaje/${currentTrip.tripID}";
    final encodedState = jsonEncode({
      'IdEstadoViaje': TripStates.toDepot.asInt,
      'salidaDispoFinal': encodeTime(null),
    });
    final response = await http.put(requestURL,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        },
        body: encodedState);
    currentTrip.tripState = TripStates.toDepot.asInt;

    notifyListeners();
  }

  Future<void> sendClientReception(
      {String nombre,
      String rut,
      String observaciones,
      String base64Firma}) async {
    final requestURL = "$serverIp/api/Recepcion/";
    final encodedState = jsonEncode({
      'IdViaje': currentTrip.tripID,
      'Recepcionado': "$nombre $rut",
      'FechaRecepcion': encodeTime(null),
      'Observaciones': observaciones,
      'Firma': base64Firma
    });
    final response = await http
        .post(requestURL,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token"
            },
            body: encodedState)
        .then((onValue) => onClientReceptionSent());
    notifyListeners();
  }

  Future<void> sendLandfillReception(
      {String base64Image,
      String tons,
      String name,
      String observations}) async {
    final requestURL = "$serverIp/api/RecepcionVertedero/";
    final encodedState = jsonEncode({
      'IdViaje': currentTrip.tripID,
      'Recepcionado': "$name",
      'FechaRecepcion': encodeTime(null),
      'Observaciones': observations,
      'ValeRecepcion': base64Image,
      'Toneladas': double.parse(tons)
    });
    final response = await http
        .post(requestURL,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token"
            },
            body: encodedState)
        .then((onValue) {
      onLandfillReceptionSent();
    });
    notifyListeners();
  }

  DateTime parseTime(String time) {
    if (time == null) {
      return DateTime.now();
    }
    DateFormat format = DateFormat("yyyy-MM-dd-HH:mm:ss");

    final date = format.parse(time.replaceAll("T", "-"));
    return date;
  }

  String encodeTime(DateTime date) {
    DateFormat format = DateFormat("yyyy-MM-ddTHH:mm:ss");
    String formattedTime;
    if (date != null) {
      formattedTime = format.format(date);
    } else {
      formattedTime = format.format(DateTime.now());
    }
    return formattedTime;
  }

  Future<Obra> fetchObra(String obraID) async {
    final obraURL = "$serverIp/api/Obra/$obraID";
    final response = await http.get(obraURL, headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    });
    final decodedResponse = jsonDecode(response.body);
    return Obra(
        nombre: decodedResponse['nombre'],
        comuna: decodedResponse['comuna'],
        direccion: decodedResponse['direccion'],
        latitud: decodedResponse['latitud'],
        longitud: decodedResponse['longuitud'],
        nombreEncargado: decodedResponse['encargado'],
        telefono: decodedResponse['telefono']);
  }

  Obra fetchObraByID(String id) {
    return obras[id];
  }

  Future<void> populateTrips() async {
    final tripsURL = "$serverIp/api/Viaje/ViajesChofer/$_driverID";
    try {
      final response = await http.get(tripsURL, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.statusCode);
      if (response.statusCode == 404 || response.statusCode == 400) {
        throw HttpException(errorMessage(response.statusCode));
      }
      final responseData = jsonDecode(response.body);
      for (var trip in responseData) {
        var equipments = await fetchEquipments(trip['idViaje']);
        var currentEquipmentIndex = equipments.indexWhere((e) {
          return e.equipmentID == trip['equipamiento'];
        });

        trips.add(
          Trip(
              tripID: trip['idViaje'],
              programmedArrivalTime: parseTime(trip['salidaProgramada']),
              programmedReturnTime: parseTime(trip['llegadaBaseProgramada']),
              programmedDepartureTime: parseTime(trip['salidaProgramada']),
              tripState: trip['idEstadoViaje'],
              // tripState: 0,
              avaibleEquipment: equipments,
              equipment: currentEquipmentIndex == -1
                  ? Equipment()
                  : equipments[currentEquipmentIndex],
              obraID: trip['idObra'],
              depotId: trip['idBodega'],
              equipmentID: trip['equipamiento'],
              latitudSalida: trip['baseSalida']['latitud'],
              longitudSalida: trip['baseSalida']['longuitud'],
              latitudVertedero: trip['disposicionFinal']['latitud'],
              longitudVertedero: trip['disposicionFinal']['longuitud'],
              latitudDepot: trip['bodega']['latitud'],
              longitudDepot: trip['bodega']['longuitud']),
        );
        if (!obras.containsKey(trip['idObra'])) {
          obras[trip['idObra']] = await fetchObra(trip['idObra']);
        }

        if (!depots.containsKey(trip['idBodega'])) {
          final bodega = trip['bodega'];
          final newDepot = Depot(
              depotId: bodega['idBodega'],
              name: bodega['nombre'],
              adress: bodega['direccion'],
              comuna: bodega['comuna'],
              coordinates: {
                'lat': bodega['latitud'],
                'lon': bodega['longuitud']
              },
              encargado: bodega['encargado'],
              telephone: bodega['telefono']);
          depots[newDepot.depotId] = newDepot;
        }
        print(trips.last.avaibleEquipment);
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }

    sortTrips();
    for (var trip in trips) {
      if (trip.stateEnum != TripStates.canceled &&
          trip.stateEnum != TripStates.pending &&
          trip.stateEnum != TripStates.finished) {
        currentTrip = trip;
        currentObra = obras[trip.obraID];
        currentDepot = depots[trip.depotId];
      }
    }
    notifyListeners();
  }

  Future<List<Equipment>> fetchEquipments(String tripID) async {
    final equipmentURL = "$serverIp/api/Viaje/busquedaEquipo/$tripID";
    final response = await http.get(equipmentURL, headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    });
    final decodedResponse = jsonDecode(response.body);
    print("decodedResponse: ${tripID}");
    print("decodedResponse: ${decodedResponse}");
    List<Equipment> avaibleEquipment = [];
    for (var equipment in decodedResponse) {
      avaibleEquipment.add(Equipment(
        equipmentID: equipment["idEquipamiento"],
        name: equipment["nombre"],
      ));
    }
    return Future.value(avaibleEquipment);
  }

  Equipment fetchEquipmentByID(String id) {
    if (avaibleEquipments.isEmpty) {
      return Equipment();
    }
    final equipment = avaibleEquipments.firstWhere((e) {
      return e.equipmentID == id;
    });
    return equipment;
  }

  Equipment currentEquipment() {
    final equipment = fetchEquipmentByID(currentTrip.equipmentID);
    return equipment;
  }

  void sortTrips() {
    final now = DateTime.now();
    trips = trips.where((trip) {
      final tripDate = trip.programmedDepartureTime;
      return DateTime(now.year, now.month, now.day) ==
          DateTime(tripDate.year, tripDate.month, tripDate.day);
    }).toList();
    trips.sort((a, b) {
      return a.programmedDepartureTime.compareTo(b.programmedDepartureTime) * 1;
    });
    final pmTrips =
        trips.where((trip) => trip.programmedDepartureTime.hour > 12).toList();
    final amTrips =
        trips.where((trip) => trip.programmedDepartureTime.hour <= 12).toList();
    trips = amTrips + pmTrips;
  }

  String errorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'La contraseña no debe estar vacía';
      case 401:
        return 'Contraseña incorrecta';
      case 404:
        return 'Servidor no encontrado';
      default:
        return 'Error conectando';
    }
  }

  DateTime _getTokenExpiryDate(String token) {
    if (token == null) {
      return null;
    }
    int expireSeconds = json.decode(ascii
        .decode(base64.decode(base64.normalize(token.split(".")[1]))))['exp'];
    DateTime expireDate =
        DateTime.fromMillisecondsSinceEpoch(expireSeconds * 1000);
    print(expireDate);
    return expireDate;
  }

  Future<bool> login(String email, String password) async {
    if (await checkToken()) {
      connectionStatus = ConnectionStatus.connected;
      notifyListeners();
      return true;
    } else
      try {
        final loginUrl = '$getServerIp/api/Usuario/Login';
        connectionStatus = ConnectionStatus.connecting;
        notifyListeners();
        final codedUserData =
            json.encode({"email": email, "password": password});
        final response =
            await http.post(loginUrl, body: codedUserData, headers: {
          "Content-Type": "application/json;charset=UTF-8",
          "Accept": "application/json",
          "Charset": 'utf-8'
        });
        final responseData = json.decode(response.body);
        final statusCode = response.statusCode;
        print(statusCode);
        if (statusCode == 200) {
          _userName = responseData['nombreCompleto'];
          _token = responseData['token'];
          _tokenExpirationDate = _getTokenExpiryDate(responseData['token']);
          _userUniqueName = responseData['username'];
          _driverID = responseData['idChofer'];
          notifyListeners();

          connectionStatus = ConnectionStatus.connected;
          notifyListeners();
          saveData();
        } else {
          print(statusCode);
          throw HttpException(errorMessage(statusCode));
        }

        return true;
      } catch (error) {
        connectionStatus = ConnectionStatus.disconnected;
        print('error connecting');
        print(error.toString());
        notifyListeners();
        throw error;
      }
  }

  //Local stuff, maybe move to another provider

  Future<bool> checkToken() async {
    // Check if token is still valid
    if (_token != null && _tokenExpirationDate != null) {
      if (_tokenExpirationDate.isAfter(DateTime.now())) {
        return true;
      } else {
        _token = null;
        _tokenExpirationDate = null;
        return false;
      }
    }
    return false;
  }

  void logOut(Function logOutAction) {
    final secureStorage = FlutterSecureStorage();
    secureStorage.delete(key: 'token');
    logOutAction();
  }

  Future<void> loadData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userData = sharedPreferences.getString('userData');
    final secureStorage = FlutterSecureStorage();
    if (userData == null) {
      print('No data');
      return;
    }
    final decodedData = jsonDecode(userData) as Map<String, Object>;
    _userName = decodedData['userName'];
    _userEmail = decodedData['userEmail'];
    saveEmail = decodedData['saveEmail'];
    _driverID = decodedData['driverID'];
    try {
      _token = await secureStorage.read(key: 'token');
      _userName = await secureStorage.read(key: 'username');
    } catch (error) {
      _token = null;
    }

    _tokenExpirationDate = _getTokenExpiryDate(_token);

    notifyListeners();
  }

  void setUserEmail(String email) {
    this._userEmail = email;
  }

  Future<void> saveData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final secureStorage = FlutterSecureStorage();
    final encodedData = jsonEncode({
      'userName': _userName,
      'userEmail': saveEmail ? _userEmail : '',
      'saveEmail': saveEmail,
      'driverID': _driverID
    });
    try {
      sharedPreferences.setString('userData', encodedData);
      secureStorage.write(key: 'token', value: _token);
      secureStorage.write(key: 'userName', value: _userUniqueName);
    } catch (error) {
      print(error.toString());
      throw error;
    }
    notifyListeners();
  }
}
