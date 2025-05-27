import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/theme.dart';
import 'package:tangaya_apps/firebase_options.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  debugPrint("✅ Firebase Initialized");
  Get.put(AuthController());
  Get.put(ManageTourEventController());
  runApp(
    GetMaterialApp(
      title: "Pokdarwis Tangaya",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: AppTheme.themeData,
    ),
  );
}
