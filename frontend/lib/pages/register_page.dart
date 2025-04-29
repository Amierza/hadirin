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

  String? selectedRole;

  final List<String> roles = [
    'Backend Engineer',
    'Frontend Engineer',
    'Mobile Developer',
    'DevOps Engineer',
    'Product Manager',
    'UI/UX Designer',
    'Data Analyst',
    'QA Engineer',
    'HR Specialist',
  ];

  @override
  void dispose() {
    controller.nameController.dispose();
    controller.emailController.dispose();
    controller.passwordController.dispose();
    controller.phoneController.dispose();
    super.dispose();
  }

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
    if (_formKey.currentState!.validate() && selectedRole != null) {
      controller.register(context, selectedRole!);
    } else {
      Get.snackbar(
        'Error',
        'Semua field harus diisi dengan benar',
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              
              // Name Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nama',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: extraBold,
                    color: primaryTextColor,
                  ),
                ),
              ),
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama anda',
                  hintStyle: TextStyle(color: tertiaryTextColor),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty 
                    ? 'Masukkan nama anda' 
                    : null,
              ),
              const SizedBox(height: 40),
              
              // Phone Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nomor HP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: extraBold,
                    color: primaryTextColor,
                  ),
                ),
              ),
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor HP anda',
                  hintStyle: TextStyle(color: tertiaryTextColor),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty 
                    ? 'Masukkan nomor HP anda' 
                    : null,
              ),
              const SizedBox(height: 40),
              
              // Role Dropdown
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pilih Posisi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: extraBold,
                    color: primaryTextColor,
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor),
                  ),
                ),
                hint: Text(
                  'Pilih Posisi Pekerjaan',
                  style: TextStyle(color: tertiaryTextColor),
                ),
                items: roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue;
                  });
                },
                validator: (value) => value == null ? 'Pilih posisi pekerjaan' : null,
              ),
              const SizedBox(height: 40),
              
              // Email Field
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
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email anda',
                  hintStyle: TextStyle(color: tertiaryTextColor),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryBackgroundColor),
                  ),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 40),
              
              // Password Field
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
                  controller: controller.passwordController,
                  obscureText: controller.obscureText.value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    hintStyle: TextStyle(color: tertiaryTextColor),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryBackgroundColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureText.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: controller.obscureText.value
                            ? tertiaryTextColor
                            : primaryTextColor,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                  validator: _validatePassword,
                ),
              ),
              const SizedBox(height: 40),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: bold,
                      color: backgroundColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Already have account text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an Account? ",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: tertiaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const SignInPage());
                    },
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
            ],
          ),
        ),
      ),
    );
  }
}