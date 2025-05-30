// controllers/register_controller.dart
import 'package:frontend/models/position_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/position_api_service.dart';

class RegisterController extends GetxController {
  var obscureText = true.obs;
  var isLoading = false.obs;
  var isLoadingPositions = true.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  var positions = <Position>[].obs;
  var selectedPosition = Rxn<Position>();

  @override
  void onInit() {
    super.onInit();
    fetchPositions();
  }

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void setSelectedPosition(Position? position) {
    selectedPosition.value = position;
  }

  Future<void> fetchPositions() async {
    try {
      isLoadingPositions.value = true;
      final data = await PositionApiService.fetchPositions();
      positions.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data posisi");
    } finally {
      isLoadingPositions.value = false;
    }
  }

  void register(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final position = selectedPosition.value;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        position == null) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return;
    }

    isLoading.value = true;

    try {
      final result = await AuthService.register(
        name,
        email,
        password,
        phone,
        position.positionId,
      );

      if (result.statusCode == 200) {
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Success",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your Account is succesfully created",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text("Continue"),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        Get.defaultDialog(
          title: 'Registrasi Gagal',
          middleText: "Terjadi kesalahan saat mendaftar",
          textConfirm: "Tutup",
          onConfirm: () => Navigator.of(context).pop(),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan server");
    } finally {
      isLoading.value = false;
    }
  }
}
