import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {

  static const String baseUrl =
      "https://script.google.com/macros/s/AKfycbytb_iQq-2My9LZJviMLW4I7poW3OZ3kX1ZHTuBYAl4o7peHNnjTaessIXb4piMMqKB/exec";

  Set<Marker> markers = {};
  bool isLoading = true;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    loadEmployees();

    /// 🔥 AUTO REFRESH EVERY 5 SECONDS
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      loadEmployees();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// 📡 FETCH EMPLOYEE DATA
  Future<void> loadEmployees() async {

    try {
      final url = "$baseUrl?action=getLiveEmployees";

      final response = await http.get(Uri.parse(url));

      final data = jsonDecode(response.body);

      Set<Marker> newMarkers = {};

      for (var emp in data) {

        if (emp['lat'] == null || emp['lng'] == null) continue;

        newMarkers.add(
          Marker(
            markerId: MarkerId(emp['empId'].toString()),

            position: LatLng(
              double.parse(emp['lat'].toString()),
              double.parse(emp['lng'].toString()),
            ),

            infoWindow: InfoWindow(
              title: emp['empId'],
              snippet: "${emp['client']} • ${emp['time']}",
            ),
          ),
        );
      }

      setState(() {
        markers = newMarkers;
        isLoading = false;
      });

    } catch (e) {
      print("MAP ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Employee Tracking"),
      ),

      body: Stack(
        children: [

          /// 🗺️ GOOGLE MAP
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(12.9716, 77.5946), // Default location
              zoom: 12,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          /// 🔄 LOADING INDICATOR
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}




