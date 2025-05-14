import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/app/data/models/tour_package_model.dart';

class TourpackageWidget extends GetView<HomeController> {
  const TourpackageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.tourPackages.isEmpty) {
        return const Center(child: Text("Tidak ada data paket wisata."));
      }

      return ListView.separated(
        padding: ScaleHelper.paddingSymmetric(horizontal: 4),
        itemCount: controller.tourPackages.length,
        itemBuilder: (context, index) {
          final tour = controller.tourPackages[index];
          if (tour.imageUrls.isEmpty) return const SizedBox();
          return TourPackageCard(tour: tour);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 20),
      );
    });
  }
}

class TourPackageCard extends StatelessWidget {
  final TourPackage tour;

  const TourPackageCard({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.DETAIL_PACK, arguments: tour.id),
      child: Container(
        decoration: BoxDecoration(
          color: Neutral.white4,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Primary.darkColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                      bottom: Radius.circular(16),
                    ),
                    child: Image.network(
                      tour.imageUrls.first,
                      width: double.infinity,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Neutral.dark1.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      tour.title,
                      style: semiBold.copyWith(
                        fontSize: ScaleHelper.scaleTextForDevice(18),
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Neutral.dark1.withOpacity(0.5),
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: ScaleHelper.paddingSymmetric(
                horizontal: 14,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rp ${tour.price.toInt()}",
                          style: bold.copyWith(
                            fontSize: ScaleHelper.scaleTextForDevice(20),
                            color: Primary.darkColor,
                          ),
                        ),
                        SizedBox(height: ScaleHelper.scaleHeightForDevice(4)),
                        Text(
                          tour.description,
                          style: regular.copyWith(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(Routes.DETAIL_PACK, arguments: tour.id);
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 14),
                    label: Text("Pesan", style: medium.copyWith(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Primary.mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
