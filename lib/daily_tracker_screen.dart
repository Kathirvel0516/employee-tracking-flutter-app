import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'location_service.dart';
import 'summary_screen.dart';

class DailyTrackerScreen extends StatefulWidget {
  final String empId;

  const DailyTrackerScreen({super.key, required this.empId});

  @override
  State<DailyTrackerScreen> createState() => _DailyTrackerScreenState();
}

class _DailyTrackerScreenState extends State<DailyTrackerScreen> {
  List assignments = [];
  bool isLoading = true;
  Position? currentPosition;
  String employeeName = "";
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadData();
    loadEmployee();

    timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await getLocation();
      checkAutoVisit();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    final data = await ApiService.getAssignments(widget.empId);
    setState(() {
      assignments = data;
      isLoading = false;
    });
  }

  Future<void> loadEmployee() async {
    final data = await ApiService.getEmployee(widget.empId);
    setState(() {
      employeeName = data['name'] ?? widget.empId;
    });
  }

  Future<void> getLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      setState(() {
        currentPosition = pos;
      });
    } catch (e) {
      print("LOCATION ERROR: $e");
    }
  }

  double getDistance(lat1, lon1, lat2, lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// 🔥 FIXED AUTO VISIT LOGIC
  void checkAutoVisit() async {
    if (currentPosition == null) return;
    if (assignments.isEmpty) return;
    double currentLat = currentPosition!.latitude;
    double currentLng = currentPosition!.longitude;
    double minDistance = double.infinity;
    Map? nearestClient;
    
    /// 🔥 Find nearest client only
    for (var item in assignments) {
      if (item['visited'] == true) continue;
      double lat = (item['lat'] as num).toDouble();
      double lng = (item['lng'] as num).toDouble();
      double distance = getDistance(currentLat, currentLng, lat, lng);
      
      print("Client: ${item['name']} → Distance: $distance");
      if (distance < minDistance) {
        minDistance = distance;
        nearestClient = item;
      }
    }
    /// 🔥 Only check nearest client
    if (nearestClient != null) {
      print("Nearest: ${nearestClient['name']} → $minDistance");
      if (minDistance <= 200 && minDistance > 10) {
        String time = TimeOfDay.now().format(context);
        try {
          await ApiService.saveVisit(
            empId: widget.empId,
            empName: employeeName,
            client: nearestClient['name'],
            address: nearestClient['location'],
            time: time,
            lat: currentLat,
            lng: currentLng,
            distance: minDistance,
          );
        } catch (e) {
          print("API ERROR: $e");
        }
        setState(() {
          nearestClient!['visited'] = true;
          nearestClient!['time'] = time;
        });
      }
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  String getTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  String getFormattedDate() {
    final now = DateTime.now();

    List months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    List days = [
      "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ];

    return "${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}";
  }

  @override
  Widget build(BuildContext context) {
    int total = assignments.length;
    int visited = assignments.where((e) => e['visited'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF1E2A5E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getTime(),
                          style: const TextStyle(color: Colors.white70)),
                      const Text("GPS ●●●",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(getGreeting(),
                      style: const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 5),

                  Text(employeeName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 5),

                  Text("${getFormattedDate()} · $visited of $total visited",
                      style: const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 10, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          currentPosition == null
                              ? "Fetching your location..."
                              : "Location detected",
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "GPS tracking active · Background location enabled",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// PROGRESS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's progress"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : visited / total,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("$visited / $total",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("TODAY'S ROUTE",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : assignments.isEmpty
                      ? const Center(
                          child: Text(
                            "No assignments for today",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )
                      : ListView.builder(
                          itemCount: assignments.length,
                          itemBuilder: (context, index) {
                            final item = assignments[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: item['visited']
                                      ? const Border(
                                          left: BorderSide(
                                              color: Colors.green, width: 4))
                                      : null,
                                ),
                                child: Row(
                                  children: [

                                    CircleAvatar(
                                      backgroundColor: item['visited']
                                          ? Colors.green.shade100
                                          : Colors.grey.shade200,
                                      child: item['visited']
                                          ? const Icon(Icons.check,
                                              color: Colors.green)
                                          : Text("${index + 1}"),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(item['location'],
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),

                                    item['visited']
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(item['time'],
                                                style: const TextStyle(
                                                    color: Colors.green)),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text("Pending"),
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  List updatedAssignments = assignments.map((item) {
                    if (item['visited'] == true) {
                      return item;
                    } else {
                      return {...item, 'status': 'missed'};
                    }
                  }).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SummaryScreen(
                        total: assignments.length,
                        visited: visited,
                        assignments: updatedAssignments,
                        empName: employeeName,
                        empId: widget.empId,
                      ),
                    ),
                  );
                },
                child: const Text("End Day & View Summary"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}