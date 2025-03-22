import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/sign_in_page.dart';
import 'package:frontend/pages/rename_password_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email anda';
    }

    // Basic email regex pattern
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Masukkan email yang benar';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Text(
                'Forget Password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: extraBold,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your Email to reset password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: bold,
                  color: tertiaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Image.asset('assets/logo_green.png', height: 200),
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'E-mail',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: extraBold,
                    color: primaryTextColor,
                  ),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter Your E-mail',
                  hintStyle: TextStyle(color: tertiaryTextColor),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor),
                  ),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 40),
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Get.to(() => RenamePasswordPage());
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
              const SizedBox(height: 20),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => SignInPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: extraBold,
                      color: primaryTextColor,
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
              