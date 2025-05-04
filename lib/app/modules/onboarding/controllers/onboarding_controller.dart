import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingController extends GetxController {
  var selectedPageIndex = 0.obs;
  var pageController = PageController();
  bool get isLastPage => selectedPageIndex.value == items.length - 1;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  // Periksa status login pengguna
  void _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Jika sudah login, arahkan ke Home
      Get.offAllNamed(Routes.HOME);  // Ganti dengan rute halaman Home
    }
  }

  forwardAction() {
    if (isLastPage) {
      Get.toNamed(Routes.WELCOME);
    } else {
      pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
    }
  }

  List<OnboardingInfo> items = [
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
