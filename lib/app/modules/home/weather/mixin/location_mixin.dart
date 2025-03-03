import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

mixin LocationMixin on GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoading = false.obs;

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      // Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak secara permanen, silakan aktifkan di pengaturan';
      }

      // Dapatkan posisi saat ini
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      currentPosition.value = position;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
