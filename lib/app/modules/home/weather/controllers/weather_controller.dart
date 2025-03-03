import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/weather/mixin/location_mixin.dart';

class WeatherController extends GetxController with LocationMixin {
  @override
  void onInit() {
    getCurrentLocation();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
