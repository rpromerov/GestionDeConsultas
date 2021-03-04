import 'dart:async';
import 'dart:convert';

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
  static const serverIp = "http://192.168.0.29:5000";
  String _token = null;
  String _userName = null;
  String _userEmail = null;
  String _userUniqueName = null;
  String _driverID = null;
  var saveEmail = false;
  DateTime _tokenExpirationDate = null;
  var testDidFinishTrip = false;

  List<Trip> trips = [];
  var obras = Map<String, Obra>();

  var currentTrip = Trip();
  var currentObra = Obra();

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

  Future<bool> checkReception() async {
    if (currentTrip == null) {
      return false;
    }
    return await geoData.isReceptionAvaible(
        currentObra.latitud, currentObra.longitud);
  }

  Future<void> changeState(String tripID, TripStates state) async {
    final requestURL = "$serverIp/api/Viaje/$tripID";
    encodeTime();
    final encodedState =
        jsonEncode({'IdEstadoViaje': state.asInt, 'inicio': encodeTime()});
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
    encodeTime();
    final encodedState =
        jsonEncode({'IdEstadoViaje': 99, 'llegadaBodega': encodeTime()});
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
    //TODO: notify server
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

  DateTime parseTime(String time) {
    if (time == null) {
      return DateTime.now();
    }
    DateFormat format = DateFormat("yyyy-MM-dd-HH:mm:ss");

    final date = format.parse(time.replaceAll("T", "-"));
    return date;
  }

  String encodeTime() {
    DateFormat format = DateFormat("yyyy-MM-ddTHH:mm:ss");
    final formatedTime = format.format(DateTime.now());
    print(formatedTime);
    return formatedTime;
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
      print("$_driverID");
      final response = await http.get(tripsURL, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      });
      if (response.statusCode == 404 || response.statusCode == 400) {
        throw HttpException(errorMessage(response.statusCode));
      }
      final responseData = jsonDecode(response.body);
      for (var trip in responseData) {
        trips.add(
          Trip(
              tripID: trip['idViaje'],
              programmedArrivalTime: parseTime(trip['salidaProgramada']),
              programmedReturnTime: parseTime(trip['llegadaBaseProgramada']),
              programmedDepartureTime: parseTime(trip['salidaProgramada']),
              tripState: trip['idEstadoViaje'],
              obraID: trip['idObra']),
        );
        if (!obras.containsKey(trip['idObra'])) {
          obras[trip['idObra']] = await fetchObra(trip['idObra']);
        }
      }
    } catch (error) {
      throw HttpException(errorMessage(0));
    }

    sortTrips();
    for (var trip in trips) {
      if (trip.stateEnum != TripStates.canceled &&
          trip.stateEnum != TripStates.pending) {
        currentTrip = trip;
        currentObra = obras[trip.obraID];
      }
    }
    print(trips.first.tripState);
    notifyListeners();
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
        final loginUrl = '$serverIp/api/Usuario/Login';
        connectionStatus = ConnectionStatus.connecting;
        notifyListeners();
        final codedUserData =
            json.encode({'email': email, 'password': password});
        final response = await http.post(loginUrl,
            body: codedUserData,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json"
            });
        final responseData = json.decode(response.body);
        final statusCode = response.statusCode;
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
        throw error as HttpException;
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
