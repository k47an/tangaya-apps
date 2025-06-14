import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/data/services/booking_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

mixin OrderFormMixin on GetxController {
  AuthController get authController;
  BookingService get orderService;
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
  final isFetchingDates = false.obs;

  late final ScrollController scrollController;
  late final FocusNode nameNode;
  late final FocusNode phoneNode;
  late final FocusNode addressNode;
  late final FocusNode peopleCountNode;

  void initFormControllers() {
    if (authController.user != null) {
      nameC.text = authController.userName;
      phoneC.text = authController.userPhone;
      addressC.text = authController.userAddress;
    }
    scrollController = ScrollController();
    nameNode = FocusNode();
    phoneNode = FocusNode();
    addressNode = FocusNode();
    peopleCountNode = FocusNode();

    nameNode.addListener(() => _scrollToFocus(nameNode));
    phoneNode.addListener(() => _scrollToFocus(phoneNode));
    addressNode.addListener(() => _scrollToFocus(addressNode));
    peopleCountNode.addListener(() => _scrollToFocus(peopleCountNode));
  }

  void disposeFormControllers() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    peopleC.dispose();
    for (var c in peopleNames) {
      c.dispose();
    }
    scrollController.dispose();
    nameNode.dispose();
    phoneNode.dispose();
    addressNode.dispose();
    peopleCountNode.dispose();
  }

  void _scrollToFocus(FocusNode node) {
    try {
      if (node.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (node.context != null) {
            Scrollable.ensureVisible(
              node.context!,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: 1.0,
            );
          }
        });
      }
    } catch (e) {
      print("Error scrolling to focus: $e");
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
    isFetchingDates.value = true;
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("orders")
              .where("itemId", isEqualTo: itemId)
              .where("itemType", isEqualTo: "tour")
              .where(
                "status",
                whereIn: [
                  "panding_approval",
                  "awaiting_payment_choice",
                  "cod_selected",
                  "paid",
                ],
              )
              .get();

      final fetchedDates =
          snapshot.docs
              .map((d) => (d.data()['bookingDate'] as Timestamp?)?.toDate())
              .whereType<DateTime>()
              .toList();

      unavailableDates.assignAll(fetchedDates);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat tanggal tidak tersedia.');
      print("ERROR fetchUnavailableDates: $e");
    } finally {
      isFetchingDates.value = false;
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
      if (currentItem == null) throw Exception("Detail item tidak tersedia.");

      final newOrderId =
          FirebaseFirestore.instance.collection("orders").doc().id;
      final customerEmail =
          authController.userEmail.isNotEmpty
              ? authController.userEmail
              : "${phoneC.text.replaceAll(RegExp(r'[^0-9]'), '')}@placeholder.email";

      num itemUnitPrice =
          (itemType == 'tour' && currentItem is TourPackage)
              ? currentItem.price ?? 0
              : (itemType == 'event' && currentItem is Event)
              ? currentItem.price ?? 0
              : -1;

      if (itemUnitPrice < 0) throw Exception("Harga item tidak dikenal.");

      await orderService.saveOrderToFirestore(
        orderId: newOrderId,
        paymentStatus: "pending_approval",
        totalPrice: itemUnitPrice.toInt(),
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
    } catch (e) {
      Get.snackbar("Error Pesanan", "Terjadi kesalahan: $e");
    } finally {
      isOrdering.value = false;
    }
  }
}
