import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/home/mixin/weather_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/event_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, WeatherMixin, TourMixin, EventMixin {
  late TabController tabController;
  final RxInt currentTab = 0.obs;
  final RxBool isExpanded = false.obs;

  final List<Map<String, String>> tabs = [
    {'title': 'Tour Package', 'icon': 'assets/icons/tracking.svg'},
    {'title': 'Events', 'icon': 'assets/icons/edutourism.svg'},
  ];

  // Getter untuk memudahkan akses data tour dan event di view
  RxList<TourPackage> get popularTours => tourPackages; 
  // Asumsi Anda punya ini di EventMixin:
  RxList<Event> get upcomingEvents => events; // Langsung dari EventMixin

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() => currentTab.value = tabController.index);
    fetchCurrentWeather();
    fetchTourPackages();
    fetchEvents();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  String getTabIcon(int index) => tabs[index]['icon'] ?? '';
  String getTabTitle(int index) => tabs[index]['title'] ?? '';
}