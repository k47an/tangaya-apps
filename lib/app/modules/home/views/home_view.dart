import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/header_widget.dart';
import 'package:tangaya_apps/app/modules/home/views/widgets/weather_widget.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            HeaderWidget(),
            Positioned(top: 150, left: 0, right: 0, child: WeatherWidget()),
            // Positioned(
            //   top: 300,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     padding: EdgeInsets.all(20),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(30),
            //         topRight: Radius.circular(30),
            //       ),
            //     ),
            //     child: Column(children: [Text('Content goes here')]),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
