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

      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Periksa koneksi internet Anda.',
              );
            },
          );

      print(
        "Token: ${token.substring(0, 10)}...",
      ); // Log partial token for security
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

        return permitsJson.map((json) => PermitItem.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Data tidak ditemukan untuk bulan yang dipilih.');
      } else {
        throw Exception(
          'Gagal mengambil data perizinan. Kode error: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        );
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
      String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Buat request body
      Map<String, dynamic> requestBody = _createPermitRequest(
        permitDate: formattedDate,
        permitTitle: title,
        permitDesc: reason,
      );

      final url = Uri.parse('$baseUrl/user/create-permit');

      // Make HTTP request
      final response = await http
          .post(url, headers: _getHeaders(), body: json.encode(requestBody))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Periksa koneksi internet Anda.',
              );
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
          'message':
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        };
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan: ${e.toString()}',
      };
    }
  }

  // Fungsi Update Permit
  static Future<Map<String, dynamic>> updatePermission({
    required String permitId,
    String? permitDate,
    String? permitTitle,
    String? permitDesc,
    int? permitStatus,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (permitDate != null) body['permit_date'] = permitDate;
      if (permitTitle != null) body['permit_title'] = permitTitle;
      if (permitDesc != null) body['permit_desc'] = permitDesc;
      if (permitStatus != null) body['permit_status'] = permitStatus;

      final response = await http.patch(
        Uri.parse('$baseUrl/user/update-permit/$permitId'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == true) {
          return {
            'success': true,
            'message':
                responseData['message'] ?? 'Perizinan berhasil diperbarui',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal memperbarui perizinan',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Fungsi untuk delete permit
  static Future<Map<String, dynamic>> deletePermission(String permitId) async {
    print('🔥 DEBUG: Starting deletePermission for permitId: $permitId');

    try {
      final url = '$baseUrl/user/delete-permit/$permitId';
      print('🔥 DEBUG: Request URL: $url');

      final headers = _getHeaders();
      print('🔥 DEBUG: Request Headers: $headers');

      print('🔥 DEBUG: Sending DELETE request...');
      final response = await http.delete(Uri.parse(url), headers: headers);

      print('🔥 DEBUG: Response Status Code: ${response.statusCode}');
      print('🔥 DEBUG: Response Headers: ${response.headers}');
      print('🔥 DEBUG: Raw Response Body: ${response.body}');

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        print('🔥 DEBUG: Parsed Response Data: $responseData');
      } catch (jsonError) {
        print('🔥 DEBUG: JSON Parse Error: $jsonError');
        return {
          'success': false,
          'message': 'Invalid JSON response: ${response.body}',
          'debug': {
            'statusCode': response.statusCode,
            'rawBody': response.body,
            'jsonError': jsonError.toString(),
          },
        };
      }

      if (response.statusCode == 200) {
        print('🔥 DEBUG: Status code is 200, checking response status...');
        if (responseData['status'] == true) {
          print('🔥 DEBUG: Delete successful!');
          return {
            'success': true,
            'message': responseData['message'] ?? 'Perizinan berhasil dihapus',
            'data': responseData['data'],
          };
        } else {
          print('🔥 DEBUG: Delete failed - API returned status: false');
          print('🔥 DEBUG: API Error Message: ${responseData['message']}');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal menghapus perizinan',
            'debug': {
              'apiStatus': responseData['status'],
              'fullResponse': responseData,
            },
          };
        }
      } else {
        print('🔥 DEBUG: HTTP Error - Status Code: ${response.statusCode}');
        print('🔥 DEBUG: HTTP Error Body: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'debug': {
            'statusCode': response.statusCode,
            'responseBody': response.body,
            'responseHeaders': response.headers,
          },
        };
      }
    } catch (e, stackTrace) {
      print('🔥 DEBUG: Exception caught in deletePermission: $e');
      print('🔥 DEBUG: Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'debug': {
          'exception': e.toString(),
          'stackTrace': stackTrace.toString(),
        },
      };
    }
  }

  /// Get permission by ID (optional, for refresh after update)
  static Future<Map<String, dynamic>> getPermissionById(String permitId) async {
    print('🔍 DEBUG: Starting getPermissionById for permitId: $permitId');

    try {
      final url = '$baseUrl/permit/$permitId';
      print('🔍 DEBUG: Request URL: $url');

      final headers = _getHeaders();
      print('🔍 DEBUG: Request Headers: $headers');

      print('🔍 DEBUG: Sending GET request...');
      final response = await http.get(Uri.parse(url), headers: headers);

      print('🔍 DEBUG: Response Status Code: ${response.statusCode}');
      print('🔍 DEBUG: Response Headers: ${response.headers}');
      print('🔍 DEBUG: Raw Response Body: ${response.body}');

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        print('🔍 DEBUG: Parsed Response Data: $responseData');
      } catch (jsonError) {
        print('🔍 DEBUG: JSON Parse Error: $jsonError');
        return {
          'success': false,
          'message': 'Invalid JSON response: ${response.body}',
          'debug': {
            'statusCode': response.statusCode,
            'rawBody': response.body,
            'jsonError': jsonError.toString(),
          },
        };
      }

      if (response.statusCode == 200) {
        print('🔍 DEBUG: Status code is 200, checking response status...');
        if (responseData['status'] == true) {
          print('🔍 DEBUG: Get permission successful!');
          print('🔍 DEBUG: Permission data: ${responseData['data']}');
          return {'success': true, 'data': responseData['data']};
        } else {
          print('🔍 DEBUG: Get permission failed - API returned status: false');
          print('🔍 DEBUG: API Error Message: ${responseData['message']}');
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'Gagal mengambil data perizinan',
            'debug': {
              'apiStatus': responseData['status'],
              'fullResponse': responseData,
            },
          };
        }
      } else {
        print('🔍 DEBUG: HTTP Error - Status Code: ${response.statusCode}');
        print('🔍 DEBUG: HTTP Error Body: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'debug': {
            'statusCode': response.statusCode,
            'responseBody': response.body,
            'responseHeaders': response.headers,
          },
        };
      }
    } catch (e, stackTrace) {
      print('🔍 DEBUG: Exception caught in getPermissionById: $e');
      print('🔍 DEBUG: Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: $e',
        'debug': {
          'exception': e.toString(),
          'stackTrace': stackTrace.toString(),
        },
      };
    }
  }

  // Fungsi tambahan untuk refresh data setelah create
  static Future<List<PermitItem>> refreshPermitsAfterCreate(
    String month,
  ) async {
    // Tunggu sebentar untuk memastikan data sudah tersimpan di server
    await Future.delayed(const Duration(milliseconds: 500));
    return await fetchPermitsByMonth(month);
  }
}
