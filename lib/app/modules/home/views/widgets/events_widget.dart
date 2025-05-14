import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EventsWidget extends GetView<HomeController> {
  const EventsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isEventLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.events.isEmpty) {
        return const Center(child: Text("Tidak ada data event."));
      }

      return ListView.separated(
        padding: ScaleHelper.paddingSymmetric(horizontal: 4),
        itemCount: controller.events.length,
        itemBuilder: (context, index) {
          final event = controller.events[index];
          if (event.imageUrl.isEmpty) {
            return const SizedBox();
          }
          return EventCard(event: event);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 20),
      );
    });
  }
}

class EventCard extends StatelessWidget {
  final dynamic event; 
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Get.toNamed(
            Routes.DETAIL,
            arguments: {'id': event.id, 'type': 'event'},
          ),
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
                      event.imageUrl!, // Asumsi ada imageUrls dan tidak kosong
                      width: double.infinity,
                      fit: BoxFit.fitHeight,
                      height: 150, // Sesuaikan tinggi sesuai kebutuhan
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: Center(child: Icon(Icons.image_not_supported)),
                        );
                      },
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
                      event.title ?? '', // Asumsi ada properti title
                      style: semiBold.copyWith(
                        fontSize: ScaleHelper.scaleTextForDevice(18),
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Neutral.dark1.withOpacity(0.5),
                            offset: const Offset(0, 1),
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
                          event.title ?? '', // Asumsi ada properti nama event
                          style: bold.copyWith(
                            fontSize: ScaleHelper.scaleTextForDevice(20),
                            color: Primary.darkColor,
                          ),
                        ),
                        SizedBox(height: ScaleHelper.scaleHeightForDevice(4)),
                        Text(
                          event.description ??
                              '', // Asumsi ada properti deskripsi
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
                      // Navigasi ke detail event
                      // Get.toNamed(Routes.DETAIL_EVENT, arguments: event.id);
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 14),
                    label: Text("Lihat", style: medium.copyWith(fontSize: 14)),
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
