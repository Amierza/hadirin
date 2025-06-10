import 'package:get/get.dart';
import 'package:frontend/models/permission_model.dart';
import 'package:frontend/services/permission_service.dart';

class PermissionController extends GetxController {
  var selectedMonth = 'Januari'.obs;
  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;
  var permits = <PermitItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPermissions();
  }

  void changeMonth(String newMonth) {
    selectedMonth.value = newMonth;
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    try {
      isLoading.value = true;
      isError.value = false;
      permits.value = await PermitService.fetchPermitsByMonth(
        selectedMonth.value,
      );
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Di controller
  Future<void> deletePermit(String permitId, String month) async {
    final result = await PermitService.deletePermission(permitId);

    if (result['success']) {
      // ✅ Ambil ulang data
      final updatedPermits = await PermitService.fetchPermitsByMonth(month);
      permits.assignAll(updatedPermits); // <- ini penting
      update(); // atau refresh UI secara eksplisit jika pakai Obx
    } else {
      // tampilkan error
    }
  }
}
