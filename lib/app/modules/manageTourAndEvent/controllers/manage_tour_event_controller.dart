import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/event_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/views/widgets/upsertEvent.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/views/widgets/upsertTour.dart';

class ManageTourEventController extends GetxController
    with TourMixin, EventMixin {
  void goToUpsertTourView({TourPackage? tourPackage}) {
    if (tourPackage == null) {
      prepareForAddTour();
    } else {
      prepareForEditTour(tourPackage);
    }
    Get.to(() => UpsertTourView(tourPackage: tourPackage));
  }

  void goToUpsertEventView({Event? event}) {
    if (event == null) {
      prepareForAddEvent();
    } else {
      prepareForEditEvent(event);
    }
    Get.to(() => UpsertEventView(event: event));
  }

  @override
  Future<void> deleteTourPackage({required TourPackage package}) async {
    _showDeleteConfirmationDialog(
      title: 'Hapus Paket Wisata?',
      content: 'Anda yakin ingin menghapus "${package.title}"?',
      onConfirm: () {
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
        Get.back();
        onConfirm();
      },
      onCancel: () {},
    );
  }
}
