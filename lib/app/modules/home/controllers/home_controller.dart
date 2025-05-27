import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/home/mixin/weather_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/event_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';

class HomeController extends GetxController
    with
        GetSingleTickerProviderStateMixin,
        WeatherMixin,
        TourMixin,
        EventMixin {
  late TabController tabController;
  final RxInt currentTab = 0.obs;

  final List<Map<String, String>> tabs = [
    {'title': 'Paket Wisata', 'icon': 'assets/icons/tracking.svg'},
    {'title': 'Event', 'icon': 'assets/icons/edutourism.svg'},
  ];

  final RxDouble currentPage = 0.0.obs;
  final RxDouble currentEventPage = 0.0.obs;

  final RxBool isLoading = false.obs;

  List<TourPackage> cachedTours = [];
  List<Event> cachedEvents = [];

  void refreshData() async {
    isLoading.value = true;

    await fetchTourPackages();
    await fetchEvents();
    fetchCurrentWeather();

    cachedTours = List.from(tourPackages);
    cachedEvents = List.from(events);

    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() => currentTab.value = tabController.index);

    refreshData();
  }

  @override
  void onClose() {
    tabController.dispose();

    super.onClose();
  }

  String getTabIcon(int index) => tabs[index]['icon'] ?? '';
  String getTabTitle(int index) => tabs[index]['title'] ?? '';
}
