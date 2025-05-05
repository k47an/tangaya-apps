import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';

class SplashController extends GetxController {
  // Fungsi untuk mengecek status user (login atau tidak)
  Future<void> checkUserStatus() async {
    // Tunggu sebentar (2 detik) untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Mendengarkan perubahan status autentikasi
    FirebaseAuth.instance.authStateChanges().first.then((user) {
      if (user == null) {
        // Arahkan ke halaman onboarding jika belum login
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        // Arahkan ke halaman home jika sudah login
        Get.offAllNamed(Routes.HOME);
      }
    });
  }
}
