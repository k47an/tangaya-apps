import 'package:get/get.dart';

import '../controllers/detail_pack_controller.dart';

class DetailPackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailPackController>(
      () => DetailPackController(),
    );
  }
}
