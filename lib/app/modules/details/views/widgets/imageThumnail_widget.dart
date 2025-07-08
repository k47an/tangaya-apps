import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/details/controllers/detail_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ImageThumbnailsWidget extends GetView<DetailController> {
  final List<String> imageUrls;

  const ImageThumbnailsWidget({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final thumbnailUrl = imageUrls[index];
          return Obx(() {
            bool isActive = controller.activeHeroImageUrl.value == thumbnailUrl;
            return InkWell(
              // =========================================================
              // PERBAIKAN DI SINI: Sesuaikan nama methodnya
              // =========================================================
              onTap: () => controller.changeActiveHeroImage(thumbnailUrl),
              child: Container(
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(color: Primary.mainColor, width: 2.5)
                      : Border.all(color: Colors.grey.shade300, width: 1.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isActive ? 9.5 : 11.0),
                  child: Image.network(
                    thumbnailUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}