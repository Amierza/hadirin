import 'dart:convert';
import 'package:frontend/config/config.dart';
import 'package:http/http.dart' as http;
import '../models/position_model.dart';

final baseUrl = Config.apiKey;

class PositionApiService {
  static Future<List<Position>> fetchPositions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/get-all-position"),
      headers: {'Content-Type': 'application/json'}
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((item) => Position.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load positions');
    }
  }
}
