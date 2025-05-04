import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    // Tunggu 2 detik lalu dengarkan perubahan auth
    Future.delayed(const Duration(seconds: 2), () {
      FirebaseAuth.instance.authStateChanges().first.then((user) {
        debugPrint("DEBUG: Firebase user => $user");
        if (user == null) {
          Get.offAllNamed(Routes.ONBOARDING); // jika belum login
        } else {
          Get.offAllNamed(Routes.HOME); // jika sudah login
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Primary.darkColor, Primary.mainColor, Primary.subtleColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.1, 0.5, 0.9],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            top: 400,
            left: -40,
            right: 0,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/images/logo_icon.png'),
            ),
          ),
        ],
      ),
    );
  }
}
