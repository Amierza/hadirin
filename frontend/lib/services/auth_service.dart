import 'dart:convert';
import 'package:frontend/config/config.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/error_model.dart';
import 'package:http/http.dart' as http;

final baseUrl = Config.apiKey;

class AuthService {
  static Future<http.Response> register(
    String name,
    String email,
    String password,
    String phoneNumber,
    String positionId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'position_id': positionId,
      }),
    );

    return response;
  }

  static Future<dynamic> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user/login"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode(request.toJson())
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['status'] == true) {
      return LoginResponse.fromJson(responseBody);
    } else {
      return ErrorResponse.fromJson(responseBody);
    }
  }
}
