import 'package:get/get.dart';

import '../controllers/detail_controller.dart';

class DetailPackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailController>(() => DetailController());
  }
}
