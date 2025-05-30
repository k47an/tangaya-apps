import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/editEvent_widget.dart';
// Pastikan path ke EditEventView sudah benar
// atau jika editEvent_widget.dart adalah file yang benar
// import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/editEvent_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onDelete;

  const EventCard({super.key, required this.event, this.onDelete});

  String _formatPrice(double? price) {
    if (price == null || price == 0) {
      return 'Gratis';
    }
    // Format mata uang ke Rupiah tanpa desimal
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID', // Menggunakan locale Indonesia
      symbol: 'Rp ', // Simbol Rupiah
      decimalDigits: 0, // Tidak menampilkan angka desimal
    );
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: ScaleHelper.scaleHeightForDevice(8),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          // Tambahkan padding yang sesuai
          horizontal: ScaleHelper.scaleWidthForDevice(16),
          vertical: ScaleHelper.scaleHeightForDevice(10),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: ScaleHelper.scaleWidthForDevice(
              70,
            ), // Sedikit diperbesar untuk tampilan lebih baik
            height: ScaleHelper.scaleHeightForDevice(
              70,
            ), // Sesuaikan tinggi agar proporsional
            child: Image.network(
              event.imageUrl,
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
                    strokeWidth: 2.0, // Perkecil stroke
                  ),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    // Tampilan error yang lebih baik
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
          event.title,
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(16),
            color: Neutral.dark1, // Ganti warna agar lebih kontras jika perlu
          ),
          maxLines: 2, // Batasi judul agar tidak terlalu panjang
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          // Gunakan Column untuk menampilkan beberapa baris di subtitle
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: ScaleHelper.scaleHeightForDevice(4),
            ), // Jarak antara title dan subtitle pertama
            Text(
              // Gunakan locale 'id_ID' untuk format tanggal Indonesia
              '${event.location} • ${DateFormat('dd MMM yyyy', 'id_ID').format(event.eventDate)}',
              style: regular.copyWith(
                color: Neutral.dark1,
                fontSize: ScaleHelper.scaleTextForDevice(
                  12,
                ), // Sesuaikan ukuran font
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: ScaleHelper.scaleHeightForDevice(4),
            ), // Jarak antara subtitle pertama dan harga
            Text(
              _formatPrice(event.price), // Tampilkan harga yang sudah diformat
              style: semiBold.copyWith(
                // Harga dibuat sedikit menonjol
                color:
                    (event.price == null || event.price == 0)
                        ? Colors.green
                        : Primary.mainColor, // Warna berbeda untuk gratis
                fontSize: ScaleHelper.scaleTextForDevice(13),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Neutral.dark1,
          ), // Warna ikon agar lebih terlihat
          onSelected: (value) {
            if (value == 'edit') {
              // Pastikan Anda menggunakan view yang benar untuk edit
              Get.to(() => EditEventView(event: event));
            }
            if (value == 'delete' && onDelete != null) {
              // Tambahkan dialog konfirmasi sebelum menghapus
              Get.defaultDialog(
                title: "Konfirmasi Hapus",
                middleText:
                    "Apakah Anda yakin ingin menghapus event '${event.title}'?",
                textConfirm: "Hapus",
                textCancel: "Batal",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                cancelTextColor: Primary.mainColor,
                onConfirm: onDelete,
              );
            }
          },
          itemBuilder:
              (context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    // Gunakan Row untuk ikon dan teks
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
                    // Gunakan Row untuk ikon dan teks
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
        isThreeLine: true, // Izinkan subtitle untuk memiliki ruang lebih
      ),
    );
  }
}
