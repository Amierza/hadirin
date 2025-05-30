import 'dart:convert';
import 'package:frontend/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/permission_model.dart';
import 'package:get_storage/get_storage.dart';

final baseUrl = Config.apiKey;

class PermitService {
  static Future<List<PermitItem>> fetchPermitsByMonth(String month) async {
    try {
      final box = GetStorage();
      final token = box.read("token");

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final url = Uri.parse("$baseUrl/user/get-all-permit?month=$month");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Periksa koneksi internet Anda.');
        },
      );

      print("Token: ${token.substring(0, 10)}..."); // Log partial token for security
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Better null checking
        if (data == null || data['data'] == null) {
          return [];
        }
        
        final permitsJson = data['data']['permits'];
        if (permitsJson == null || permitsJson is! List) {
          return [];
        }

        return permitsJson
            .map((json) => PermitItem.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Data tidak ditemukan untuk bulan yang dipilih.');
      } else {
        throw Exception('Gagal mengambil data perizinan. Kode error: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      }
      rethrow;
    }
  }
}