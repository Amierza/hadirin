import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/register_controller.dart';
import 'package:frontend/controllers/sign_in_controller.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/pages/presence_history_page.dart';
import 'package:frontend/pages/presence_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/splash_page.dart';
import 'package:frontend/pages/sign_in_page.dart';
import 'package:frontend/pages/forget_password_page.dart';
import 'package:frontend/pages/rename_password_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env.local");
  } catch (error) {
    print("Gagal load env $error");
  }

  try {
    await GetStorage.init();
  } catch (error) {
    print("Gagal init GetStorage $error");
  }

  runApp(await buildApp());
}

Future<Widget> buildApp() async {
  Get.lazyPut<RegisterController>(() => RegisterController(), fenix: false);
  Get.lazyPut<SignInController>(() => SignInController(), fenix: false);

  return const MyApp();
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
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/presence_history', page: () => PresenceHistoryPage()),
        GetPage(name: '/edit_profile', page: () => EditProfilePage())

      ],
    );
  }
}
