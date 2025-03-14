import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/constant/constant.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';

class WeatherWidget extends GetView<HomeController> {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Obx(() {
        final weather = controller.currentWeather.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temp',
                  style: light.copyWith(color: Neutral.dark1, fontSize: 12),
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
                          color: Neutral.dark1,
                          fontSize: 50,
                        ),
                      ),
                      Positioned(
                        top: -10,
                        left: 53,
                        child: Text(
                          '°c',
                          style: extraBold.copyWith(
                            color: Neutral.dark1,
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
                    '${weather?.tempMin?.celsius?.toStringAsFixed(0) ?? '0'}°  /  ${weather?.tempMax?.celsius?.toStringAsFixed(0) ?? '0'}°',
                    style: light.copyWith(color: Neutral.dark1, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Cuaca terkini',
                      style: regular.copyWith(
                        color: Neutral.dark1,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'POKDARWIS Tangaya',
                      style: regular.copyWith(
                        color: Neutral.dark1,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Image.network(
                  'http://openweathermap.org/img/w/${weather?.weatherIcon ?? '01d'}.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                Text(
                  weather?.weatherDescription ?? 'Tidak tersedia',
                  style: extraBold.copyWith(color: Neutral.dark1, fontSize: 16),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
