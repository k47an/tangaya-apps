import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/auth/views/components/auth_button.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';

class SignInView extends GetView<AuthController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ScaleHelper.scaleWidthForDevice(22),
            vertical: ScaleHelper.scaleHeightForDevice(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang Kembali!',
                style: semiBold.copyWith(
                  fontSize: ScaleHelper.scaleTextForDevice(24),
                  color: Primary.mainColor,
                ),
              ),
              SizedBox(height: ScaleHelper.scaleHeightForDevice(16)),
              Text(
                'Masuk untuk bisa melakukan pemesanan!',
                style: regular.copyWith(
                  fontSize: ScaleHelper.scaleTextForDevice(18),
                  color: Neutral.dark3,
                ),
              ),
              SizedBox(height: ScaleHelper.scaleHeightForDevice(32)),
              Center(
                child: AuthButton(
                  svgAssetPath: 'assets/icons/google.svg',
                  label: 'Sign In With Google',
                  onTap: () async {
                    final result = await controller.signInWithGoogle();
                    if (result) {
                      Get.toNamed(Routes.HOME);
                    }
                  },
                ),
              ),
              SizedBox(height: ScaleHelper.scaleHeightForDevice(30)),
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.HOME),
                  child: Text(
                    'Masuk sebagai tamu?',
                    style: bold.copyWith(
                      fontSize: ScaleHelper.scaleTextForDevice(16),
                      color: Neutral.dark2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper.scaleHeightForDevice(20)),
            ],
          ),
        ),
      ),
    );
  }
}
