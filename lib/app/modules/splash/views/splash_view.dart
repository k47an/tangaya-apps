import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Get.offNamed(Routes.ONBOARDING);
    });
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Primary.darkColor, Primary.mainColor, Primary.subtleColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.5, 0.9],
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
