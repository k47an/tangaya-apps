import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/mixin/tracking_mixin.dart';
import 'package:tangaya_apps/app/modules/home/mixin/weather_mixin.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, WeatherMixin, TrackingMixin {
  late TabController tabController;
  RxInt currentTab = 0.obs;
  List<String> tabs = ['Tour Package', 'Events'];

  String getTabIcon(int index) {
    switch (index) {
      case 0:
        return 'assets/icons/tracking.svg';
      case 1:
        return 'assets/icons/edutourism.svg';
      default:
        return '';
    }
  }

  String getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Tour Package';
      case 1:
        return 'Events';
      default:
        return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      currentTab.value = tabController.index;
    });
    fetchCurrentWeather();
    fetchTrackingList();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
