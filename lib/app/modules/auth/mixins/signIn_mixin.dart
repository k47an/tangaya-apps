// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tangaya_apps/app/routes/app_pages.dart';
// import 'package:tangaya_apps/constant/constant.dart';

// mixin SignInMixin on GetxController {
//   final signInFormKey = GlobalKey<FormState>();

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   final isLoading = false.obs;
//   final obscurePassword = true.obs;

//   final emailError = ''.obs;
//   final passwordError = ''.obs;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       emailError.value = 'Email tidak boleh kosong';
//       return emailError.value;
//     }
//     if (!GetUtils.isEmail(value)) {
//       emailError.value = 'Format email tidak valid';
//       return emailError.value;
//     }
//     emailError.value = '';
//     return null;
//   }

//   String? validatePassword(String? value) {
//     final password = value?.trim() ?? '';
//     if (password.isEmpty) {
//       passwordError.value = 'Password tidak boleh kosong';
//       return passwordError.value;
//     } else if (password.length < 6) {
//       passwordError.value = 'Password minimal 6 karakter';
//       return passwordError.value;
//     }
//     passwordError.value = '';
//     return null;
//   }

//   void togglePasswordVisibility() {
//     obscurePassword.value = !obscurePassword.value;
//   }

//   Future<void> doLogin() async {
//     if (!signInFormKey.currentState!.validate()) {
//       return;
//     }

//     isLoading.value = true;

//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       _showSnackbar(
//         title: 'Success',
//         message: 'Berhasil Login!',
//         color: Color(Primary.mainColor.value),
//       );
//       Get.offAllNamed(Routes.HOME);
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'Login gagal!';
//       if (e.code == 'user-not-found') {
//         errorMessage = 'Email tidak terdaftar!';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Password salah!';
//       }
//       _showSnackbar(
//         title: 'Error',
//         message: errorMessage,
//         color: Color(Error.mainColor.value),
//       );
//     } catch (e) {
//       _showSnackbar(
//         title: 'Error',
//         message: 'Terjadi kesalahan, coba lagi!',
//         color: Color(Error.mainColor.value),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _showSnackbar({
//     required String title,
//     required String message,
//     required Color color,
//   }) {
//     Get.snackbar(
//       title,
//       message,
//       colorText: Colors.white,
//       backgroundColor: color.withOpacity(0.9),
//       snackPosition: SnackPosition.TOP,
//     );
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.onClose();
//   }
// }
