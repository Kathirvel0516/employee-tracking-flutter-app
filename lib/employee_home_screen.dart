import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final String empId;

  const EmployeeHomeScreen({super.key, required this.empId});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {

  // ✅ YOUR CORRECT API URL
  final String baseURL =
  "https://script.google.com/macros/s/AKfycbytb_iQq-2My9LZJviMLW4I7poW3OZ3kX1ZHTuBYAl4o7peHNnjTaessIXb4piMMqKB/exec";
  Map<String, dynamic>? client;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClient();
  }

  // ================= FETCH CLIENT =================
  Future<void> fetchClient() async {
    try {
      final url = "$baseURL?action=getTodayClient&empId=${widget.empId}";
      print("API URL: $url");

      final res = await http.get(Uri.parse(url));

      print("API RESPONSE: ${res.body}");

      final data = jsonDecode(res.body);

      if (data == null || data['clientId'] == null) {
        setState(() {
          isLoading = false;
          client = null;
        });
        return;
      }

      setState(() {
        client = data;
        isLoading = false;
      });

    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= GET LOCATION (COMMON FUNCTION) =================
  Future<Position> getLocation() async {

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ================= START WORK =================
  Future<void> startWork() async {

    try {
      Position position = await getLocation();

      print("START LAT: ${position.latitude}");
      print("START LNG: ${position.longitude}");

      final url =
          "$baseURL?action=startWork"
          "&empId=${widget.empId}"
          "&clientId=${client!['clientId']}"
          "&lat=${position.latitude}"
          "&lng=${position.longitude}";

      print("START URL: $url");

      await http.get(Uri.parse(url));

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Work Started")));

    } catch (e) {
      print("START ERROR: $e");
    }
  }

  // ================= END WORK =================
  Future<void> endWork() async {

    try {
      Position position = await getLocation();

      print("END LAT: ${position.latitude}");
      print("END LNG: ${position.longitude}");

      final url =
          "$baseURL?action=endWork"
          "&empId=${widget.empId}"
          "&clientId=${client!['clientId']}"
          "&lat=${position.latitude}"
          "&lng=${position.longitude}";

      print("END URL: $url");

      await http.get(Uri.parse(url));

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Work Ended")));

    } catch (e) {
      print("END ERROR: $e");
    }
  }

  // ================= NAVIGATE =================
  Future<void> openMap() async {
    final lat = client!['lat'];
    final lng = client!['lng'];

    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";

    await launchUrl(Uri.parse(url));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (client == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF061C3D),
        body: Center(
          child: Text(
            "No client assigned today",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Employee Work",
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF061C3D),
              Color(0xFF0B2A5B),
              Color(0xFF061C3D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🔶 CLIENT CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        client!['clientName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        client!['location'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // 🟢 START WORK
                ElevatedButton(
                  onPressed: startWork,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 55),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(color: Colors.green, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Start Work",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔴 END WORK
                ElevatedButton(
                  onPressed: endWork,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 55),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "End Work",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                // 🟡 NAVIGATE
                ElevatedButton(
                  onPressed: openMap,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 55),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(
                        color: Color(0xFFD4AF37), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Navigate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}