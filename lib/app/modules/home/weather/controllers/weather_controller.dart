import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/weather/mixin/location_mixin.dart';
import 'package:weather/weather.dart';

class WeatherController extends GetxController with LocationMixin {
  WeatherFactory wf = new WeatherFactory(
    "2b6f111cea2f3692611bd60d98159ea4",
    language: Language.INDONESIAN,
  );

  final Rx<Weather?> currentWeather = Rx<Weather?>(null);

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
  }

  @override
  void onClose() {
    super.onClose();
  }
}
