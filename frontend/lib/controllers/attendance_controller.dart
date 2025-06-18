import 'package:frontend/models/attendance_model.dart';
import 'package:frontend/models/error_model.dart';
import 'package:frontend/services/attendance_service.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final attendanceList = <Attendance>[].obs;
  final filteredList = <Attendance>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllAttendance();
  }

  Future<void> fetchAllAttendance() async {
    isLoading.value = true;
    try {
      final result = await AttendanceService.getAllAttendance();
      
      if (result is AllAttendanceResponse) {
        attendanceList.assignAll(result.data);
        filteredList.assignAll(result.data); // Initialize filtered list
      } else if (result is ErrorResponse) {
        errorMessage.value = result.message;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void filterByMonth(int month) {
    filteredList.assignAll(attendanceList.where((att) {
      return att.attDateIn.month == month;
    }).toList());
  }
}