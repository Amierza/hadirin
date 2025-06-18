import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:frontend/models/error_model.dart';
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
      final Map<String, dynamic> updatedFields = {};

      // Only add changed fields
      if (nameController.text != user.value?.userName) {
        updatedFields['name'] = nameController.text;
      }
      if (emailController.text != user.value?.userEmail) {
        updatedFields['email'] = emailController.text;
      }
      if (phoneNumberController.text != user.value?.userPhoneNumber) {
        updatedFields['phone_number'] = phoneNumberController.text;
      }

      if (updatedFields.isEmpty && selectedPhoto == null) {
        Get.snackbar("Info", "No changes detected");
        return;
      }

      final response = await UserService.updateUser(
        updatedFields: updatedFields,
        imageFile: selectedPhoto,
      );

      if (response is UserResponse) {
        Get.snackbar("Success", "Profile updated successfully");
        fetchUserDetail(); // Refresh data
      } else if (response is ErrorResponse) {
        Get.snackbar("Error", response.message);
      } else if (response is String) {
        Get.snackbar("Error", response);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }
}
