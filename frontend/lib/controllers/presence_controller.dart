import 'dart:io';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PresenceController extends GetxController {
  // State variables
  var isLoading = false.obs;
  var isCheckedIn = false.obs;
  var userPosition = Rx<Position?>(null);
  var lastCheckInTime = Rx<DateTime?>(null);
  var currentAttendanceId = Rx<String?>(null);

  // Storage keys
  static const String _attIdKey = 'current_att_id';
  static const String _checkInTimeKey = 'last_check_in_time';
  static const String _isCheckedInKey = 'is_checked_in';
  static const String _checkOutStatusKey = 'check_out_status';
  static const String _checkOutTimeKey = 'last_check_out_time';
  static const String _tokenKey = 'token';

  // Location configuration
  final double targetLatitude = -7.266422;
  final double targetLongitude = 112.783539;
  final double radiusMeter = 200;

  // API configuration
  String get _apiBaseUrl => Config.apiKey;

  // Storage instance
  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadPersistedData();
    _loadTodayAttendance();
  }

  // Load persisted data from storage
  void _loadPersistedData() {
    try {
      currentAttendanceId.value = box.read(_attIdKey);
      final storedTime = box.read(_checkInTimeKey);
      lastCheckInTime.value =
          storedTime != null ? DateTime.parse(storedTime) : null;
      isCheckedIn.value = box.read(_isCheckedInKey) ?? false;

      // Check if already checked out today
      final lastCheckOut = box.read(_checkOutTimeKey);
      if (lastCheckOut != null && _isToday(DateTime.parse(lastCheckOut))) {
        isCheckedIn.value = false;
      }

      if (kDebugMode) {
        print('📦 Loaded persisted data:');
        print(' - att_id: ${currentAttendanceId.value}');
        print(' - last_check_in: ${lastCheckInTime.value}');
        print(' - is_checked_in: ${isCheckedIn.value}');
        print(' - last_check_out: ${box.read(_checkOutTimeKey)}');
      }
    } catch (e) {
      print('❌ Error loading persisted data: $e');
      _clearPersistedData();
    }
  }

  // Save data to storage
  void _persistData() {
    try {
      box.write(_attIdKey, currentAttendanceId.value);
      box.write(_checkInTimeKey, lastCheckInTime.value?.toIso8601String());
      box.write(_isCheckedInKey, isCheckedIn.value);
    } catch (e) {
      print('❌ Error persisting data: $e');
    }
  }

  // Clear attendance data from storage
  void _clearPersistedData() {
    box.remove(_attIdKey);
    box.remove(_checkInTimeKey);
    box.remove(_isCheckedInKey);
    box.remove(_checkOutStatusKey);
    box.remove(_checkOutTimeKey);
  }

  // Load today's attendance
  Future<void> _loadTodayAttendance() async {
    try {
      await getTodayAttendance();
    } catch (e) {
      print("❌ Error loading attendance: $e");
    }
  }

  // Clear all attendance data
  void clearAttendanceData() {
    currentAttendanceId.value = null;
    isCheckedIn.value = false;
    lastCheckInTime.value = null;
    _clearPersistedData();
  }

  // Check if user has checked out today
  bool isCheckedOutToday() {
    final lastCheckOut = box.read(_checkOutTimeKey);
    if (lastCheckOut != null) {
      return _isToday(DateTime.parse(lastCheckOut));
    }
    return false;
  }

  // Get last checkout time
  DateTime? getLastCheckOutTime() {
    final lastCheckOut = box.read(_checkOutTimeKey);
    return lastCheckOut != null ? DateTime.parse(lastCheckOut) : null;
  }

  // Get authentication token
  String? _getToken() {
    return box.read(_tokenKey);
  }

  // Prepare request headers
  Map<String, String> _getHeaders() {
    final token = _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Check location permissions
  Future<void> checkLocationPermission() async {
    try {
      isLoading.value = true;
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
      print('❌ Location permission error: $e');
      Get.snackbar('Error', e.toString());
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
      print('📍 User location: ${userPosition.value}');
    } catch (e) {
      print('❌ Failed to get location: $e');
      Get.snackbar('Error', 'Failed to get location: ${e.toString()}');
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
      print('🟢 Starting check-in process...');

      // Check if already checked in today
      if (isCheckedIn.value && _isToday(lastCheckInTime.value)) {
        throw Exception('You have already checked in today');
      }

      // Verify location is available
      if (userPosition.value == null) {
        throw Exception('Location not available. Please enable GPS.');
      }

      // Prepare check-in request
      final uri = Uri.parse('$_apiBaseUrl/user/create-attendance');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_getHeaders());

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'att_photo_in',
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );

      // Add location and timestamp
      final position = userPosition.value!;
      final now = DateTime.now();
      final dateIn = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

      request.fields['att_date_in'] = dateIn;
      request.fields['att_latitude_in'] = position.latitude.toString();
      request.fields['att_longitude_in'] = position.longitude.toString();

      print('📤 Sending check-in data with date: $dateIn...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      print('📥 Response Code: ${response.statusCode}');
      if (kDebugMode) print('📥 Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          final attId = responseData['data']['att_id'];
          if (attId == null || attId.isEmpty) {
            throw Exception('Invalid attendance ID received from server');
          }

          // Update state and persist
          isCheckedIn.value = true;
          lastCheckInTime.value = now;
          currentAttendanceId.value = attId;
          // Clear any previous checkout status
          box.remove(_checkOutStatusKey);
          box.remove(_checkOutTimeKey);
          _persistData();

          print('✅ Check-in successful. Attendance ID: $attId');
          Get.snackbar('Success', 'Check-in successful');
        } else {
          throw Exception(responseData['message'] ?? 'Check-in failed');
        }
      } else {
        throw Exception(
          responseData['error'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Check-in error: $e');
      isCheckedIn.value = false;
      showErrorDialog(
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
      print('🔴 Starting check-out process...');

      // Verify we have a current attendance ID
      if (currentAttendanceId.value == null) {
        throw Exception('No attendance record found. Please check-in first.');
      }

      // Verify location is available
      if (userPosition.value == null) {
        throw Exception('Location not available. Please enable GPS.');
      }

      // Prepare check-out URL with att_id
      final uri = Uri.parse(
        '$_apiBaseUrl/user/update-attendance/${currentAttendanceId.value}',
      );
      final request = http.MultipartRequest('PATCH', uri);
      request.headers.addAll(_getHeaders());

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'att_photo_out',
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );

      // Add location and timestamp
      final position = userPosition.value!;
      final now = DateTime.now();
      final dateOut = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

      request.fields['att_date_out'] = dateOut;
      request.fields['att_latitude_out'] = position.latitude.toString();
      request.fields['att_longitude_out'] = position.longitude.toString();

      print('📤 Sending check-out data with date: $dateOut...');

      for (int attempt = 1; attempt <= retryCount; attempt++) {
        try {
          final response = await request.send().timeout(Duration(seconds: 30));
          final responseBody = await response.stream.bytesToString();
          final responseData = json.decode(responseBody);

          print('📥 Response Code: ${response.statusCode}');
          if (kDebugMode) print('📥 Response Body: $responseBody');

          if (response.statusCode == 200 || response.statusCode == 201) {
            if (responseData['status'] == true) {
              // Update state and clear storage
              clearAttendanceData();
              // Store checkout status and time
              box.write(_checkOutStatusKey, true);
              box.write(_checkOutTimeKey, now.toIso8601String());

              Get.snackbar('Success', 'Check-out successful');
              return;
            } else {
              throw Exception(responseData['message'] ?? 'Check-out failed');
            }
          } else {
            throw Exception(
              responseData['error'] ?? 'Server error: ${response.statusCode}',
            );
          }
        } catch (e) {
          if (attempt == retryCount) rethrow;
          print('⚠️ Check-out attempt $attempt failed. Retrying... ($e)');
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }
    } catch (e) {
      print('❌ Check-out error: $e');
      if (e.toString().contains('Broken pipe') ||
          e.toString().contains('SocketException')) {
        showErrorDialog(
          "Network Error",
          "Connection to server was interrupted. Please check your network and try again.",
          () => checkOut(imageFile, retryCount: 1),
        );
      } else {
        showErrorDialog(
          "Check-Out Failed",
          e.toString(),
          () => checkOut(imageFile),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Get today's attendance from server
  Future<void> getTodayAttendance() async {
    try {
      isLoading.value = true;
      final uri = Uri.parse('$_apiBaseUrl/user/attendances');
      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final List data = responseData['data'];
          for (final item in data) {
            if (item['att_date_in'] != null &&
                _isToday(DateTime.parse(item['att_date_in']))) {
              currentAttendanceId.value = item['att_id'];
              lastCheckInTime.value = DateTime.parse(item['att_date_in']);
              isCheckedIn.value = item['att_date_out'] == null;
              _persistData();
              print("✅ Found today's attendance");
              return;
            }
          }
          clearAttendanceData();
          print("ℹ️ No attendance found for today");
        } else {
          throw Exception(responseData['message'] ?? "Failed to fetch data");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Failed to get attendance: $e");
      Get.snackbar("Error", "Failed to fetch attendance: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to check if date is today
  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Show error dialog with retry option
  void showErrorDialog(String title, String message, VoidCallback onRetry) {
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
