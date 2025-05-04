// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// mixin SignUpMixin on GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final signUpFormKey = GlobalKey<FormState>();

//   // Text Editing Controllers
//   final emailController = TextEditingController();
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   // Error messages
//   RxString emailError = ''.obs;
//   RxString usernameError = ''.obs;
//   RxString passwordError = ''.obs;
//   RxString confirmPasswordError = ''.obs;

//   // Password visibility
//   RxBool obscurePassword = true.obs;
//   RxBool obscureConfirmPassword = true.obs;

//   // Loading state
//   RxBool isLoading = false.obs;

//   void togglePasswordVisibility() {
//     obscurePassword.value = !obscurePassword.value;
//   }

//   void toggleConfirmPasswordVisibility() {
//     obscureConfirmPassword.value = !obscureConfirmPassword.value;
//   }

//   String? validateEmail(String? value) {
//     final email = value?.trim() ?? '';
//     if (email.isEmpty) {
//       emailError.value = 'Email tidak boleh kosong';
//       return emailError.value;
//     } else if (!GetUtils.isEmail(email)) {
//       emailError.value = 'Format email tidak valid';
//       return emailError.value;
//     }
//     emailError.value = '';
//     return null;
//   }

//   String? validateUsername(String? value) {
//     final username = value?.trim() ?? '';
//     if (username.isEmpty) {
//       usernameError.value = 'Username tidak boleh kosong';
//       return usernameError.value;
//     } else if (username.length < 3) {
//       usernameError.value = 'Username minimal 3 karakter';
//       return usernameError.value;
//     } else if (username.length > 20) {
//       usernameError.value = 'Username maksimal 20 karakter';
//       return usernameError.value;
//     } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
//       usernameError.value = 'Username hanya boleh huruf, angka, dan _';
//       return usernameError.value;
//     }
//     usernameError.value = '';
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

//   String? validateConfirmPassword(String? value) {
//     final password = passwordController.text.trim();
//     final confirmPassword = value?.trim() ?? '';
//     if (confirmPassword.isEmpty) {
//       confirmPasswordError.value = 'Konfirmasi password tidak boleh kosong';
//       return confirmPasswordError.value;
//     } else if (password != confirmPassword) {
//       confirmPasswordError.value = 'Password tidak cocok';
//       return confirmPasswordError.value;
//     }
//     confirmPasswordError.value = '';
//     return null;
//   }

//   bool isFormValid() {
//     validateEmail(emailController.text);
//     validateUsername(usernameController.text);
//     validatePassword(passwordController.text);
//     validateConfirmPassword(confirmPasswordController.text);

//     return emailError.value.isEmpty &&
//         usernameError.value.isEmpty &&
//         passwordError.value.isEmpty &&
//         confirmPasswordError.value.isEmpty;
//   }

//   Future<void> signUpWithEmailAndPassword() async {
//     if (!isFormValid()) {
//       Get.snackbar("Error", "Silakan periksa kembali data yang dimasukkan");
//       return;
//     }

//     isLoading.value = true;
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       final user = userCredential.user;
//       if (user != null) {
//         await user.updateDisplayName(usernameController.text.trim());
//         await user.reload();
//         Get.snackbar("Sukses", "Akun berhasil dibuat");
//         // Tambahkan navigasi jika perlu
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         Get.snackbar("Error", "Password terlalu lemah");
//       } else if (e.code == 'email-already-in-use') {
//         Get.snackbar("Error", "Email sudah digunakan");
//       } else {
//         Get.snackbar("Error", "Terjadi kesalahan. Coba lagi.");
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Error: ${e.toString()}");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     usernameController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.onClose();
//   }
// }
