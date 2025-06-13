// lib/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ... (impor lainnya)
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/event_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/upsertEvent.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/upsertTour.dart';

class ManageTourEventController extends GetxController with TourMixin, EventMixin {
  
  // --- Navigasi untuk Tour ---
  void goToUpsertTourView({TourPackage? tourPackage}) {
    if (tourPackage == null) {
      prepareForAddTour();
    } else {
      prepareForEditTour(tourPackage);
    }
    Get.to(() => UpsertTourView(tourPackage: tourPackage));
  }

  // --- Navigasi untuk Event ---
  void goToUpsertEventView({Event? event}) {
    if (event == null) {
      prepareForAddEvent();
    } else {
      prepareForEditEvent(event);
    }
    Get.to(() => UpsertEventView(event: event));
  }

  // PERBAIKAN: Override method delete dari mixin untuk menambahkan dialog konfirmasi
  @override
  Future<void> deleteTourPackage({required TourPackage package}) async {
    _showDeleteConfirmationDialog(
      title: 'Hapus Paket Wisata?',
      content: 'Anda yakin ingin menghapus "${package.title}"?',
      onConfirm: () {
        // Panggil method delete asli dari mixin
        super.deleteTourPackage(package: package);
      },
    );
  }
  
  @override
  Future<void> deleteEvent(Event event) async {
    _showDeleteConfirmationDialog(
      title: 'Hapus Event?',
      content: 'Anda yakin ingin menghapus "${event.title}"?',
      onConfirm: () {
        super.deleteEvent(event);
      },
    );
  }

  // Method helper untuk menampilkan dialog konfirmasi
  void _showDeleteConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      middleText: content,
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // Tutup dialog
        onConfirm(); // Jalankan fungsi hapus
      },
      onCancel: () {}, // Cukup tutup dialog
    );
  }
}