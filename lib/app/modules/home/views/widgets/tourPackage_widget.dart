import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';

class TourpackageWidget extends GetView<HomeController> {
  const TourpackageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.tourPackages.isEmpty) {
        return const Center(child: Text("Tidak ada data tracking."));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
        itemCount: controller.tourPackages.length,
        itemBuilder: (context, index) {
          final tracking = controller.tourPackages[index];
          if (tracking.imageUrls.isEmpty) return const SizedBox();

          return ArticleCard(
            id: tracking.id,
            imageUrls: tracking.imageUrls,
            title: tracking.title,
            description: tracking.description,
            price: tracking.price.toInt(),
          );
        },
      );
    });
  }
}

class ArticleCard extends StatelessWidget {
  final List<String> imageUrls;
  final String title;
  final String description;
  final int price;
  final String id;

  ArticleCard({
    super.key,
    required this.imageUrls,
    required this.title,
    required this.description,
    required this.price,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Neutral.white2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.DETAIL_PACK, arguments: id);
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(imageUrls.first),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: semiBold.copyWith(
                          fontSize: 24,
                          color: Neutral.dark1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp $price",
                        style: medium.copyWith(
                          fontSize: 20,
                          color: Primary.darkColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      print("Pesan Sekarang clicked");
                    },
                    child: Row(
                      children: [
                        Text(
                          "Pesan",
                          style: medium.copyWith(
                            fontSize: 20,
                            color: Primary.mainColor,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_right_rounded,
                          color: Primary.mainColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
