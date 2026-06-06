import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl =
      "https://script.google.com/macros/s/AKfycbytb_iQq-2My9LZJviMLW4I7poW3OZ3kX1ZHTuBYAl4o7peHNnjTaessIXb4piMMqKB/exec";

  /// GET ASSIGNMENTS
  static Future<List<dynamic>> getAssignments(String empId) async {

    final url = "$baseUrl?action=getAssignments&empId=$empId";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }

  /// GET EMPLOYEE NAME
  static Future<Map<String, dynamic>> getEmployee(String empId) async {

    final url = "$baseUrl?action=getEmployee&empId=$empId";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }

  /// ✅ UPDATED SAVE VISIT (NEW FIELDS ADDED)
  static Future<void> saveVisit({
    required String empId,
    required String empName,     // ✅ NEW
    required String client,
    required String address,     // ✅ NEW
    required String time,
    required double lat,
    required double lng,
    required double distance,    // ✅ NEW
  }) async {

    final url =
        "$baseUrl?action=saveVisit"
        "&empId=$empId"
        "&empName=$empName"
        "&client=$client"
        "&address=$address"
        "&time=$time"
        "&lat=$lat"
        "&lng=$lng"
        "&distance=$distance";

    await http.get(Uri.parse(url));
  }
}