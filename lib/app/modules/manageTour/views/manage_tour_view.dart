import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/manageTour/controllers/manage_tour_controller.dart';
import 'package:tangaya_apps/app/modules/manageTour/widgets/addTourPackage_widget.dart';
import 'package:tangaya_apps/app/modules/manageTour/widgets/tourPackageCard.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ManageTourView extends GetView<ManageTourController> {
  const ManageTourView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tourPackages.isEmpty) {
          return const Center(child: Text('No tour packages available.'));
        }

        return _buildTourPackagesList();
      }),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Get.back(),
      ),
      iconTheme: const IconThemeData(color: Neutral.white1),
      centerTitle: true,
      backgroundColor: Primary.mainColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Management Tours and Events",
            style: semiBold.copyWith(
              fontSize: ScaleHelper(context).scaleTextForDevice(20),
              color: Neutral.white1,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Neutral.white1),
            onPressed: () => _showAddPackageBottomSheet(context),
          ),
        ],
      ),
    );
  }

  void _showAddPackageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.tour),
                  title: const Text('Tambah Paket Wisata'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(AddTourPackageView());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Tambah Event'),
                  onTap: () {
                    Navigator.pop(context);
                    // Get.to(AddEventView());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTourPackagesList() {
    return ListView.builder(
      itemCount: controller.tourPackages.length,
      itemBuilder: (context, index) {
        final tourPackage = controller.tourPackages[index];
        return TourPackageCard(
          tourPackage: tourPackage,
          onEdit: (newTitle, newDescription, newPrice, newImages) async {
            await controller.editTourPackage(
              docId: '',
              newTitle: '',
              newDescription: '',
              newPrice: 0,
              oldImageUrls: [],
              newImageFiles: [],
              imagesToDelete: [], initialTitle: '',
            );
          },
          onDelete: () async {
            await controller.deleteTourPackage(docId: '', imageUrls: []);
          },
        );
      },
    );
  }
}
