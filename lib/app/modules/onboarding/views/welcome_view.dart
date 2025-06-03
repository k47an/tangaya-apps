import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/utils/global_components/main_button.dart';

class WelcomeView extends GetView<OnboardingController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Neutral.white1,
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: ScaleHelper.scaleWidthForDevice(500),
                height: ScaleHelper.scaleHeightForDevice(500),
              ),
              Spacer(),
              Text(
                "Jelajahi Destinasi Impian Anda",
                style: semiBold.copyWith(
                  fontSize: ScaleHelper.scaleTextForDevice(22),
                  color: Neutral.dark1,
                ),
              ),
              Padding(
                padding: ScaleHelper.paddingSymmetric(horizontal: 24),
                child: Text(
                  "Temukan tempat wisata terbaik dan nikmati pengalaman tak terlupakan di berbagai destinasi menarik!",
                  style: regular.copyWith(
                    fontSize: ScaleHelper.scaleTextForDevice(14),
                    color: Neutral.dark3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: ScaleHelper.paddingSymmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    MainButton(
                      label: 'Masuk Dengan Akun',
                      onTap: () => Get.toNamed(Routes.SIGNIN),
                    ),
                    SizedBox(height: ScaleHelper.scaleHeightForDevice(16)),
                    MainButton(
                      label: 'Masuk sebagai Tamu',
                      onTap: () => Get.toNamed(Routes.HOME),
                      backgroundColor: Neutral.white4,
                      textColor: Primary.mainColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
