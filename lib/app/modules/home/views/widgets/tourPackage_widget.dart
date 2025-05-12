import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final controller = Get.put(
      HomeController(),
      tag: 'carousel_$id',
      permanent: false,
    );

    final isSingleImage = imageUrls.length == 1;

    final textPainter = TextPainter(
      text: TextSpan(
        text: description,
        style: regular.copyWith(fontSize: 14, color: Neutral.dark3),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32);

    final hasMoreThanTwoLines = textPainter.didExceedMaxLines;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Neutral.white2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(imageUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 200,
              viewportFraction: 1.0,
              enlargeCenterPage: !isSingleImage,
              enableInfiniteScroll: !isSingleImage,
              autoPlay: !isSingleImage,
              scrollPhysics:
                  isSingleImage ? const NeverScrollableScrollPhysics() : null,
              onPageChanged: (index, reason) {
                controller.changeIndex(index);
              },
            ),
          ),
          const SizedBox(height: 8),
          if (!isSingleImage)
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    imageUrls.asMap().entries.map((entry) {
                      return Container(
                        width: 5.0,
                        height: 5.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              controller.current.value == entry.key
                                  ? Primary.mainColor
                                  : Neutral.dark1.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
              );
            }),
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
              const SizedBox(height: 8),
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      firstChild: Text(
                        description,
                        style: regular.copyWith(
                          fontSize: 14,
                          color: Neutral.dark3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        description,
                        style: regular.copyWith(
                          fontSize: 14,
                          color: Neutral.dark3,
                        ),
                      ),
                      crossFadeState:
                          controller.isExpanded.value
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    if (hasMoreThanTwoLines) // Only show the button if there are more than 2 lines
                      GestureDetector(
                        onTap: () => controller.isExpanded.toggle(),
                        child: Text(
                          controller.isExpanded.value
                              ? "Lebih sedikit"
                              : "Selengkapnya",
                          style: medium.copyWith(
                            fontSize: 14,
                            color: Primary.mainColor,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
