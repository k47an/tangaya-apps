import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/constant/constant.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/camping_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/edutour_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/header_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/tracking_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/weather_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Primary.darkColor, Primary.mainColor, Primary.subtleColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Column(
          children: [
            const HeaderWidget(),
            const WeatherWidget(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
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
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Primary.mainColor,
                      unselectedLabelColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      controller: controller.tabController,
                      dividerColor: Neutral.transparent,
                      tabAlignment: TabAlignment.center,
                      indicatorColor: Primary.mainColor,
                      tabs: List.generate(
                        controller.tabs.length,
                        (index) => Obx(
                          () => Tab(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  controller.getTabIcon(index),
                                  width: 20,
                                  height: 20,
                                  color:
                                      controller.currentTab.value == index
                                          ? Primary.mainColor
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 10),
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
    );
  }
}
