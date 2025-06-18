import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/user_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends GetxController {
  final user = Rxn<User>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  File? selectedPhoto;

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

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      selectedPhoto = File(pickedFile.path);
      update();
    }
  }

  void updateUser() async {
    isLoading.value = true;
    try {
      final response = await UserService.updateUser(
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        imageFile: selectedPhoto,
      );
      print(response);

      if (response is UserResponse) {
        Get.snackbar("Update profil berhasil", "Profil berhasil diperbarui");
        fetchUserDetail();
      } else {
        Get.snackbar("Update profil gagal", "Gagal melakukan update profil");
      }
    } finally {
      isLoading.value = false;
    }
  }
}
