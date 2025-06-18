import 'dart:convert';
import 'dart:io';

import 'package:frontend/config/config.dart';
import 'package:frontend/models/error_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:get_storage/get_storage.dart';
import "package:path/path.dart";
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

  static Future<dynamic> updateUser({
    Map<String, dynamic>? updatedFields,
    File? imageFile,
  }) async {
    final token = box.read("token");

    final uri = Uri.parse("$baseUrl/user/update-user");
    final request = http.MultipartRequest(
      "PATCH",
      uri,
    ); 
    request.headers["Authorization"] = "Bearer $token";
    
    updatedFields?.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Tambahkan file image jika ada
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );
    }

    // Kirim request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserResponse.fromJson(responseBody);
    } else {
      return ErrorResponse.fromJson(responseBody);
    }
  }
}
