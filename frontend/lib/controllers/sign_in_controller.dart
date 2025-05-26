import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/error_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:get/get.dart';

import '../widgets/dialog_status.dart';

class SignInController extends GetxController {
  final isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginUser() async {
    isLoading.value = true;

    final request = LoginRequest(
      email: emailController.text,
      password: passwordController.text,
    );

    try {
      final response = await AuthService.login(request);

      if (response is LoginResponse) {
        Get.dialog(
          StatusDialog(
            isSuccess: true,
            message: response.message,
            onPressed: () {
              Get.toNamed("/home");
            },
          ),
        );
      } else if (response is ErrorResponse) {
        Get.dialog(
          StatusDialog(
            isSuccess: false,
            message: response.message,
            onPressed: () {
              Get.back();
            },
          ),
        );
      }
    } catch (error) {
      Get.snackbar("Error", "Terjadi kesalahan server");
    } finally {
      isLoading.value = false;
    }
  }
}
