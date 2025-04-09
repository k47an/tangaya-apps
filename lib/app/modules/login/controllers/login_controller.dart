import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/login/mixins/goggle_auth.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';

class LoginController extends GetxController with AuthGoogle {
  Rx<User?> firebaseUser = Rx<User?>(null);

  RxBool obscureText = true.obs;
  RxString passwordError = ''.obs;

  void handleGoogleSignIn() async {
    User? user = await signInWithGoogle();
    if (user != null) {
      firebaseUser.value = user;
      Get.snackbar("Success", "Login berhasil sebagai ${user.displayName}");

      Get.offAllNamed(
        Routes.HOME,
        arguments: {'name': user.displayName, 'photoURL': user.photoURL},
      );
    } else {
      Get.snackbar(
        "Error",
        "Gagal login dengan Google",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Neutral.transparent,
        colorText: Error.lightColor,
      );
    }
  }

  void handleSignOut() async {
    await signOut();
    firebaseUser.value = null;
    Get.snackbar(
      "Success",
      "Berhasil logout",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Neutral.transparent,
      colorText: Primary.mainColor,
    );
    Get.offAllNamed(Routes.HOME);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
