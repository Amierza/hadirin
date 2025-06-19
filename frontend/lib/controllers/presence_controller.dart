import 'dart:io';
import 'dart:convert';
import 'package:frontend/models/error_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/config/config.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/attendance_service.dart';
import 'package:frontend/models/attendance_model.dart';

class PresenceController extends GetxController {
  // State variables
  var isLoading = false.obs;
  var isCheckedIn = false.obs;
  var userPosition = Rx<Position?>(null);
  var lastCheckInTime = Rx<DateTime?>(null);
  var checkOutTime = Rx<DateTime?>(null);
  var currentAttendanceId = Rx<String?>(null);
  var photoInUrl = Rx<String?>(null);
  var photoOutUrl = Rx<String?>(null);
  var status = Rx<String?>(null);

  // Storage instance
  final GetStorage box = GetStorage();

  // Location configuration
  final double targetLatitude = -7.266422;
  final double targetLongitude = 112.783539;
  final double radiusMeter = 200;

  // API configuration
  String get _apiBaseUrl => Config.apiKey;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await checkLocationPermission();
    await getTodayAttendance();
  }

  // Get authentication token from storage
  String? _getToken() {
    try {
      return box.read("token");
    } catch (e) {
      return null;
    }
  }

  // Verify token exists and is valid
  bool get isAuthenticated {
    final token = _getToken();
    return token != null && token.isNotEmpty;
  }

  // Prepare request headers
  Map<String, String> _getHeaders({bool includeContentType = false}) {
    final token = _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final headers = {'Authorization': 'Bearer $token'};

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  // Prepare multipart request headers
  Map<String, String> _getMultipartHeaders() {
    final token = _getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {'Authorization': 'Bearer $token'};
  }

  // Check location permissions
  Future<void> checkLocationPermission() async {
    try {
      isLoading.value = true;

      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions permanently denied. Enable in app settings.',
        );
      }

      await _getUserLocation();
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Get current user location
  Future<void> _getUserLocation() async {
    try {
      isLoading.value = true;
      userPosition.value = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to get location: ${e.toString()}');
      userPosition.value = null;
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Check-in process
  Future<void> checkIn(File imageFile) async {
    try {
      isLoading.value = true;

      if (!isAuthenticated) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (userPosition.value == null) {
        throw Exception('Location not available. Please enable GPS.');
      }

      final uri = Uri.parse('$_apiBaseUrl/user/create-attendance');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_getMultipartHeaders());

      request.files.add(
        await http.MultipartFile.fromPath(
          'att_photo_in',
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );

      final position = userPosition.value!;
      final now = DateTime.now();
      final dateIn = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

      request.fields['att_date_in'] = dateIn;
      request.fields['att_latitude_in'] = position.latitude.toString();
      request.fields['att_longitude_in'] = position.longitude.toString();

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          isCheckedIn.value = true;
          lastCheckInTime.value = now;
          currentAttendanceId.value = responseData['data']['att_id'];
          checkOutTime.value = null;

          await getTodayAttendance();
          _showSuccessSnackbar('Success', 'Check-in successful');
        } else {
          throw Exception(responseData['message'] ?? 'Check-in failed');
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorizedError();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception(
          responseData['error'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      isCheckedIn.value = false;
      _showErrorDialog(
        "Check-in Failed",
        e.toString(),
        () => checkIn(imageFile),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check-out process
  Future<void> checkOut(File imageFile, {int retryCount = 3}) async {
    try {
      isLoading.value = true;

      if (!isAuthenticated) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (currentAttendanceId.value == null) {
        throw Exception('No attendance record found. Please check-in first.');
      }

      if (userPosition.value == null) {
        throw Exception('Location not available. Please enable GPS.');
      }

      final uri = Uri.parse(
        '$_apiBaseUrl/user/update-attendance/${currentAttendanceId.value}',
      );
      final request = http.MultipartRequest('PATCH', uri);
      request.headers.addAll(_getMultipartHeaders());

      request.files.add(
        await http.MultipartFile.fromPath(
          'att_photo_out',
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );

      final position = userPosition.value!;
      final now = DateTime.now().toLocal();
      final dateOut = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

      request.fields['att_date_out'] = dateOut;
      request.fields['att_latitude_out'] = position.latitude.toString();
      request.fields['att_longitude_out'] = position.longitude.toString();

      for (int attempt = 1; attempt <= retryCount; attempt++) {
        try {
          final response = await request.send().timeout(Duration(seconds: 30));
          final responseBody = await response.stream.bytesToString();
          final responseData = json.decode(responseBody);

          if (response.statusCode == 200 || response.statusCode == 201) {
            if (responseData['status'] == true) {
              isCheckedIn.value = false;
              checkOutTime.value = now;

              await getTodayAttendance();
              _showSuccessSnackbar('Success', 'Check-out successful');
              return;
            } else {
              throw Exception(responseData['message'] ?? 'Check-out failed');
            }
          } else if (response.statusCode == 401) {
            _handleUnauthorizedError();
            throw Exception('Session expired. Please login again.');
          } else {
            throw Exception(
              responseData['error'] ?? 'Server error: ${response.statusCode}',
            );
          }
        } catch (e) {
          if (attempt == retryCount) rethrow;
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }
    } catch (e) {
      if (e.toString().contains('Broken pipe') ||
          e.toString().contains('SocketException')) {
        _showErrorDialog(
          "Network Error",
          "Connection to server was interrupted. Please check your network and try again.",
          () => checkOut(imageFile, retryCount: 1),
        );
      } else {
        _showErrorDialog(
          "Check-Out Failed",
          e.toString(),
          () => checkOut(imageFile),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Get today's attendance from server using the service
  Future<void> getTodayAttendance() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      final result = await AttendanceService.getattendancebyDate(formattedDate);

      if (result is AttendanceResponse) {
        final attendance = result.data;
        currentAttendanceId.value = attendance.attId;
        status.value = attendance.attStatus.toString();

        if (attendance.attDateIn != null) {
          lastCheckInTime.value = attendance.attDateIn;
          isCheckedIn.value = attendance.attDateOut == null;
        }

        if (attendance.attDateOut != null) {
          checkOutTime.value = attendance.attDateOut;
          isCheckedIn.value = false;
        }

        photoInUrl.value = attendance.attPhotoIn;
        photoOutUrl.value = attendance.attPhotoOut;
      } else if (result is ErrorResponse) {
        // Silently handle "No attendance record found" case
        if (!result.message.contains("No attendance record found")) {
          throw Exception(result.message);
        }
        _clearAttendanceData();
      }
    } catch (e) {
      // Removed the error snackbar for failed attendance fetch
      _clearAttendanceData();
    } finally {
      isLoading.value = false;
    }
  }

  // Clear attendance data
  void _clearAttendanceData() {
    currentAttendanceId.value = null;
    lastCheckInTime.value = null;
    checkOutTime.value = null;
    isCheckedIn.value = false;
    photoInUrl.value = null;
    photoOutUrl.value = null;
    status.value = null;
  }

  // Handle unauthorized error (401)
  void _handleUnauthorizedError() {
    box.remove("token");
    _clearAttendanceData();
  }

  // Check if user has checked out today
  bool isCheckedOutToday() {
    if (checkOutTime.value == null) return false;
    return _isToday(checkOutTime.value!);
  }

  // Helper to check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Show error dialog with retry option
  void _showErrorDialog(String title, String message, VoidCallback onRetry) {
    Future.delayed(Duration.zero, () {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: Text('Retry'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    });
  }

  // Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Show success snackbar
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Check if user is within target radius
  bool isWithinRadius() {
    if (userPosition.value == null) return false;
    final distance = Geolocator.distanceBetween(
      targetLatitude,
      targetLongitude,
      userPosition.value!.latitude,
      userPosition.value!.longitude,
    );
    return distance <= radiusMeter;
  }
}
