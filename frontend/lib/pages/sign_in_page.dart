import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/forget_password_page.dart';

class SignInController extends GetxController {
  var obscureText = true.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }
}

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);

  final SignInController controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            Image.asset('assets/logo_green.png', height: 120),
            const SizedBox(height: 20),

            // Welcome Text
            Text(
              'Selamat datang di Hadirin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: extraBold,
                color: primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Absen dengan deteksi wajah bersama hadirin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: bold,
                color: tertiaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 37),

            // Email Input
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
            ),
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: extraBold,
                  color: primaryTextColor,
                ),
              ),
            ),
            Obx(
              () => TextFormField(
                obscureText: controller.obscureText.value,
                decoration: InputDecoration(
                  hintText: 'Enter Your Password',
                  hintStyle: TextStyle(color: tertiaryTextColor),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureText.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color:
                          controller.obscureText.value
                              ? tertiaryTextColor
                              : primaryTextColor,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Get.to(() => ForgetPasswordPage());
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: bold,
                    color: tertiaryTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: bold,
                    color: backgroundColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign Up Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an Account? ",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: regular,
                    color: tertiaryTextColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Sign Up",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: extraBold,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
