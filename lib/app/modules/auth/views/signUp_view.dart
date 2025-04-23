import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

import '../../../../constant/constant.dart';
import '../../../../utils/global_components/text_input_field.dart';
import '../../../../utils/global_components/main_button.dart';
import '../../../routes/app_pages.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          // key: controller.registerFormKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mulai Perjalanan Anda',
                    style: semiBold.copyWith(
                      fontSize: 24,
                      color: Primary.mainColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Daftar untuk Memulai Perjalanan Menuju Distinasi Wisata Pilihan Anda',
                    style: regular.copyWith(fontSize: 16, color: Neutral.dark3),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(30)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: medium.copyWith(fontSize: 16, color: Neutral.dark1),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: InputField(
                  title: 'Masukan Email',
                  // validator: (email) => controller.validateEmail(email),
                  // onChanged: controller.setEmailR,
                  onChanged: (value) {
                    // controller.setEmailR(value);
                    // controller.validateEmail(value);
                  },
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(16)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username',
                    style: medium.copyWith(fontSize: 16, color: Neutral.dark1),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: InputField(
                  title: 'Ketikkan Username',
                  // validator:
                  //     (username) => controller.validateUsername(username),
                  // onChanged: controller.setUserNameR,
                  onChanged: (value) {
                    // controller.setUserNameR(value);
                    // controller.validateUsername(value);
                  },
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(16)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: medium.copyWith(fontSize: 16, color: Neutral.dark1),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: InputField(
                    title: 'Ketikkan Password',
                    // onChanged: controller.setPasswordR,
                    onChanged: (value) {
                      // controller.setPasswordR(value);
                      // controller.validatePassword(value);
                    },
                    obscureText: controller.obscureText.value,
                    // validator: (pwd) => controller.validatePassword(pwd),
                    icon: GestureDetector(
                      onTap: () {
                        controller.togglePasswordVisibility();
                      },
                      child: SizedBox(
                        width: 10,
                        height: 20,
                        child: SvgPicture.asset(
                          controller.obscureText.value
                              ? 'assets/icons/eye-closed.svg'
                              : 'assets/icons/eye-open.svg',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(16)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Konfirmasi Password',
                    style: medium.copyWith(fontSize: 16, color: Neutral.dark1),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(10)),
              Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScaleHelper(context).scaleWidthForDevice(22),
                  ),
                  child: InputField(
                    title: 'Ketikkan konfirmasi password',
                    // onChanged: controller.setConfirmPasswordR,
                    onChanged: (value) {
                      // controller.setConfirmPasswordR(value);
                      // controller.validateConfirmPassword(value);
                    },
                    obscureText: controller.obscureText.value,
                    // validator:
                    //     (pwd) => controller.validateConfirmPassword(pwd),
                    icon: GestureDetector(
                      onTap: () {
                        controller.togglePasswordVisibility();
                      },
                      child: SizedBox(
                        width: 10,
                        height: 20,
                        child: SvgPicture.asset(
                          controller.obscureText.value
                              ? 'assets/icons/eye-closed.svg'
                              : 'assets/icons/eye-open.svg',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(30)),
              // Obx(
              //   () =>
              MainButton(
                label: 'Daftar',
                // isEnabled: controller.isFormValid.value,
                onTap: () {
                  // controller.doRegister();
                },
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: medium.copyWith(
                      fontSize: ScaleHelper(context).scaleTextForDevice(16),
                      color: Neutral.dark1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.SIGNIN);
                    },
                    child: Text(
                      'Masuk',
                      style: bold.copyWith(
                        fontSize: ScaleHelper(context).scaleTextForDevice(16),
                        color: Primary.mainColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScaleHelper(context).scaleHeightForDevice(20)),
            ],
          ),
        ),
      ),
    );
  }
}
