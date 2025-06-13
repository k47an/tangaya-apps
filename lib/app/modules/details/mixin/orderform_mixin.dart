import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/data/services/order_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

mixin OrderFormMixin on GetxController {
  AuthController get authController;
  OrderService get orderService;
  Rx<dynamic> get detailItem;
  String get itemType;
  String get itemId;

  final isOrdering = false.obs;
  final unavailableDates = <DateTime>[].obs;

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final peopleC = TextEditingController();
  final selectedDate = Rx<DateTime?>(null);
  final selectedDateFormatted = ''.obs;
  final peopleCount = 0.obs;
  final peopleNames = <TextEditingController>[].obs;

  void initFormControllers() {
    if (authController.user != null) {
      nameC.text = authController.userName;
      phoneC.text = authController.userPhone;
      addressC.text = authController.userAddress;
    }
  }

  void disposeFormControllers() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    peopleC.dispose();
    for (var c in peopleNames) {
      c.dispose();
    }
  }

  void setPeopleCount(int count) {
    final newCount = count < 0 ? 0 : count;
    peopleCount.value = newCount;
    while (peopleNames.length < newCount) {
      peopleNames.add(TextEditingController());
    }
    if (peopleNames.length > newCount) {
      final toRemove = peopleNames.sublist(newCount);
      for (var c in toRemove) {
        c.dispose();
      }
      peopleNames.removeRange(newCount, peopleNames.length);
    }
  }

  void resetForm() {
    peopleC.clear();
    selectedDate.value = null;
    selectedDateFormatted.value = '';
    setPeopleCount(0);
  }

  Future<void> fetchUnavailableDates() async {
    if (itemType != 'tour') {
      unavailableDates.clear();
      return;
    }
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("orders")
              .where("itemId", isEqualTo: itemId)
              .where("itemType", isEqualTo: "tour")
              .where(
                "status",
                whereIn: [
                  "settlement",
                  "approved",
                  "cod_confirmed_awaiting_delivery",
                  "approved_pending_payment",
                  "approved_awaiting_payment_choice",
                  "payment_initiated_post_approval",
                ],
              )
              .get();

      unavailableDates.assignAll(
        snapshot.docs
            .map((d) => (d.data()['bookingDate'] as Timestamp?)?.toDate())
            .whereType<DateTime>()
            .toList(),
      );
      print("Unavailable dates for tour $itemId: $unavailableDates");
    } catch (e) {
      print("Failed to fetch unavailable dates for tour: $e");
      Get.snackbar('Error', 'Gagal memuat tanggal tidak tersedia.');
    }
  }

  Future<void> submitOrder() async {
    if (nameC.text.isEmpty || phoneC.text.isEmpty || addressC.text.isEmpty) {
      Get.snackbar("Validasi Gagal", "Nama, telepon, dan alamat wajib diisi.");
      return;
    }
    final int currentPeopleCountInput =
        int.tryParse(peopleC.text.isEmpty ? "0" : peopleC.text) ?? 0;
    if (peopleC.text.isNotEmpty && currentPeopleCountInput <= 0) {
      Get.snackbar("Validasi Gagal", "Jumlah orang tidak valid.");
      return;
    }
    if (currentPeopleCountInput > 0 && peopleNames.any((c) => c.text.isEmpty)) {
      Get.snackbar("Validasi Gagal", "Harap isi nama semua peserta.");
      return;
    }
    if (itemType == 'tour' && selectedDate.value == null) {
      Get.snackbar("Validasi Gagal", "Harap pilih tanggal untuk paket wisata.");
      return;
    }

    isOrdering.value = true;

    try {
      final currentItem = detailItem.value;
      if (currentItem == null) {
        throw Exception("Detail item tidak tersedia. Coba lagi.");
      }

      final newOrderId =
          FirebaseFirestore.instance.collection("orders").doc().id;
      final customerEmail =
          authController.userEmail.isNotEmpty
              ? authController.userEmail
              : "Tidak ada email yang tersedia";

      num itemUnitPrice =
          (itemType == 'tour' && currentItem is TourPackage)
              ? currentItem.price ?? 0
              : (itemType == 'event' && currentItem is Event)
              ? currentItem.price ?? 0
              : -1;

      if (itemUnitPrice < 0) {
        throw Exception("Tipe atau harga item tidak dikenal untuk pemesanan.");
      }
      int totalPrice = itemUnitPrice.toInt();

      await orderService.saveOrderToFirestore(
        orderId: newOrderId,
        paymentStatus: "pending_approval",
        totalPrice: totalPrice,
        customerName: nameC.text,
        customerEmail: customerEmail,
        customerPhone: phoneC.text,
        customerAddress: addressC.text,
        peopleCountText: peopleC.text,
        detailItemValue: currentItem,
        itemType: itemType,
        itemId: itemId,
        selectedDateValue: itemType == 'tour' ? selectedDate.value : null,
        peopleNamesValues: peopleNames.map((c) => c.text).toList(),
        isUpdate: false,
      );

      Get.back();
      Get.snackbar(
        "Sukses",
        "Pemesanan berhasil dikirim dan menunggu persetujuan admin.",
      );
      resetForm();
    } catch (e, stackTrace) {
      Get.snackbar("Error Pesanan", "Terjadi kesalahan: $e");
      print("ERROR submitOrder: $e");
      print("STACKTRACE submitOrder: $stackTrace");
    } finally {
      isOrdering.value = false;
    }
  }
}
