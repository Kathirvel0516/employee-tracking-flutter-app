import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'admin_map_screen.dart';
import 'daily_tracker_screen.dart';

void main() {
  runApp(const HunterWorkHubApp());
}

class HunterWorkHubApp extends StatelessWidget {
  const HunterWorkHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  late final WebViewController controller;

  String role = "";
  String employeeId = "";

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {

            print("CURRENT URL: $url");

            /// ✅ EMPLOYEE LOGIN
            if (url.contains("employee-dashboard")) {

              Uri uri = Uri.parse(url);

              String empIdFromUrl = uri.queryParameters['empId'] ?? "";

              if (empIdFromUrl.isNotEmpty) {
                setState(() {
                  role = "employee";
                  employeeId = empIdFromUrl;
                });

                print("EMPLOYEE LOGIN: $employeeId");
              }
            }

            /// ✅ ADMIN LOGIN
            else if (url.contains("admin-dashboard")) {

              setState(() {
                role = "admin";
                employeeId = "";
              });

              print("ADMIN LOGIN");
            }

            /// ✅ RESET ON LOGIN PAGE
            else if (url.contains("login")) {

              setState(() {
                role = "";
                employeeId = "";
              });

              print("RESET LOGIN");
            }
          },
        ),
      )

      ..loadRequest(Uri.parse("https://hunterworkhub.in"));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),

      /// 🔥 FLOATING BUTTON BASED ON ROLE
      floatingActionButton: buildFloatingButton(),
    );
  }

  /// 🔘 FLOATING BUTTON HANDLER
  Widget? buildFloatingButton() {

    /// 👨‍💼 EMPLOYEE BUTTON
    if (role == "employee" && employeeId.isNotEmpty) {

      return FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_pin_circle),
        onPressed: () {

          print("OPEN EMPLOYEE SCREEN → $employeeId");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyTrackerScreen(
                empId: employeeId,
              ),
            ),
          );
        },
      );
    }

    /// 🧑‍💼 ADMIN BUTTON
    else if (role == "admin") {

      return FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.admin_panel_settings),
        onPressed: () {

          print("OPEN ADMIN MAP");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminMapScreen(),
            ),
          );
        },
      );
    }

    /// ❌ NO BUTTON
    return null;
  }
}