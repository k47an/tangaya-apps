import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';

mixin HeroImageMixin {
  Rx<dynamic> get detailItem;
  final RxString activeHeroImageUrl = "".obs;

  void changeHeroImage(String newUrl) {
    activeHeroImageUrl.value = newUrl;
  }

  void initializeActiveHeroImage() {
    String newUrl = "https://via.placeholder.com/600x400?text=No+Image";

    if (detailItem.value != null) {
      final item = detailItem.value;
      if (item is TourPackage &&
          item.imageUrls != null &&
          item.imageUrls!.isNotEmpty) {
        newUrl = item.imageUrls!.first;
      } else if (item is Event && item.imageUrl.isNotEmpty) {
        newUrl = item.imageUrl;
      }
    } else {
      newUrl = "https://via.placeholder.com/600x400?text=Item+Not+Available";
    }
    activeHeroImageUrl.value = newUrl;
  }
}
