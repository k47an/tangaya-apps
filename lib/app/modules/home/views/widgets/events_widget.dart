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
      if (controller.isEventLoading.value && controller.events.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Primary.mainColor),
        );
      }

      if (controller.events.isEmpty) {
        return const Center(child: Text("Tidak ada data event."));
      }

      return CarouselSlider.builder(
        itemCount: controller.events.length,
        itemBuilder: (context, index, realIndex) {
          final event = controller.events[index];
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: ScaleHelper.paddingOnly(bottom: 10),
            child: EventCard(event: event),
          );
        },
        options: CarouselOptions(
          height: 495,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
          enableInfiniteScroll: controller.events.length > 1,
          autoPlay: controller.events.length > 1,
          autoPlayInterval: const Duration(seconds: 5),
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

  String _formatPrice(double? price) {
    if (price == null || price == 0) {
      return 'Gratis';
    }
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: event.imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 60,
                    ),
                  ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6],
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
                mainAxisSize: MainAxisSize.min,
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
                      fontSize: 20,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                        DateFormat(
                          'd MMMM yyyy',
                          'id_ID',
                        ).format(event.eventDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        (event.price == null || event.price == 0)
                            ? Icons.local_offer_outlined
                            : Icons.sell_outlined,
                        size: 14,
                        color:
                            (event.price == null || event.price == 0)
                                ? Colors.greenAccent[400]
                                : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatPrice(event.price),
                        style: TextStyle(
                          color:
                              (event.price == null || event.price == 0)
                                  ? Colors.greenAccent[400]
                                  : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.DETAIL,
                        arguments: {'id': event.id, 'type': 'event'},
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white30,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Lihat Detail",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
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
