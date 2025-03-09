import 'package:flutter/material.dart';
import 'package:frontend/pages/presence_page.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/splash_page.dart';
import 'package:frontend/pages/sign_in_page.dart';
import 'package:frontend/pages/forget_password_page.dart';
import 'package:frontend/pages/rename_password_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hadirin Presence Application',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => SignInPage()),
        GetPage(name: '/forget-password', page: () => ForgetPasswordPage()),
        GetPage(name: '/rename-password', page: () => RenamePasswordPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/presence', page: () => PresencePage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/perizinan', page: () => HomePage()),
      ],
    );
  }
}
