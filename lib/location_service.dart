import 'package:geolocator/geolocator.dart';

class LocationService {

  /// 🔥 GET FRESH LOCATION (FIXED)
  static Future<Position> getCurrentLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    /// 1️⃣ Check if location service is ON
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled. Please enable GPS.");
    }

    /// 2️⃣ Check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Location permission permanently denied. Enable from settings."
      );
    }

    /// 🔥 3️⃣ FORCE FRESH LOCATION (IMPORTANT FIX)
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best, // 🔥 highest accuracy
      forceAndroidLocationManager: true,      // 🔥 avoid cached location
      timeLimit: const Duration(seconds: 10), // 🔥 timeout safety
    );

    return position;
  }

  /// 🔥 LIVE LOCATION STREAM (IMPROVED)
  static Stream<Position> getLocationStream() {

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best, // 🔥 better accuracy
      distanceFilter: 5, // 🔥 update every 5 meters
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// 🔹 Distance calculation (meters)
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }
}