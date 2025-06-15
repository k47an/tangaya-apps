import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tangaya_apps/app/data/services/auth_services.dart';
import 'package:tangaya_apps/app/data/services/event_service.dart';
import 'package:tangaya_apps/app/data/services/booking_service.dart';
import 'package:tangaya_apps/app/data/services/midtrans_service.dart';
import 'package:tangaya_apps/app/data/services/tourPackage_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/constant/theme.dart';
import 'package:tangaya_apps/firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: FirebaseEnvOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  Get.put(AuthService());
  Get.put(AuthController());
  Get.put(TourPackageService());
  Get.put(EventService());
  Get.put(BookingService());
  Get.put(MidtransService());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pokdarwis Tangaya",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: AppTheme.themeData,
    ),
  );
}
