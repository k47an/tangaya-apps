import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/editTourView_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class TourPackageCard extends StatelessWidget {
  final TourPackage tourPackage;
  final VoidCallback? onDelete;

  const TourPackageCard({super.key, required this.tourPackage, this.onDelete});

  @override
  Widget build(BuildContext context) {
    Get.find<ManageTourEventController>();

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: ScaleHelper.scaleHeightForDevice(8),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: ScaleHelper.scaleWidthForDevice(60),
            height: ScaleHelper.scaleHeightForDevice(60),
            child: Image.network(
              (tourPackage.imageUrls != null &&
                      tourPackage.imageUrls!.isNotEmpty)
                  ? tourPackage.imageUrls![0]
                  : '',

              fit: BoxFit.cover,
              loadingBuilder: (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 48),
            ),
          ),
        ),
        title: Text(
          tourPackage.title ?? '',
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(16),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tourPackage.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: regular.copyWith(color: Neutral.dark1),
            ),
            SizedBox(height: ScaleHelper.scaleHeightForDevice(4)),
            Text(
              'Rp ${tourPackage.price?.toStringAsFixed(0)}',
              style: semiBold.copyWith(color: Primary.subtleColor),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Get.to(
                () => EditTourView(
                  docId: '${tourPackage.id}',
                  initialTitle: '${tourPackage.title}',
                  initialDescription: '${tourPackage.description}',
                  initialPrice: tourPackage.price ?? 0.0,
                  initialImageUrls: tourPackage.imageUrls ?? [],
                ),
              );
            }
            if (value == 'delete' && onDelete != null) {
              onDelete!();
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(
                    'Edit',
                    style: regular.copyWith(color: Neutral.dark1),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(
                    'Hapus',
                    style: regular.copyWith(color: Colors.red),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
