import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/dialog_status.dart';

class RenamePasswordPageController extends GetxController {
  var obscureText1 = true.obs;
  var obscureText2 = true.obs;

  void togglePasswordVisibility1() {
    obscureText1.value = !obscureText1.value;
  }

  void togglePasswordVisibility2() {
    obscureText2.value = !obscureText2.value;
  }
}

class RenamePasswordPage extends StatefulWidget {
  RenamePasswordPage({Key? key}) : super(key: key);

  @override
  State<RenamePasswordPage> createState() => _RenamePasswordPageState();
}

class _RenamePasswordPageState extends State<RenamePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final RenamePasswordPageController controller = Get.put(
    RenamePasswordPageController(),
  );

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'masukkan password anda';
    }
    if (value.length < 8) {
      return 'Password anda harus minimal 8 karakter';
    }
    if (value.length > 20) {
      return 'Password anda harus kurang dari 20 katarakter';
    }
    return null;
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Masukkan ulang password';
    if (value != passwordController.text) return 'Password tidak sama';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Text(
                'Reset Your Password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: extraBold,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Enter new password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: bold,
                  color: tertiaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),

              // New Password
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'New Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: extraBold,
                    color: primaryTextColor,
                  ),
                ),
              ),
              Obx(
                () => TextFormField(
                  controller: passwordController,
                  obscureText: controller.obscureText1.value,
                  decoration: InputDecoration(
                    hintText: 'Enter New Password',
                    hintStyle: TextStyle(color: tertiaryTextColor),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryBackgroundColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureText1.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color:
                            controller.obscureText1.value
                                ? tertiaryTextColor
                                : primaryTextColor,
                      ),
                      onPressed: controller.togglePasswordVisibility1,
                    ),
                  ),
                  validator: validatePassword,
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirm Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: extraBold,
                    color: primaryTextColor,
                  ),
                ),
              ),
              Obx(
                () => TextFormField(
                  controller: confirmPasswordController,
                  obscureText: controller.obscureText2.value,
                  decoration: InputDecoration(
                    hintText: 'Confirm Your Password',
                    hintStyle: TextStyle(color: tertiaryTextColor),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryBackgroundColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureText2.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color:
                            controller.obscureText2.value
                                ? tertiaryTextColor
                                : primaryTextColor,
                      ),
                      onPressed: controller.togglePasswordVisibility2,
                    ),
                  ),
                  validator: validateConfirmPassword,
                ),
              ),
              const SizedBox(height: 120),

              // Tombol Next
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatusDialog(
                            isSuccess: true,
                            message: 'Your password is succesfully created',
                            onPressed: () {
                              Get.toNamed("/login");
                            },
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatusDialog(
                            isSuccess: false,
                            message: 'Please input the correct password',
                            onPressed: () {
                              Get.back();
                            },
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: bold,
                      color: backgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
