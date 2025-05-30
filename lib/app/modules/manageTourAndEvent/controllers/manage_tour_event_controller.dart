// managetoureventcontroller
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/event_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';

class ManageTourEventController extends GetxController
    with TourMixin, EventMixin {
  @override
  void onInit() {
    super.onInit();
    fetchTourPackages();
    fetchEvents();
  }

  @override
  void onClose() {
    // Dispose controllers yang dideklarasikan di TourMixin
    // Pastikan semua controller dari TourMixin juga di-dispose di sini jika ada tambahan
    tourPackageTitleController.dispose();
    tourPackageDescriptionController.dispose();
    tourPackagePriceController.dispose();
    // contoh jika ada controller lain di TourMixin:
    // tourDateController.dispose();
    // tourLocationController.dispose();

    // Dispose controllers yang dideklarasikan di EventMixin
    eventTitleController.dispose();
    eventDescriptionController.dispose();
    eventLocationController.dispose();
    eventPriceController.dispose(); // <-- Tambahkan ini

    super.onClose();
  }
}
