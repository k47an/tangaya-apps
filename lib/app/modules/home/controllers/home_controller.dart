import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/mixin/weather_mixin.dart';

class HomeController extends GetxController with WeatherMixin {
  @override
  void onInit() {
    super.onInit();
    fetchCurrentWeather();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
