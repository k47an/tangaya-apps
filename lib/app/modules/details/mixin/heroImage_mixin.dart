import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/details/mixin/detailItem_mixin.dart';

mixin HeroImageMixin on GetxController implements DetailItemMixin {
  final RxString activeHeroImageUrl = ''.obs;

  void initializeActiveHeroImage() {
    final images = _getImageUrls();
    activeHeroImageUrl.value =
        images.isNotEmpty
            ? images.first
            : 'https://via.placeholder.com/600x400?text=No+Image';
  }

  void changeActiveHeroImage(String newUrl) {
    activeHeroImageUrl.value = newUrl;
  }

  List<String> _getImageUrls() {
    final item = detailItem.value;
    if (item == null) return [];

    switch (item.runtimeType) {
      case TourPackage:
        return (item as TourPackage).imageUrls ?? [];
      case Event:
        final imageUrl = (item as Event).imageUrl;
        return imageUrl.isNotEmpty ? [imageUrl] : [];
      default:
        return [];
    }
  }
}
