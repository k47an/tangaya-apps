import 'dart:async';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/weather/mixin/location_mixin.dart';
import 'package:weather/weather.dart';

class WeatherController extends GetxController with LocationMixin {
  WeatherFactory wf = WeatherFactory(
    "2b6f111cea2f3692611bd60d98159ea4",
    language: Language.INDONESIAN,
  );

  final Rx<Weather?> currentWeather = Rx<Weather?>(null);
  Timer? _timer;

  Future<void> getCurrentWeather() async {
    await getCurrentLocation();
    var location = currentPosition.value;
    if (location != null) {
      double latitude = location.latitude;
      double longitude = location.longitude;
      Weather weather = await wf.currentWeatherByLocation(latitude, longitude);
      currentWeather.value = weather;
      print(weather.toString());
    } else {
      print("Lokasi tidak ditemukan");
    }
  }

  void startLocationUpdates() {
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      getCurrentWeather();
    });
  }

  void stopLocationUpdates() {
    _timer?.cancel();
  }

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  @override
  void onReady() {
    super.onReady();
    // Mengambil cuaca saat ini setelah controller siap
    getCurrentWeather();
    // Mulai memperbarui lokasi setiap 5 menit
    startLocationUpdates();
  }

  @override
  void onClose() {
    // Hentikan pembaruan lokasi saat controller ditutup
    stopLocationUpdates();
    super.onClose();
  }
}
