import 'package:flutter/cupertino.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/user_service.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final user = Rxn<User>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDetail();
  }

  void fetchUserDetail() async {
    try {
      final response = await UserService.getUserDetail();
      if (response is UserResponse) {
        user.value = response.data;
        nameController.text = response.data.userName;
        emailController.text = response.data.userEmail;
        phoneNumberController.text = response.data.userPhoneNumber;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
