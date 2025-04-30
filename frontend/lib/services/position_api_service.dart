import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/position_model.dart';

class PositionApiService {
  static const String url = 'https://hadirin-production.up.railway.app/api/v1/user/get-all-position';

  static Future<List<Position>> fetchPositions() async {
    final response = await http.get(Uri.parse(url));
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
