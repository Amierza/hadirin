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
  String? selectedRole;
  final List<String> roles = [
    'Manager',
    'Developer',
    'Designer',
    'Admin',
    'Marketing',
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo
                Image.asset('assets/logo_green.png', width: 150, height: 150),

                // Welcome text
                const SizedBox(height: 20),
                const Text(
                  'Selamat datang di Hadirin',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text('Absen dengan deteksi wajah bersama hadirin'),

                // Form fields
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 20),
                _buildRoleDropdown(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(controller),
                const SizedBox(height: 20),
                _buildCreateAccountButton(),
                const SizedBox(height: 10),
                _buildAlreadyHaveAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter Your Name',
              hintStyle: TextStyle(color: primaryTextColor),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryBackgroundColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryBackgroundColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forgot Password?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: secondaryBackgroundColor),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  'Pilih Role Pekerjaan',
                  style: TextStyle(color: primaryTextColor),
                ),
                value: selectedRole,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: primaryTextColor),
                items:
                    roles.map((String role) {
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'E-mail',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter Your E-mail',
              hintStyle: TextStyle(color: primaryTextColor),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryBackgroundColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: secondaryBackgroundColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(RegisterController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => TextFormField(
              controller: passwordController,
              obscureText: controller.obscureText.value,
              decoration: InputDecoration(
                hintText: "Masukkan Password",
                hintStyle: TextStyle(color: primaryTextColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureText.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color:
                        controller.obscureText.value
                            ? primaryTextColor
                            : primaryTextColor,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: secondaryBackgroundColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: secondaryBackgroundColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: GestureDetector(
        onTap: () {
          // Implementasi fungsi register
          if (nameController.text.isEmpty ||
              emailController.text.isEmpty ||
              passwordController.text.isEmpty ||
              selectedRole == null) {
            Get.snackbar(
              'Error',
              'Semua field harus diisi',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          // Panggil fungsi register di controller
          // controller.register(nameController.text, emailController.text, passwordController.text, selectedRole!);
        },
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
                fontWeight: bold,
                color: secondaryTextColor,
              ),
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
          onTap: () {
            Get.to(() => SignInPage());
          },
          child: Text(
            "Login",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
