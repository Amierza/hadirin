import 'package:flutter/material.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/models/error_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:get/get.dart';

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
                      Get.toNamed("/home");
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
      } else if (response is ErrorResponse) {
        Get.defaultDialog(
          title: response.message,
          middleText: response.error,
          textConfirm: "Tutup",
          onConfirm: Get.back,
          backgroundColor: Colors.red,
        );
      }
    } catch (error) {
      Get.snackbar("Error", "Terjadi kesalahan server");
    } finally {
      isLoading.value = false;
    }
  }
}
