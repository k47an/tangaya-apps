import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  late PageController pageController;
  final selectedPageIndex = 0.obs;
  final isLoading = false.obs;

  final List<OnboardingInfo> items = [
    OnboardingInfo(
      title: "Camping",
      descriptions:
          "Nikmati pengalaman berkemah yang seru dengan lokasi terbaik dan fasilitas lengkap",
      image: "assets/images/camp.jpg",
    ),
    OnboardingInfo(
      title: "Tracking",
      descriptions:
          "Jelajahi alam bebas dengan rute tracking menantang dan pemandangan menakjubkan",
      image: "assets/images/tracking.jpg",
    ),
    OnboardingInfo(
      title: "Edutour",
      descriptions:
          "Pelajari sejarah, budaya, dan keindahan alam dalam perjalanan wisata edukatif",
      image: "assets/images/edutor.jpg",
    ),
  ];

  bool get isLastPage => selectedPageIndex.value == items.length - 1;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void onMainButtonPressed() {
    if (isLastPage) {
      Get.toNamed(Routes.WELCOME);
    } else {
      if (pageController.hasClients) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingInfo {
  final String title;
  final String descriptions;
  final String image;

  OnboardingInfo({
    required this.title,
    required this.descriptions,
    required this.image,
  });
}
