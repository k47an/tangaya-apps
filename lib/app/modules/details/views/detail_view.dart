import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/details/controllers/detail_controller.dart';
import 'package:tangaya_apps/app/modules/details/views/widgets/bookingBar_widget.dart';
import 'package:tangaya_apps/app/modules/details/views/widgets/bookingForm_widget.dart';
import 'package:tangaya_apps/app/modules/details/views/widgets/detailContent_widget.dart';
import 'package:tangaya_apps/app/modules/details/views/widgets/heroImage_widget.dart';
import 'package:tangaya_apps/app/modules/details/views/widgets/imageThumnail_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Primary.mainColor),
            );
          }
          if (controller.detailItem.value == null) {
            return const Center(child: Text("Detail item tidak ditemukan."));
          }
          return _buildMainContent(context);
        }),
        bottomNavigationBar: Obx(() {
          if (controller.detailItem.value != null) {
            return BookingBarWidget(
              item: controller.detailItem.value,
              onBookingPressed: () async {
                controller.resetForm();
                if (controller.itemType == 'tour') {
                  await controller.fetchUnavailableDates();
                }
                showOrderBottomSheet(context);
              },
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final item = controller.detailItem.value;
    List<String> imageUrls = [];

    if (item is TourPackage) {
      imageUrls = item.imageUrls ?? [];
    } else if (item is Event) {
      imageUrls = item.imageUrl.isNotEmpty ? [item.imageUrl] : [];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () =>
                HeroImageWidget(imageUrl: controller.activeHeroImageUrl.value),
          ),
          ImageThumbnailsWidget(imageUrls: imageUrls),
          DetailContentWidget(item: item),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void showOrderBottomSheet(BuildContext context) {
    Get.bottomSheet(
      const BookingFormWidget(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}
