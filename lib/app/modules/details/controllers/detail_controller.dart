// lib/app/modules/detail/controllers/detail_controller.dart

import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/services/event_service.dart';
import 'package:tangaya_apps/app/data/services/order_service.dart';
import 'package:tangaya_apps/app/data/services/tourPackage_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/details/mixin/heroImage_mixin.dart';
import 'package:tangaya_apps/app/modules/details/mixin/orderform_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';

// Import mixins that we've created
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/event_mixin.dart';

class DetailController extends GetxController
    with TourMixin, EventMixin, HeroImageMixin, OrderFormMixin {
  final TourPackageService _tourService = Get.find<TourPackageService>();
  final EventService _eventService = Get.find<EventService>();
  // CORE STATE
  final isLoading = false.obs;
  @override
  final Rx<dynamic> detailItem = Rx<dynamic>(null); // Required by mixins

  // ARGUMENTS & DEPENDENCIES
  @override
  final String itemType = Get.arguments['type']; // Required by mixins
  @override
  final String itemId = Get.arguments['id']; // Required by mixins

  @override
  final authController = Get.find<AuthController>(); // Required by OrderDetailFormMixin
  @override
  late final OrderService orderService; // Required by OrderDetailFormMixin

  @override
  void onInit() {
    super.onInit();
    // Initialize dependencies
    orderService =
        Get.isRegistered<OrderService>()
            ? Get.find<OrderService>()
            : Get.put(OrderService());

    // Call init methods from mixins
    initFormControllers();

    // Start fetching data
    fetchDetail();
  }

  @override
  void onClose() {
    disposeFormControllers();
    super.onClose();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    try {
      dynamic fetchedData;
      if (itemType == 'tour') {
        fetchedData = await _tourService.getTourPackageById(itemId);
      } else if (itemType == 'event') {
        fetchedData = await _eventService.getEventById(itemId);
        throw Exception('Tipe item tidak valid.');
      }

      if (fetchedData == null) {
        throw Exception('Item tidak ditemukan.');
      }

      detailItem.value = fetchedData;

      initializeActiveHeroImage();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail: $e');
      detailItem.value = null;
      initializeActiveHeroImage();
    } finally {
      isLoading.value = false;
    }
  }
}
