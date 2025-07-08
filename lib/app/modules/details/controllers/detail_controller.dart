import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/services/booking_service.dart';
import 'package:tangaya_apps/app/data/services/event_service.dart';
import 'package:tangaya_apps/app/data/services/tourPackage_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/details/mixin/detailItem_mixin.dart';
import 'package:tangaya_apps/app/modules/details/mixin/heroImage_mixin.dart';
import 'package:tangaya_apps/app/modules/details/mixin/orderform_mixin.dart';

class DetailController extends GetxController
    with DetailItemMixin, HeroImageMixin, OrderFormMixin {
  final isLoading = true.obs;

  final TourPackageService _tourService = Get.find<TourPackageService>();
  final EventService _eventService = Get.find<EventService>();

  @override
  late final BookingService orderService;
  @override
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments == null ||
        Get.arguments['type'] == null ||
        Get.arguments['id'] == null) {
      debugPrint('Informasi item tidak lengkap.');
      Get.back();
      return;
    }

    itemType = Get.arguments['type'];
    itemId = Get.arguments['id'];

    orderService =
        Get.isRegistered<BookingService>()
            ? Get.find<BookingService>()
            : Get.put(BookingService());

    initFormControllers();
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
      } else {
        throw Exception('Tipe item tidak valid.');
      }

      if (fetchedData == null) {
        throw Exception('Item dengan ID "$itemId" tidak ditemukan.');
      }
      detailItem.value = fetchedData;
      initializeActiveHeroImage();
    } catch (e) {
      debugPrint('Gagal memuat detail: $e');
      detailItem.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
