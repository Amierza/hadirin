import 'dart:convert';

import 'package:frontend/config/config.dart';
import 'package:frontend/models/attendance_model.dart';
import 'package:frontend/models/error_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

final baseUrl = Config.apiKey;

class AttendanceService {
  static final box = GetStorage();

  static Future<dynamic> getAllAttendance(String month) async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/user/get-all-attendance?month=$month"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      return AllAttendanceResponse.fromJson(responseBody);
    } else {
      return ErrorResponse.fromJson(responseBody);
    }
  }

  static Future<dynamic> getattendancebyDate(String date) async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/user/get-attendance-today?date=$date"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      return AttendanceResponse.fromJson(responseBody);
    } else {
      return ErrorResponse.fromJson(responseBody);
    }
  }
}
