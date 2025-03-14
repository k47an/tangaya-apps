import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tangaya_apps/app/constant/theme.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.themeData,
    ),
  );
}
