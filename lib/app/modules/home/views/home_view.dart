import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/camping_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/edutour_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/header_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/tracking_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/weather_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return WillPopScope(
      onWillPop: () async {
        // Keluar aplikasi ketika tombol back ditekan
        SystemNavigator.pop(); // atau exit(0)
        return false;
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
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
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    padding: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Primary.subtleColor,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Neutral.dark1.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          labelColor: Primary.mainColor,
                          unselectedLabelColor: Colors.grey,
                          controller: controller.tabController,
                          dividerColor: Neutral.transparent,
                          tabAlignment: TabAlignment.center,
                          indicatorWeight: ScaleHelper(
                            context,
                          ).scaleHeightForDevice(1),
                          indicatorColor: Primary.mainColor,
                          indicatorPadding: EdgeInsets.symmetric(
                            vertical: ScaleHelper(
                              context,
                            ).scaleHeightForDevice(5),
                          ),
                          tabs: List.generate(
                            controller.tabs.length,
                            (index) => Obx(
                              () => Tab(
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      controller.getTabIcon(index),
                                      width: ScaleHelper(
                                        context,
                                      ).scaleWidthForDevice(15),
                                      height: ScaleHelper(
                                        context,
                                      ).scaleHeightForDevice(15),
                                      color:
                                          controller.currentTab.value == index
                                              ? Primary.mainColor
                                              : Colors.grey,
                                    ),
                                    SizedBox(
                                      width: ScaleHelper(
                                        context,
                                      ).scaleWidthForDevice(8),
                                    ),
                                    Text(
                                      controller.getTabTitle(index),
                                      style: TextStyle(
                                        color:
                                            controller.currentTab.value == index
                                                ? Primary.mainColor
                                                : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScaleHelper(context).scaleHeightForDevice(10),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: controller.tabController,
                            children: const [
                              TrackingWidget(),
                              CampingWidget(),
                              EdutourWidget(),
                            ],
                          ),
                        ),
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
}
