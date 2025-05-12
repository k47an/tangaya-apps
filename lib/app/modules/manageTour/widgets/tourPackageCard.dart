// lib/app/modules/manageTour/widgets/tour_package_card.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/tourPackageModel.dart';
import 'package:tangaya_apps/app/modules/manageTour/bindings/manage_tour_binding.dart';
import 'package:tangaya_apps/app/modules/manageTour/widgets/editTourView_widget.dart';

class TourPackageCard extends StatelessWidget {
  final TourPackage tourPackage;
  final Future<void> Function(String, String, double, List<File?>?) onEdit;
  final VoidCallback onDelete;

  const TourPackageCard({
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
                  tourPackage.imageUrls.isNotEmpty
                      ? tourPackage.imageUrls.length
                      : 1,
              itemBuilder: (context, index) {
                final imageUrl =
                    tourPackage.imageUrls.isNotEmpty
                        ? tourPackage.imageUrls[index]
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
                        tourPackage.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tourPackage.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                        softWrap: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${tourPackage.price.toStringAsFixed(0)}',
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
                              docId: tourPackage.id,
                              initialTitle: tourPackage.title,
                              initialDescription: tourPackage.description,
                              initialPrice: tourPackage.price,
                              initialImageUrls: tourPackage.imageUrls,
                            ),
                            binding: ManageTourBinding(),
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
