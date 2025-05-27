import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tangaya_apps/constant/constant.dart';

class TourpackageWidget extends GetView<HomeController> {
  const TourpackageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.cachedTours.isEmpty) {
        return const Center(child: Text("Tidak ada data paket wisata."));
      }

      return CarouselSlider.builder(
        itemCount: controller.cachedTours.length,
        itemBuilder: (context, index, realIndex) {
          final tour = controller.cachedTours[index];
          if (tour.imageUrls == null || tour.imageUrls!.isEmpty) {
            return const SizedBox();
          }
          return Container(
            margin: ScaleHelper.paddingOnly(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Neutral.dark1.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: TourPackageCard(tour: tour),
            ),
          );
        },
        options: CarouselOptions(
          height: 480,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          enableInfiniteScroll: false,
          onPageChanged: (index, reason) {
            controller.currentPage.value = index.toDouble();
          },
        ),
      );
    });
  }
}

class TourPackageCard extends StatelessWidget {
  final TourPackage tour;

  const TourPackageCard({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: tour.imageUrls!.first,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
        ),

        // Overlay gradient gelap dari bawah
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),

        // Konten informasi
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Desa Saniang Baka',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),

              Text(
                tour.title ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Text('Rp', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 4),
                  Text(
                    tour.price != null
                        ? NumberFormat('#,###', 'id_ID').format(tour.price)
                        : 'Tidak tersedia',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              Routes.DETAIL,
                              arguments: {'id': tour.id, 'type': 'tour'},
                            );
                          },
                          child: const Text(
                            "See more",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              Routes.DETAIL,
                              arguments: {'id': tour.id, 'type': 'tour'},
                            );
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
