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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => HeaderWidget(
                    displayName: authController.userName,
                    photoURL: authController.userPhotoURL,
                  ),
                ),
                const WeatherWidget(),
                Padding(
                  padding: ScaleHelper.paddingOnly(
                    left: 20,
                    right: 20,
                    top: 30,
                  ),
                  child: Text(
                    'Pilih Kategori',
                    style: medium.copyWith(
                      fontSize: ScaleHelper.scaleTextForDevice(20),
                      color: Colors.white,
                    ),
                  ),
                ),
                // Tab bar dan konten
                Expanded(
                  child: Column(
                    children: [
                      _buildTabBar(),
                      Expanded(child: _buildTabBarView()),
                    ],
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
      margin: EdgeInsets.symmetric(
        vertical: ScaleHelper.scaleHeightForDevice(10),
      ),

      child: Obx(() {
        return TabBar(
          controller: controller.tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 2.0, color: Neutral.white2),
            insets: EdgeInsets.symmetric(
              horizontal: ScaleHelper.scaleWidthForDevice(32),
            ),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Neutral.transparent,
          labelPadding: EdgeInsets.zero,
          tabs: List.generate(controller.tabs.length, (index) {
            final isSelected = controller.currentTab.value == index;
            return GestureDetector(
              onTap: () {
                controller.tabController.animateTo(index);
                controller.currentTab.value = index;
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: ScaleHelper.scaleHeightForDevice(
                    5,
                  ), // Tambahkan jarak antara garis dan text
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      controller.getTabIcon(index),
                      width: ScaleHelper.scaleWidthForDevice(20),
                      height: ScaleHelper.scaleHeightForDevice(20),
                      color: isSelected ? Neutral.white1 : Neutral.white4,
                    ),
                    SizedBox(width: ScaleHelper.scaleWidthForDevice(8)),
                    Text(
                      controller.getTabTitle(index),
                      style: TextStyle(
                        color: isSelected ? Neutral.white1 : Neutral.white4,
                        fontSize: ScaleHelper.scaleTextForDevice(14),
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildTabBarView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: TabBarView(
        controller: controller.tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [TourpackageWidget(), EventWidget()],
      ),
    );
  }
}
