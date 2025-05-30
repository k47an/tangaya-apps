import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Pastikan intl diimpor jika Anda membutuhkannya untuk format lain di sini,
// meskipun contoh ini tidak menggunakannya secara langsung untuk TourPackageCard.
// import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/editTourView_widget.dart';
import 'package:tangaya_apps/constant/constant.dart'; // Asumsi konstanta Anda di sini

class TourPackageCard extends StatelessWidget {
  final TourPackage tourPackage;
  final VoidCallback?
  onDelete; // Callback yang akan dipanggil saat tombol hapus di dialog dikonfirmasi

  const TourPackageCard({super.key, required this.tourPackage, this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Get.find<ManageTourEventController>(); // Pemanggilan ini tidak perlu di build method jika tidak digunakan langsung untuk membangun UI.
    // Controller biasanya diakses melalui GetView atau parameter.

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: ScaleHelper.scaleHeightForDevice(8),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          // Menambahkan content padding agar konsisten
          horizontal: ScaleHelper.scaleWidthForDevice(16),
          vertical: ScaleHelper.scaleHeightForDevice(10),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: ScaleHelper.scaleWidthForDevice(
              70,
            ), // Menyamakan ukuran dengan EventCard
            height: ScaleHelper.scaleHeightForDevice(70),
            child: Image.network(
              (tourPackage.imageUrls != null &&
                      tourPackage.imageUrls!.isNotEmpty)
                  ? tourPackage
                      .imageUrls![0] // Tampilkan gambar pertama jika ada
                  : 'https://via.placeholder.com/150/CCCCCC/FFFFFF?Text=No+Image', // URL Placeholder jika tidak ada gambar
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    // Error builder yang lebih baik
                    width: ScaleHelper.scaleWidthForDevice(70),
                    height: ScaleHelper.scaleHeightForDevice(70),
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.broken_image,
                      size: ScaleHelper.scaleTextForDevice(30),
                      color: Colors.grey[600],
                    ),
                  ),
            ),
          ),
        ),
        title: Text(
          tourPackage.title ?? 'Tanpa Judul',
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(16),
            color: Neutral.dark1, // Menyamakan style dengan EventCard
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
              maxLines: 1, // Atau 2 jika ingin lebih banyak deskripsi terlihat
              overflow: TextOverflow.ellipsis,
              style: regular.copyWith(
                color: Neutral.dark1,
                fontSize: ScaleHelper.scaleTextForDevice(12),
              ),
            ),
            SizedBox(height: ScaleHelper.scaleHeightForDevice(4)),
            Text(
              // Format harga menggunakan NumberFormat jika belum
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(tourPackage.price ?? 0),
              style: semiBold.copyWith(
                color:
                    Primary
                        .mainColor, // Menyamakan warna harga dengan EventCard
                fontSize: ScaleHelper.scaleTextForDevice(13),
              ),
            ),
          ],
        ),
        isThreeLine: true, // Agar subtitle punya cukup ruang
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Neutral.dark1,
          ), // Menyamakan ikon dengan EventCard
          onSelected: (value) {
            if (value == 'edit') {
              Get.to(
                () => EditTourView(
                  // Pastikan EditTourView sudah ada dan diimpor
                  // docId: tourPackage.id, // Jika id adalah String
                  docId: tourPackage.id ?? '', // Handle jika id bisa null
                  initialTitle: tourPackage.title ?? '',
                  initialDescription: tourPackage.description ?? '',
                  initialPrice: tourPackage.price ?? 0.0,
                  initialImageUrls: tourPackage.imageUrls ?? [],
                ),
              );
            }
            // --- MODIFIKASI UNTUK KONFIRMASI HAPUS ---
            if (value == 'delete' && onDelete != null) {
              Get.defaultDialog(
                title: "Konfirmasi Hapus",
                middleText:
                    "Apakah Anda yakin ingin menghapus paket wisata '${tourPackage.title ?? ''}'?",
                textConfirm: "Hapus",
                textCancel: "Batal",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red, // Warna tombol konfirmasi
                cancelTextColor:
                    Primary
                        .mainColor, // Warna tombol batal, sesuaikan dengan konstanta Anda
                onConfirm:
                    onDelete, // 👈 onDelete yang diterima dari luar akan dipanggil
              );
            }
            // --- AKHIR MODIFIKASI ---
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  // Menyamakan style item menu
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Neutral.dark1,
                        size: ScaleHelper.scaleTextForDevice(20),
                      ),
                      SizedBox(width: ScaleHelper.scaleWidthForDevice(8)),
                      Text(
                        'Edit',
                        style: regular.copyWith(
                          color: Neutral.dark1,
                          fontSize: ScaleHelper.scaleTextForDevice(14),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: ScaleHelper.scaleTextForDevice(20),
                      ),
                      SizedBox(width: ScaleHelper.scaleWidthForDevice(8)),
                      Text(
                        'Hapus',
                        style: regular.copyWith(
                          color: Colors.red,
                          fontSize: ScaleHelper.scaleTextForDevice(14),
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
