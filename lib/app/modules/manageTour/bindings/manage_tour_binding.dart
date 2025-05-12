import 'package:get/get.dart';

import '../controllers/manage_tour_controller.dart';

class ManageTourBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageTourController>(
      () => ManageTourController(),
    );
  }
}
