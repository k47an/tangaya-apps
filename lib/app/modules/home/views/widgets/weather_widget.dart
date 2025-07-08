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

      final weatherIconUrl =
          weather?.weatherIcon != null
              ? "https://openweathermap.org/img/wn/${weather!.weatherIcon}@4x.png"
              : null;

      final temperature =
          weather?.temperature?.celsius?.toStringAsFixed(0) ?? '0';
      final tempMin = weather?.tempMin?.celsius?.round() ?? 0;
      final tempMax = weather?.tempMax?.celsius?.round() ?? 0;
      final weatherDesc =
          weather?.weatherDescription != null
              ? weather!.weatherDescription!
                  .split(' ')
                  .map((word) => word[0].toUpperCase() + word.substring(1))
                  .join(' ')
              : 'Tidak Tersedia';

      return Card(
        color: Neutral.white1.withOpacity(0.1),
        margin: ScaleHelper.paddingSymmetric(horizontal: 20, vertical: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: ScaleHelper.paddingSymmetric(horizontal: 10, vertical: 16),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (weatherIconUrl != null)
                    Image.network(
                      weatherIconUrl,
                      width: ScaleHelper.scaleWidthForDevice(120),
                      height: ScaleHelper.scaleWidthForDevice(80),
                      fit: BoxFit.fitWidth,
                    )
                  else
                    Icon(
                      Icons.wb_cloudy,
                      size: ScaleHelper.scaleWidthForDevice(100),
                      color: Colors.white.withOpacity(0.6),
                    ),
                  Text(
                    weatherDesc,
                    style: semiBold.copyWith(
                      fontSize: ScaleHelper.scaleTextForDevice(14),
                      color: Primary.subtleColor,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Pokdarwis Tangaya',
                      style: regular.copyWith(
                        fontSize: ScaleHelper.scaleTextForDevice(10),
                        color: Neutral.white1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          temperature,
                          style: extraBold.copyWith(
                            fontSize: ScaleHelper.scaleTextForDevice(44),
                            color: Primary.subtleColor,
                          ),
                        ),
                        Text(
                          '°C',
                          style: extraBold.copyWith(
                            fontSize: ScaleHelper.scaleTextForDevice(28),
                            color: Primary.subtleColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$tempMin° / $tempMax°',
                      style: regular.copyWith(
                        fontSize: ScaleHelper.scaleTextForDevice(12),
                        color: Primary.subtleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
