import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/api/api.dart';
import 'package:weather/weather.dart';

mixin WeatherMixin on GetxController {
  WeatherFactory wf = WeatherFactory(
    KEY_WEATHER,
    language: Language.INDONESIAN,
  );

  final Rx<Weather?> currentWeather = Rx<Weather?>(null);
  final double latitude = -0.708490224747233;
  final double longitude = 100.53330084137643;

  void fetchCurrentWeather() async {
    Weather weather = await wf.currentWeatherByLocation(latitude, longitude);
    currentWeather.value = weather;
  }
}
