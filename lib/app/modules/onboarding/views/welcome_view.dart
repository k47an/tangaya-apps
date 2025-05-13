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
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset('assets/images/logo.png'),
              SizedBox(height: ScaleHelper.scaleHeightForDevice(80)),
              Text(
                "Jelajahi Destinasi Impian Anda",
                style: semiBold.copyWith(
                  fontSize: ScaleHelper.scaleTextForDevice(22),
                  color: Neutral.dark1,
                ),
              ),
              SizedBox(height: ScaleHelper.scaleHeightForDevice(18)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper.scaleWidthForDevice(24),
                ),
                child: Text(
                  "Temukan tempat wisata terbaik dan nikmati pengalaman tak terlupakan di berbagai destinasi menarik!",
                  style: regular.copyWith(
                    fontSize: ScaleHelper.scaleTextForDevice(12),
                    color: Neutral.dark3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper.scaleWidthForDevice(24),
                ),
                child: Column(
                  children: [
                    SizedBox(height: ScaleHelper.scaleHeightForDevice(40)),
                    MainButton(
                      label: 'Masuk Dengan Akun',
                      onTap: () {
                        Get.toNamed(Routes.SIGNIN);
                      },
                    ),
                    SizedBox(height: ScaleHelper.scaleHeightForDevice(16)),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.HOME);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ScaleHelper.scaleHeightForDevice(14),
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Primary.mainColor),
                          color: Neutral.white4,
                        ),
                        child: Text(
                          'Masuk sebagai Tamu',
                          style: bold.copyWith(
                            fontSize: ScaleHelper.scaleTextForDevice(16),
                            color: Primary.mainColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
