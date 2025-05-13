import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/manageTour/controllers/manage_tour_controller.dart';
import 'package:tangaya_apps/constant/theme.dart';
import 'package:tangaya_apps/firebase_options.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("✅ Firebase Initialized");
  Get.put(AuthController());
  Get.put(ManageTourController());
  runApp(
    GetMaterialApp(
      title: "Pokdarwis Tangaya",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: AppTheme.themeData,
    ),
  );
}
