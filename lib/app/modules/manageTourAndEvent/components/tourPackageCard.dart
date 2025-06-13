import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/constant/constant.dart';

class TourPackageCard extends StatelessWidget {
  final TourPackage tourPackage;
  final VoidCallback onEdit; // PERBAIKAN: Callback untuk Edit
  final VoidCallback onDelete; // PERBAIKAN: Callback untuk Delete

  const TourPackageCard({
    super.key,
    required this.tourPackage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: ScaleHelper.scaleHeightForDevice(8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScaleHelper.scaleWidthForDevice(16),
          vertical: ScaleHelper.scaleHeightForDevice(10),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: ScaleHelper.scaleWidthForDevice(70),
            height: ScaleHelper.scaleHeightForDevice(70),
            child: Image.network(
              (tourPackage.imageUrls?.isNotEmpty ?? false)
                  ? tourPackage.imageUrls!.first
                  : 'https://via.placeholder.com/150', // URL Placeholder
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, size: ScaleHelper.scaleTextForDevice(30), color: Colors.grey[600]),
              ),
            ),
          ),
        ),
        title: Text(
          tourPackage.title ?? 'Tanpa Judul',
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(16),
            color: Neutral.dark1,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: ScaleHelper.scaleHeightForDevice(4)),
            Text(
              tourPackage.description ?? 'Tidak ada deskripsi.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: regular.copyWith(
                color: Neutral.dark1,
                fontSize: ScaleHelper.scaleTextForDevice(12),
              ),
            ),
            SizedBox(height: ScaleHelper.scaleHeightForDevice(4)),
            Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(tourPackage.price ?? 0),
              style: semiBold.copyWith(
                color: Primary.mainColor,
                fontSize: ScaleHelper.scaleTextForDevice(13),
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Neutral.dark1),
          // PERBAIKAN: Logika disederhanakan, hanya memanggil callback
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: const Row(children: [Icon(Icons.edit_outlined), SizedBox(width: 8), Text('Edit')]),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: const Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))]),
            ),
          ],
        ),
      ),
    );
  }
}