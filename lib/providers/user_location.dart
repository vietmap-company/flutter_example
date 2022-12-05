import 'package:flutter/foundation.dart';

class UserLocation {
  final double lng;
  final double lat;

  UserLocation({required this.lng, required this.lat});
}

class UserLocationItems with ChangeNotifier {
  late UserLocation? _userLocation;
  UserLocation? get userLocation {
    if (_userLocation != null) {
      return _userLocation;
    }
  }

  void fetchAndSetUserLocation(double lat, double lng) {
    _userLocation = UserLocation(lng: lng, lat: lat);
    notifyListeners();
  }
}
