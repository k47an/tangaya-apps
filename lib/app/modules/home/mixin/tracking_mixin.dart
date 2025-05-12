import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/tourPackageModel.dart';
import 'package:tangaya_apps/app/data/services/tourPackageService.dart';

mixin TrackingMixin on GetxController {
  final TourPackageService _tourPackageService = TourPackageService();
  final RxList<TourPackage> tourPackages = <TourPackage>[].obs;
  final RxBool isLoading = false.obs;


  // Mengambil daftar paket wisata
  Future<void> fetchTourPackages() async {
    try {
      isLoading.value = true;
      final packages = await _tourPackageService.fetchTourPackages();
      tourPackages.assignAll(packages);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil paket wisata: $e');
    } finally {
      isLoading.value = false;
    }
  }
}