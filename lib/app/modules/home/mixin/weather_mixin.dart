import 'dart:async';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/api/api.dart';
import 'package:weather/weather.dart';

mixin WeatherMixin on GetxController {
  WeatherFactory wf = WeatherFactory(
    Api.keyWeather, // Ambil dari Api.keyWeather
    language: Language.INDONESIAN,
  );

  final Rx<Weather?> currentWeather = Rx<Weather?>(null);
  final double latitude = -0.708490224747233;
  final double longitude = 100.53330084137643;
  Timer? _timer;

  void fetchCurrentWeather() async {
    Weather weather = await wf.currentWeatherByLocation(latitude, longitude);
    currentWeather.value = weather;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCurrentWeather();
    _timer = Timer.periodic(Duration(hours: 1), (timer) {
      fetchCurrentWeather();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
