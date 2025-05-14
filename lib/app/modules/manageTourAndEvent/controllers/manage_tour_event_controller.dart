import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/event_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';

class ManageTourEventController extends GetxController with TourMixin, EventMixin {
  @override
  void onInit() {
    super.onInit();
    fetchTourPackages(); 
    fetchEvents();       
  }

  @override
  void onClose() {
    // Dispose controllers yang dideklarasikan di TourMixin
    tourPackageTitleController.dispose();
    tourPackageDescriptionController.dispose();
    tourPackagePriceController.dispose();

    // Dispose controllers yang dideklarasikan di EventMixin
    eventTitleController.dispose();
    eventDescriptionController.dispose();
    eventLocationController.dispose();

    super.onClose();
  }
}