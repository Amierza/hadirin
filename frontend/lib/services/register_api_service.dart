import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  static const String baseUrl =
      'https://hadirin-production.up.railway.app/api/v1/user';

  static Future<http.Response> register(
    String name,
    String email,
    String password,
    String phoneNumber,
    String positionId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
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
}
