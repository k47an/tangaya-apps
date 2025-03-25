import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/utils/global_components/main_button.dart';

class WelcomeView extends GetView<OnboardingController> {
  const WelcomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset('assets/images/logo.png'),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(80)),
              Text(
                "Jelajahi Destinasi Impian Anda",
                style: semiBold.copyWith(
                  fontSize: ScaleHelper(context).scaleTextForDevice(22),
                  color: Neutral.dark1,
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(18)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper(context).scaleWidthForDevice(24),
                ),
                child: Text(
                  "Temukan tempat wisata terbaik dan nikmati pengalaman tak terlupakan di berbagai destinasi menarik!",
                  style: regular.copyWith(
                    fontSize: ScaleHelper(context).scaleTextForDevice(12),
                    color: Neutral.dark3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(40)),
              MainButton(
                label: 'Masuk',
                onTap: () {
                  Get.toNamed(Routes.LOGIN);
                },
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(16)),
              GestureDetector(
                onTap: () {
                  // Get.toNamed(Routes.REGISTER);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ScaleHelper(context).scaleWidthForDevice(24),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: ScaleHelper(context).scaleHeightForDevice(16),
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Primary.mainColor),
                    color: Neutral.white4,
                  ),
                  child: Text(
                    'Daftar',
                    style: semiBold.copyWith(
                      fontSize: ScaleHelper(context).scaleTextForDevice(14),
                      color: Primary.mainColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
