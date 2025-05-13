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
                final item = controller.items[index];
                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: ScaleHelper.scaleHeightForDevice(500),
                          decoration: const BoxDecoration(
                            color: Primary.mainColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(120),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(120),
                          ),
                          child: SizedBox(
                            width: Get.width,
                            height: ScaleHelper.scaleHeightForDevice(480),
                            child: Image.asset(item.image, fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScaleHelper.scaleHeightForDevice(20)),
                    Text(
                      item.title,
                      style: bold.copyWith(
                        fontSize: ScaleHelper.scaleTextForDevice(28),
                        color: Neutral.dark1,
                      ),
                    ),
                    SizedBox(height: ScaleHelper.scaleHeightForDevice(16)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScaleHelper.scaleWidthForDevice(24),
                      ),
                      child: Text(
                        item.descriptions,
                        style: regular.copyWith(
                          fontSize: ScaleHelper.scaleTextForDevice(14),
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
                  bottom: ScaleHelper.scaleHeightForDevice(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.items.length,
                          (index) => Container(
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
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScaleHelper.scaleHeightForDevice(20)),
                    GestureDetector(
                      onTap: controller.nextPage,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: ScaleHelper.scaleWidthForDevice(24),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: ScaleHelper.scaleHeightForDevice(16),
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Primary.mainColor,
                        ),
                        child: Text(
                          "Lanjut",
                          style: semiBold.copyWith(
                            fontSize: ScaleHelper.scaleTextForDevice(16),
                            color: Neutral.white1,
                          ),
                          textAlign: TextAlign.center,
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
