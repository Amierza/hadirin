import 'dart:convert';

import 'package:frontend/config/config.dart';
import 'package:frontend/models/error_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

final baseUrl = Config.apiKey;

class UserService {
  static final box = GetStorage();

  static Future<dynamic> getUserDetail() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/user/get-detail-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      return UserResponse.fromJson(responseBody);
    } else {
      return ErrorResponse.fromJson(responseBody);
    }
  }

  static Future<dynamic> updateUser(Map<String, dynamic> data) async {
    final token = box.read("token");

    final response = await http.patch(
      Uri.parse("$baseUrl/user/update-user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserResponse.fromJson(responseBody);
    } else {
      return ErrorResponse.fromJson(responseBody);
    }
  }
}
