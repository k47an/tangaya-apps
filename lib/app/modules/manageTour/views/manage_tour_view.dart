import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/manageTour/controllers/manage_tour_controller.dart';
import 'package:tangaya_apps/app/modules/manageTour/widgets/addTourPackage_widget.dart';
import 'package:tangaya_apps/app/modules/manageTour/widgets/editTourView_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ManageTourView extends GetView<ManageTourController> {
  const ManageTourView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
              },
            ),
          ],
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tourPackages.isEmpty) {
          return const Center(child: Text('No tour packages available.'));
        }

        return ListView.builder(
          itemCount: controller.tourPackages.length,
          itemBuilder: (context, index) {
            final tourPackage = controller.tourPackages[index];
            return ArticleCardAdmin(
              tourPackage: tourPackage, // Mengirimkan data tourPackage
              onEdit: (newTitle, newDescription, newPrice, newImages) async {
                await controller.editTourPackage(
                  tourPackage['id'],
                  newTitle,
                  newDescription,
                  newPrice,
                  List<String>.from(tourPackage['imageUrls']),
                  newImages!,
                );
              },
              onDelete: () async {
                await controller.deleteTourPackage(
                  tourPackage['id'],
                  List<String>.from(tourPackage['imageUrls']),
                );
              },
            );
          },
        );
      }),
    );
  }
}

class ArticleCardAdmin extends StatelessWidget {
  final Map<String, dynamic> tourPackage; // Menerima seluruh objek tourPackage
  final Future<void> Function(String, String, double, List<File?>?) onEdit;
  final VoidCallback onDelete;

  const ArticleCardAdmin({
    super.key,
    required this.tourPackage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              itemCount:
                  tourPackage['imageUrls'].isNotEmpty
                      ? tourPackage['imageUrls'].length
                      : 1,
              itemBuilder: (context, index) {
                final imageUrl =
                    tourPackage['imageUrls'].isNotEmpty
                        ? tourPackage['imageUrls'][index]
                        : 'https://via.placeholder.com/600x300.png?text=No+Image';
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tourPackage['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tourPackage['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                        softWrap: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${tourPackage['price'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => Get.to(
                            () => EditTourView(
                              docId:
                                  tourPackage['id'], // Sekarang menggunakan tourPackage['id']
                              initialTitle: tourPackage['title'],
                              initialDescription: tourPackage['description'],
                              initialPrice: tourPackage['price'],
                              initialImageUrls: List<String>.from(
                                tourPackage['imageUrls'],
                              ),
                            ),
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
