import 'package:get/get.dart';

class RegisterController extends GetxController {
  var obscureText = true.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }
}
