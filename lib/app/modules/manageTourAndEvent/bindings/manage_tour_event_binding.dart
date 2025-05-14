import 'package:get/get.dart';

import '../controllers/manage_tour_event_controller.dart';

class ManageTourEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageTourEventController>(() => ManageTourEventController());
  }
}
