import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.selectedPageIndex.call,
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: Get.height * 0.66,
                          decoration: const BoxDecoration(
                            color: Primary.subtleColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(120),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(120),
                          ),
                          child: Container(
                            width: Get.width,
                            height: Get.height * 0.62,
                            decoration: const BoxDecoration(
                              color: Primary.subtleColor,
                            ),
                            child: Image.asset(
                              controller.items[index].image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ScaleHelper(context).scaleHeightForDevice(20),
                    ),
                    Text(
                      controller.items[index].title,
                      style: semiBold.copyWith(
                        fontSize: ScaleHelper(context).scaleTextForDevice(24),
                        color: Neutral.dark1,
                      ),
                    ),
                    SizedBox(
                      height: ScaleHelper(context).scaleHeightForDevice(16),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScaleHelper(
                          context,
                        ).scaleWidthForDevice(24),
                      ),
                      child: Text(
                        controller.items[index].descriptions,
                        style: regular.copyWith(
                          fontSize: ScaleHelper(context).scaleTextForDevice(14),
                          color: Neutral.dark3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: ScaleHelper(context).scaleHeightForDevice(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.items.length,
                        (index) => Obx(() {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color:
                                  controller.selectedPageIndex.value == index
                                      ? Primary.mainColor
                                      : Neutral.dark4,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: ScaleHelper(context).scaleHeightForDevice(20),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.forwardAction();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: ScaleHelper(
                            context,
                          ).scaleWidthForDevice(24),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: ScaleHelper(
                            context,
                          ).scaleHeightForDevice(16),
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Primary.mainColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Lanjut",
                              style: semiBold.copyWith(
                                fontSize: ScaleHelper(
                                  context,
                                ).scaleTextForDevice(16),
                                color: Neutral.white1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
