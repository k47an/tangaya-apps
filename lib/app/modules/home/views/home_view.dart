import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/events_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/header_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/tourPackage_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/weather_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: Scaffold(
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Primary.darkColor,
                  Primary.mainColor,
                  Primary.subtleColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.1, 0.5, 0.9],
              ),
            ),
            child: Column(
              children: [
                Obx(
                  () => HeaderWidget(
                    displayName: authController.userName,
                    photoURL: authController.userPhotoURL,
                  ),
                ),
                const WeatherWidget(),
                Expanded(
                  child: Container(
                    margin: ScaleHelper.paddingOnly(top: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Neutral.white4,
                    ),
                    child: Column(
                      children: [
                        _buildTabBar(),
                        SizedBox(height: ScaleHelper.scaleHeightForDevice(10)),
                        Expanded(child: _buildTabBarView()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: ScaleHelper.paddingSymmetric(horizontal: 30),
      child: TabBar(
        controller: controller.tabController,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Neutral.white4,
        dividerColor: Neutral.transparent,
        indicatorWeight: ScaleHelper.scaleHeightForDevice(0.5),
        indicatorColor: Primary.darkColor,
        indicatorPadding: ScaleHelper.paddingSymmetric(vertical: 5),
        tabs: List.generate(controller.tabs.length, (index) {
          return Obx(
            () => Tab(
              child: IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      controller.getTabIcon(index),
                      width: ScaleHelper.scaleWidthForDevice(20),
                      height: ScaleHelper.scaleHeightForDevice(20),
                      color:
                          controller.currentTab.value == index
                              ? Primary.darkColor
                              : Neutral.dark5,
                    ),
                    SizedBox(width: ScaleHelper.scaleWidthForDevice(8)),
                    Text(
                      controller.getTabTitle(index),
                      style: TextStyle(
                        color:
                            controller.currentTab.value == index
                                ? Primary.darkColor
                                : Neutral.dark5,
                        fontSize: ScaleHelper.scaleTextForDevice(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: controller.tabController,
      children: const [TourpackageWidget(), EventsWidget()],
    );
  }
}
