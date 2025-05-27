import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EventWidget extends GetView<HomeController> {
  const EventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.cachedEvents.isEmpty) {
        return const Center(child: Text("Tidak ada data event."));
      }

      return CarouselSlider.builder(
        itemCount: controller.cachedEvents.length,
        itemBuilder: (context, index, realIndex) {
          final event = controller.cachedEvents[index];
          if (event.imageUrl.isEmpty) {
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
              child: EventCard(event: event),
            ),
          );
        },

        options: CarouselOptions(
          height: 480,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
          enableInfiniteScroll: false,
          onPageChanged: (index, reason) {
            controller.currentPage.value = index.toDouble();
          },
        ),
      );
    });
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: event.imageUrl,
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
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.eventDate != null
                          ? DateFormat(
                            'd MMMM yyyy',
                            'id_ID',
                          ).format(event.eventDate)
                          : 'Tanggal tidak tersedia',
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
                                arguments: {'id': event.id, 'type': 'event'},
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
                                arguments: {'id': event.id, 'type': 'event'},
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
      ),
    );
  }
}
