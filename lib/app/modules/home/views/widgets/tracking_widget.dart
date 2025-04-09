import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';

class TrackingWidget extends GetView<HomeController> {
  const TrackingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTracking.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.trackingList.isEmpty) {
        return const Center(child: Text("Tidak ada data tracking."));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
        itemCount: controller.trackingList.length,
        itemBuilder: (context, index) {
          final tracking = controller.trackingList[index];
          debugPrint("🔥 Image: ${tracking.images[0]}");
          debugPrint("🔥 Title: ${tracking.name}");

          return ArticleCard(image: tracking.images[0], title: tracking.name);
          // debug print image dan title
        },
      );
    });
  }
}

class ArticleCard extends StatelessWidget {
  final String image;
  final String title;

  const ArticleCard({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: ScaleHelper(context).scaleHeightForDevice(150),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            height: ScaleHelper(context).scaleHeightForDevice(150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                stops: const [0.1, 0.9],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              title,
              style: semiBold.copyWith(
                color: Neutral.white1,
                fontSize: ScaleHelper(context).scaleTextForDevice(14),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
