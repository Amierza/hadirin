import 'package:flutter/foundation.dart';
import 'package:frontend/models/attendance_model.dart';
import 'package:frontend/models/error_model.dart';
import 'package:frontend/services/attendance_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceController extends GetxController {
  final attendanceList = <Attendance>[].obs;
  final filteredList = <Attendance>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  var isEmpty = false.obs;
  var selectedMonth = DateFormat('MM').format(DateTime.now()).obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendance();
  }

  Future<void> fetchAllAttendance({int? month}) async {
    isLoading.value = true;
    try {
      final monthStr = (month ?? DateTime.now().month).toString().padLeft(
        2,
        '0',
      );
      final result = await AttendanceService.getAllAttendance(monthStr);

      if (result is AllAttendanceResponse) {
        if ((result.data.isEmpty)) {
          isEmpty.value = true;
          return;
        }

        attendanceList.assignAll(result.data);
        filteredList.assignAll(result.data);
      } else if (result is ErrorResponse) {
        errorMessage.value = result.message;
      }
    } catch (e) {
      print("Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void filterByMonth(int month) {
    if (attendanceList.isEmpty) return;

    final filtered =
        attendanceList.where((att) => att.attDateIn.month == month).toList();

    if (!listEquals(filtered, filteredList)) {
      filteredList.assignAll(filtered);
    }

    isEmpty.value = filteredList.isEmpty;
  }
}

class AttendanceTodayController extends GetxController {
  final attendance = Rxn<Attendance>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceToday();
  }

  Future<void> fetchAttendanceToday() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final result = await AttendanceService.getattendancebyDate(today);

      if (result is AttendanceResponse) {
        attendance.value = result.data;
      } else if (result is ErrorResponse) {
        errorMessage.value = result.message;
      } else {
        errorMessage.value = 'Unexpected error occurred';
      }
    } catch (e) {
      errorMessage.value = 'Exception: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
