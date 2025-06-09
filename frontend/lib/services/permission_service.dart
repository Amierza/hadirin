import 'dart:convert';
import 'package:frontend/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/permission_model.dart';
import 'package:get_storage/get_storage.dart';

final baseUrl = Config.apiKey;

class PermitService {
  // Helper method untuk mendapatkan token
  static String? _getToken() {
    final box = GetStorage();
    return box.read("token");
  }

  // Helper method untuk membuat headers dengan authorization
  static Map<String, String> _getHeaders() {
    final token = _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method untuk membuat request body create permit
  static Map<String, dynamic> _createPermitRequest({
    required String permitDate,
    required String permitTitle,
    required String permitDesc,
    int permitStatus = 0,
  }) {
    return {
      "permit_date": permitDate,
      "permit_status": permitStatus,
      "permit_title": permitTitle,
      "permit_desc": permitDesc,
    };
  }

  // Fungsi untuk mengambil data permits berdasarkan bulan
  static Future<List<PermitItem>> fetchPermitsByMonth(String month) async {
    try {
      final token = _getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final url = Uri.parse("$baseUrl/user/get-all-permit?month=$month");

      final response = await http.get(
        url,
        headers: _getHeaders(),
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

  // Fungsi untuk membuat permit baru
  static Future<Map<String, dynamic>> createPermission({
    required DateTime date,
    required String title,
    required String reason,
  }) async {
    try {
      final token = _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      // Format tanggal ke YYYY-MM-DD
      String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Buat request body
      Map<String, dynamic> requestBody = _createPermitRequest(
        permitDate: formattedDate,
        permitTitle: title,
        permitDesc: reason,
      );

      final url = Uri.parse('$baseUrl/user/create-permit');

      // Make HTTP request
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Periksa koneksi internet Anda.');
        },
      );

      print('Create Permit Status Code: ${response.statusCode}');
      print('Create Permit Response Body: ${response.body}');

      // Parse response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        if (responseData['status'] == true) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Perizinan berhasil dibuat',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal membuat perizinan',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi telah berakhir. Silakan login kembali.',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Data yang dikirim tidak valid',
        };
      } else {
        // Handle HTTP error
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan pada server',
        };
      }
    } catch (e) {
      // Handle network error or parsing error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        };
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan: ${e.toString()}',
      };
    }
  }

  // Fungsi untuk update permit
  static Future<Map<String, dynamic>> updatePermission({
    required String permitId,
    DateTime? date,
    String? title,
    String? reason,
    int? status,
  }) async {
    try {
      final token = _getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      // Buat request body - hanya kirim field yang diubah
      Map<String, dynamic> requestBody = {};
      
      if (date != null) {
        String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00Z";
        requestBody["permit_date"] = formattedDate;
      }
      
      if (title != null && title.isNotEmpty) {
        requestBody["permit_title"] = title;
      }
      
      if (reason != null && reason.isNotEmpty) {
        requestBody["permit_desc"] = reason;
      }
      
      if (status != null) {
        requestBody["permit_status"] = status;
      }

      final url = Uri.parse('$baseUrl/user/update-permit/$permitId');

      // Make HTTP request
      final response = await http.patch(
        url,
        headers: _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Periksa koneksi internet Anda.');
        },
      );

      print('Update Permit Status Code: ${response.statusCode}');
      print('Update Permit Response Body: ${response.body}');

      // Parse response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success
        if (responseData['status'] == true) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Perizinan berhasil diperbarui',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal memperbarui perizinan',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi telah berakhir. Silakan login kembali.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Data perizinan tidak ditemukan.',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Data yang dikirim tidak valid',
        };
      } else {
        // Handle HTTP error
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan pada server',
        };
      }
    } catch (e) {
      // Handle network error or parsing error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        };
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan: ${e.toString()}',
      };
    }
  }

  // Fungsi tambahan untuk refresh data setelah create
  static Future<List<PermitItem>> refreshPermitsAfterCreate(String month) async {
    // Tunggu sebentar untuk memastikan data sudah tersimpan di server
    await Future.delayed(const Duration(milliseconds: 500));
    return await fetchPermitsByMonth(month);
  }
}