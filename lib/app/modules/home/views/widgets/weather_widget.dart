import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/constant/constant.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';

class WeatherWidget extends GetView<HomeController> {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final weather = controller.currentWeather.value;
      return Stack(
        children: [
          if (weather?.weatherIcon != null)
            Positioned(
              top: -20,
              bottom: 0,
              left: -100,
              right: 100,
              child: Opacity(
                opacity: 0.1,
                child: Center(
                  child: Image.network(
                    "https://openweathermap.org/img/wn/${weather?.weatherIcon}.png",
                    height: 400,
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              top: 20,
              right: 30,
              bottom: 40,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temp',
                      style: light.copyWith(
                        color: Primary.subtleColor,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(left: 10),
                      child: Stack(
                        children: [
                          Text(
                            weather?.temperature?.celsius?.toStringAsFixed(0) ??
                                '0',
                            style: extraBold.copyWith(
                              color: Primary.subtleColor,
                              fontSize: 50,
                            ),
                          ),
                          Positioned(
                            top: -10,
                            left: 53,
                            child: Text(
                              '°c',
                              style: extraBold.copyWith(
                                color: Primary.subtleColor,
                                fontSize: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 90,
                      child: Text(
                        '${(weather?.tempMin?.celsius?.toDouble() ?? 0).round()}°  /  ${(weather?.tempMax?.celsius?.toDouble() ?? 0).round()}°',
                        style: light.copyWith(
                          color: Primary.subtleColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Cuaca terkini',
                            style: regular.copyWith(
                              color: Primary.subtleColor,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'POKDARWIS Tangaya',
                            style: regular.copyWith(
                              color: Primary.subtleColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        weather?.weatherDescription ?? 'Tidak tersedia',
                        style: bold.copyWith(
                          color: Primary.subtleColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
