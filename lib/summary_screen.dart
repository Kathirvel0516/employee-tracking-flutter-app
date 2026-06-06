import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final int total;
  final int visited;
  final List assignments;
  final String empName;
  final String empId;

  const SummaryScreen({
    super.key,
    required this.total,
    required this.visited,
    required this.assignments,
    required this.empName,
    required this.empId,
  });

  /// ⏰ TIME
  String getTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'pm' : 'am'}";
  }

  /// 📅 DATE
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [

            /// 🔵 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF1E2A5E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(getTime(),
                      style: const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 10),

                  const Text("Day Summary",
                      style: TextStyle(color: Colors.white70)),

                  const SizedBox(height: 5),

                  Text("$empName - $empId",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 5),

                  Text(
                    getFormattedDate(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// 📊 PROGRESS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text("Overall completion"),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: total == 0 ? 0 : visited / total,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("$visited / $total"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 📋 LIST + EMPTY STATE
            Expanded(
              child: assignments.isEmpty
                  ? const Center(
                      child: Text(
                        "No assignments for today",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {

                        final item = assignments[index];

                        bool isVisited = item['visited'] == true;
                        bool isMissed = item['status'] == 'missed';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [

                                Text(item['name']),

                                isVisited
                                    ? Row(
                                        children: [
                                          const Icon(Icons.check,
                                              color: Colors.green),
                                          const SizedBox(width: 5),
                                          Text(item['time'],
                                              style: const TextStyle(
                                                  color: Colors.green)),
                                        ],
                                      )
                                    : isMissed
                                        ? const Row(
                                            children: [
                                              Icon(Icons.close,
                                                  color: Colors.red),
                                              SizedBox(width: 5),
                                              Text("Missed",
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ],
                                          )
                                        : const Text("Pending",
                                            style: TextStyle(
                                                color: Colors.orange)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            /// 🔘 BUTTON
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
                  Navigator.pop(context);
                },
                child: const Text("Sign Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}