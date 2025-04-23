import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/auth/views/components/auth_button.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/utils/global_components/main_button.dart';
import 'package:tangaya_apps/utils/global_components/text_input_field.dart';

class SignInView extends GetView<AuthController> {
  const SignInView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper(context).scaleWidthForDevice(22),
                  vertical: ScaleHelper(context).scaleHeightForDevice(20),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selamat Datang Kembali!',
                    style: semiBold.copyWith(
                      fontSize: ScaleHelper(context).scaleTextForDevice(24),
                      color: Primary.mainColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(16)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper(context).scaleWidthForDevice(22),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Masuk untuk bisa melakukan pemesanan!',
                    style: regular.copyWith(
                      fontSize: ScaleHelper(context).scaleTextForDevice(18),
                      color: Neutral.dark3,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(32)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper(context).scaleWidthForDevice(22),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username',
                    style: medium.copyWith(
                      fontSize: ScaleHelper(context).scaleTextForDevice(16),
                      color: Neutral.dark1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper(context).scaleWidthForDevice(22),
                ),
                child: InputField(
                  title: 'Ketikkan Username',
                  validator: (String) {},
                  // (username) => controller.validateUsername(username),
                  onChanged: (String) {},
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper(context).scaleWidthForDevice(22),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: medium.copyWith(
                      fontSize: ScaleHelper(context).scaleTextForDevice(16),
                      color: Neutral.dark1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleHelper(context).scaleWidthForDevice(22),
                ),
                child: InputField(
                  title: 'Ketikkan Password',
                  onChanged: (String) {},
                  obscureText: controller.obscureText.value,
                  icon: GestureDetector(
                    onTap: () {
                      controller.obscureText.value =
                          !controller.obscureText.value;
                    },
                    child: SvgPicture.asset(
                      controller.obscureText.value
                          ? 'assets/icons/eye-closed.svg'
                          : 'assets/icons/eye-open.svg',
                    ),
                  ),
                  errorIcon: SvgPicture.asset('assets/icons/error-icon.svg'),
                  errorText:
                      controller.passwordError.value.isEmpty
                          ? null
                          : controller.passwordError.value,
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: ScaleHelper(context).scaleWidthForDevice(24),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Implement Forgot Password
                      // Get.offNamed(Routes.FORGOT_PASSWORD);
                    },
                    child: Text(
                      'Lupa Password?',
                      style: medium.copyWith(
                        fontSize: ScaleHelper(context).scaleTextForDevice(16),
                        color: Neutral.dark2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(32)),

              MainButton(
                label: 'Masuk',
                // isEnabled: controller.isFormValid.value,
                onTap: () {
                  // controller.isFormValid.value
                  //     ? () {
                  //       controller.doLogin();
                  //     }
                  // : null,
                },
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(50)),
              Text(
                'Atau masuk dengan',
                style: medium.copyWith(
                  fontSize: ScaleHelper(context).scaleTextForDevice(14),
                  color: Neutral.dark3,
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthButton(
                    svgAssetPath: 'assets/icons/google.svg',
                    label: 'Google',
                    onTap: () {
                      controller.handleGoogleSignIn();
                    },
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ScaleHelper(context).scaleHeightForDevice(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: medium.copyWith(
                        fontSize: 16,
                        color: Neutral.dark1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.SIGNUP);
                      },
                      child: Text(
                        'Daftar',
                        style: bold.copyWith(
                          fontSize: 16,
                          color: Primary.mainColor,
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
