import 'package:flutter/material.dart';
import 'package:frontend/controllers/register_controller.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/pages/sign_in_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController controller = Get.put(RegisterController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email anda';
    }
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Masukkan email yang benar';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan password anda';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (value.length > 20) {
      return 'Password tidak boleh lebih dari 20 karakter';
    }
    return null;
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      controller.register(context);
    } else {
      Get.snackbar(
        'Error',
        'Pastikan semua field diisi dengan benar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
            children: [
              const SizedBox(height: 90),
              Image.asset('assets/logo_green.png', height: 120),
              const SizedBox(height: 20),
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
                'Absen dengan deteksi wajah bersama Hadirin',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: bold,
                  color: tertiaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 37),

              _buildInputLabel('Nama'),
              TextFormField(
                controller: controller.nameController,
                decoration: _buildInputDecoration('Masukkan nama anda'),
                validator: (value) => value == null || value.isEmpty ? 'Masukkan nama anda' : null,
              ),
              const SizedBox(height: 40),

              _buildInputLabel('Nomor HP'),
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('Masukkan nomor HP anda'),
                validator: (value) => value == null || value.isEmpty ? 'Masukkan nomor HP anda' : null,
              ),
              const SizedBox(height: 40),

              _buildInputLabel('Pilih Posisi'),
              Obx(() {
                if (controller.isLoadingPositions.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return DropdownButtonFormField(
                  value: controller.selectedPosition.value,
                  hint: Text('Pilih Posisi Pekerjaan', style: TextStyle(color: tertiaryTextColor)),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  items: controller.positions.map((position) {
                    return DropdownMenuItem(
                      value: position,
                      child: Text(position.positionName),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    controller.setSelectedPosition(newValue!);
                  },
                  validator: (value) => value == null ? 'Pilih posisi pekerjaan' : null,
                );
              }),
              const SizedBox(height: 40),

              _buildInputLabel('E-mail'),
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Masukkan email anda'),
                validator: _validateEmail,
              ),
              const SizedBox(height: 40),

              _buildInputLabel('Password'),
              Obx(() => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscureText.value,
                    decoration: _buildInputDecoration('Masukkan password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureText.value ? Icons.visibility_off : Icons.visibility,
                          color: controller.obscureText.value ? tertiaryTextColor : primaryTextColor,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    validator: _validatePassword,
                  )),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        disabledBackgroundColor: primaryColor.withOpacity(0.5),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: bold,
                                color: backgroundColor,
                              ),
                            ),
                    )),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an Account? ",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: tertiaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const SignInPage()),
                    child: Text(
                      "Login",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: extraBold,
          color: primaryTextColor,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: tertiaryTextColor),
      border: const UnderlineInputBorder(),
    );
  }
}
