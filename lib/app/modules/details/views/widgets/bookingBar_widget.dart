import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';

class BookingBarWidget extends StatelessWidget {
  final dynamic item;
  final VoidCallback onBookingPressed;

  const BookingBarWidget({
    super.key,
    required this.item,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final num price = (item is TourPackage) ? (item.price ?? 0) : ((item is Event) ? (item.price ?? 0) : 0);
    final String itemType = (item is TourPackage) ? 'tour' : 'event';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemType == 'tour' ? "Harga Wisata" : "Harga Event",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                price > 0 ? "Rp ${NumberFormat('#,###', 'id_ID').format(price)}" : "Gratis",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Primary.mainColor),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Primary.mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (authController.userRole.value == 'tamu') {
                Get.snackbar(
                  'Akses Ditolak',
                  'Anda harus login untuk dapat melakukan pemesanan.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                Get.toNamed(Routes.SIGNIN); 
              } else {
                onBookingPressed(); 
              }
            },
            child: Text(itemType == 'tour' ? "Pesan Wisata" : "Daftar Event"),
          ),
        ],
      ),
    );
  }
}