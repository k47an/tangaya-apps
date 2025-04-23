import 'package:get/get.dart';

mixin SignUpMixin on GetxController {
  RxBool obscureText = true.obs;
  RxString passwordError = ''.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  void validatePassword(String password) {
    if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters long';
    } else {
      passwordError.value = '';
    }
  }
}
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email tidak boleh kosong';
  }
  if (!GetUtils.isEmail(value)) {
    return 'Format email tidak valid';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password tidak boleh kosong';
  }
  if (value.length < 6) {
    return 'Password minimal 6 karakter';
  }
  return null;
}
