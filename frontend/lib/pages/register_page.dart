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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedRole;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> roles = [
    'Manager',
    'Developer',
    'Designer',
    'Admin',
    'Marketing',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
      // controller.register(nameController.text, emailController.text, passwordController.text, selectedRole!);
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/logo_green.png', width: 150, height: 150),
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
                  const SizedBox(height: 20),
                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildRoleDropdown(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildCreateAccountButton(),
                  const SizedBox(height: 10),
                  _buildAlreadyHaveAccountText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildInputField(
      label: 'Nama',
      controller: nameController,
      hintText: 'Masukkan nama anda',
      hintStyle: TextStyle(color: tertiaryTextColor),
    );
  }

  Widget _buildEmailField() {
    return _buildInputField(
      label: 'E-mail',
      controller: emailController,
      hintText: 'Masukkan email anda',
      hintStyle: TextStyle(color: tertiaryTextColor),
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: extraBold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => TextFormField(
              controller: passwordController,
              obscureText: controller.obscureText.value,
              validator: _validatePassword,
              decoration: InputDecoration(
                hintText: "Masukkan password",
                hintStyle: TextStyle(color: tertiaryTextColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureText.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: primaryTextColor,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                border: const UnderlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Posisi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: extraBold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: const InputDecoration(border: UnderlineInputBorder()),
          hint: Text(
            'Pilih Posisi Pekerjaan',
            style: TextStyle(color: tertiaryTextColor),
          ),
          items:
              roles.map((String role) {
                return DropdownMenuItem<String>(value: role, child: Text(role));
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedRole = newValue;
            });
          },
          validator: (value) => value == null ? 'Pilih posisi pekerjaan' : null,
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return GestureDetector(
      onTap: _register,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        width: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "Create Account",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: extraBold,
              color: backgroundColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyHaveAccountText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        GestureDetector(
          onTap: () => Get.to(() => const SignInPage()),
          child: Text(
            "Login",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: extraBold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, required TextStyle hintStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: extraBold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: const UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
