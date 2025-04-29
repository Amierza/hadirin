import 'package:frontend/services/register_api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RegisterController extends GetxController {
  var obscureText = true.obs;
  var isName = true.obs;
  var isEmail = true.obs;
  var isPassword = true.obs;
  var isPhone = true.obs;
  var isRole = true.obs;
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  final Map<String, String> positionIds = {
    'Backend Engineer': '1d1bba3e-4f22-47d2-ae7d-741ae6b44b85',
    'Frontend Engineer': 'd96b99e9-1346-49e5-920b-8eab44e2c6f4',
    'Mobile Developer': 'b5f8a1b2-7183-40be-bf35-97b5e497fc21',
    'DevOps Engineer': 'ad9d219f-b8ef-4f28-9eaf-3c97eb7a7e3d',
    'Product Manager': 'e7d18443-5585-4d2d-a8e0-445b492cf3f0',
    'UI/UX Designer': '92a8631a-b10b-4b24-b2ba-c3b2acb2b7ef',
    'Data Analyst': '6b2f9091-2740-42d8-8f1c-9cc930a8d72c',
    'QA Engineer': 'c12d7805-92ce-4d4c-93d8-9b3a0d9e4b72',
    'HR Specialist': '8a214d70-2188-4d2b-91eb-4fefc6588e5f',
  };

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void register(BuildContext context, String selectedRole) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final positionId = positionIds[selectedRole] ?? '';

    if (name.isEmpty) isName.value = false;
    if (email.isEmpty || !email.isEmail) isEmail.value = false;
    if (password.isEmpty) isPassword.value = false;
    if (phone.isEmpty) isPhone.value = false;
    if (positionId.isEmpty) isRole.value = false;

    if (!isName.value ||
        !isEmail.value ||
        !isPassword.value ||
        !isPhone.value ||
        !isRole.value) {
      return;
    }

    isLoading.value = true;

    try {
      final result = await RegisterService.register(
        name,
        email,
        password,
        phone,
        positionId,
      );

      final statusCode = result.statusCode;
      final responseBody = result.body;

      print("Status code: $statusCode");
      print("Response body: $responseBody");

      if (result.statusCode == 200) {
        Get.defaultDialog(
          title: 'Registrasi Berhasil',
          titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          middleText: "Semoga lanjutkan ke halaman login",
          middleTextStyle: TextStyle(color: Colors.white),
          textConfirm: "OK",
          confirmTextColor: Colors.black, // Warna teks tombol
          buttonColor: Colors.white,       // Warna latar tombol
          backgroundColor: Colors.green,   // Latar belakang dialog
          onConfirm: () {
            Navigator.pushNamed(context, '/login');
          },
          radius: 10,
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
    } catch (err) {
      print("Internal Server Error");
    } finally {
      isLoading.value = false;
    }
  }
}
