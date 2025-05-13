import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/utils/global_components/main_button.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [_buildPageView(), _buildBottomContent()]),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
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
              padding: ScaleHelper.paddingSymmetric(horizontal: 24),
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
    );
  }

  Widget _buildBottomContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: ScaleHelper.paddingSymmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.items.length,
                  (index) => Container(
                    margin: ScaleHelper.paddingAll(4),
                    width: ScaleHelper.scaleWidthForDevice(5),
                    height: ScaleHelper.scaleWidthForDevice(5),
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
            SizedBox(height: ScaleHelper.scaleHeightForDevice(5)),
            Obx(
              () => MainButton(
                label: controller.isLastPage ? 'Mulai' : 'Selanjutnya',
                onTap: controller.onMainButtonPressed,
                isEnabled: !controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
