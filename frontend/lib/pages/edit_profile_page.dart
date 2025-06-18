import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final UserController controller = Get.put(UserController());

  String? validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan Nama anda';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email Anda';
    }
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'masukkan nomer telepon anda';
    }
    final RegExp phoneNumberRegex = RegExp(r'^[0-9]+$');
    if (!phoneNumberRegex.hasMatch(value)) {
      return 'Format nomer telepon salah';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Fetch user data when the page initializes
    controller.fetchUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => controller.pickImage(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child:
                              controller.selectedPhoto != null
                                  ? ClipOval(
                                    child: Image.file(
                                      controller.selectedPhoto!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : controller.user.value?.userPhoto != null
                                  ? ClipOval(
                                    child: Image.network(
                                      controller.user.value!.userPhoto,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                size: 60,
                                              ),
                                    ),
                                  )
                                  : const Icon(Icons.person, size: 60),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    validator: validateNama,
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Nama Lengkap",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: tertiaryTextColor,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    validator: validateEmail,
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Email",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: tertiaryTextColor,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    validator: validatePhoneNumber,
                    controller: controller.phoneNumberController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Nomor Telepon",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: tertiaryTextColor,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Obx(() {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: backgroundColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed:
                          controller.isLoading.value
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.updateUser();
                                }
                              },
                      child:
                          controller.isLoading.value
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Update',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {},
        currentIndex: 3,
      ),
    );
  }
}
