import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/mixin/tourPackage_mixin.dart';
import 'package:tangaya_apps/app/modules/home/mixin/weather_mixin.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, WeatherMixin, TourpackageMixin {
  late TabController tabController;
  final RxInt currentTab = 0.obs;
  final RxBool isExpanded = false.obs;

  final List<Map<String, String>> tabs = [
    {'title': 'Tour Package', 'icon': 'assets/icons/tracking.svg'},
    {'title': 'Events', 'icon': 'assets/icons/edutourism.svg'},
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() => currentTab.value = tabController.index);
    fetchCurrentWeather();
    fetchTourPackages();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  String getTabIcon(int index) => tabs[index]['icon'] ?? '';
  String getTabTitle(int index) => tabs[index]['title'] ?? '';
}
