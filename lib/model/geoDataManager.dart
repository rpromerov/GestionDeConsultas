import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GeoDataManager {
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  ///
  Future<bool> isReceptionAvaible(double latitud, double longitud) async {
    if (await getDistance(latitud, longitud) <= 850) {
      return true;
    } else {
      return false;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, double>> _getCoords(String destinationAdress) async {
    final requestUrl =
        'https://api.opencagedata.com/geocode/v1/json?q=$destinationAdress&key=35db225e877b4df7b375e8ebd0836247';
    final response = await http.get(requestUrl);
    final responseData = json.decode(response.body);
    final destLatitud = responseData['results'][0]['geometry']['lat'];
    final destLongitud = responseData['results'][0]['geometry']['lng'];
    return {'latitud': destLatitud, 'longitud': destLongitud};
  }

  Future<double> getDistance(double latitud, longitud) async {
    print(latitud);
    if (latitud == null || longitud == null) {
      return double.infinity;
    }
    final currentPosition = await _determinePosition();

    final currentDistance = Geolocator.distanceBetween(
        currentPosition.latitude, currentPosition.longitude, latitud, longitud);
    print("$currentDistance m");
    return currentDistance;
  }
}
