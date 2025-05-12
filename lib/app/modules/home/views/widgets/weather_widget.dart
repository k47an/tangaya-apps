import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/constant/constant.dart';
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
              top: -30,
              bottom: 0,
              left: -100,
              right: 100,
              child: Opacity(
                opacity: 0.1,
                child: Center(
                  child: Image.network(
                    "https://openweathermap.org/img/wn/${weather?.weatherIcon}.png",
                    height: ScaleHelper(context).scaleWidthForDevice(400),
                    width: ScaleHelper(context).scaleHeightForDevice(400),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScaleHelper(context).scaleWidthForDevice(20),
              vertical: ScaleHelper(context).scaleHeightForDevice(20),
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
                        fontSize: ScaleHelper(context).scaleTextForDevice(12),
                      ),
                    ),
                    Container(
                      width: ScaleHelper(context).scaleWidthForDevice(90),
                      padding: EdgeInsets.only(
                        left: ScaleHelper(context).scaleWidth(10),
                      ),
                      child: Stack(
                        children: [
                          Text(
                            weather?.temperature?.celsius?.toStringAsFixed(0) ??
                                '0',
                            style: extraBold.copyWith(
                              color: Primary.subtleColor,
                              fontSize: ScaleHelper(
                                context,
                              ).scaleTextForDevice(50),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            left: 53,
                            child: Text(
                              '°',
                              style: extraBold.copyWith(
                                color: Primary.subtleColor,
                                fontSize: ScaleHelper(
                                  context,
                                ).scaleTextForDevice(50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: ScaleHelper(context).scaleWidthForDevice(90),

                      child: Text(
                        '${(weather?.tempMin?.celsius?.toDouble() ?? 0).round()}°  /  ${(weather?.tempMax?.celsius?.toDouble() ?? 0).round()}°',
                        style: semiBold.copyWith(
                          color: Primary.subtleColor,
                          fontSize: ScaleHelper(context).scaleTextForDevice(12),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: ScaleHelper(context).scaleHeight(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Cuaca terkini',
                            style: regular.copyWith(
                              color: Primary.subtleColor,
                              fontSize: ScaleHelper(
                                context,
                              ).scaleTextForDevice(10),
                            ),
                          ),
                          Text(
                            'POKDARWIS Tangaya',
                            style: regular.copyWith(
                              color: Primary.subtleColor,
                              fontSize: ScaleHelper(
                                context,
                              ).scaleTextForDevice(10),
                            ),
                          ),
                        ],
                      ),

                      Text(
                        weather?.weatherDescription
                                ?.split(' ')
                                .map(
                                  (word) =>
                                      word[0].toUpperCase() + word.substring(1),
                                )
                                .join(' ') ??
                            'Tidak Tersedia',
                        style: bold.copyWith(
                          color: Primary.subtleColor,
                          fontSize: ScaleHelper(context).scaleTextForDevice(18),
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
