// detail_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';

class DetailController extends GetxController with TourMixin {
  final isLoading = false.obs;
  final isOrdering = false.obs;

  final Rx<dynamic> detailItem = Rx<dynamic>(
    null,
  ); // Bisa TourPackage atau Event
  final String itemType =
      Get.arguments['type']; // Terima tipe dari halaman sebelumnya
  final String itemId =
      Get.arguments['id']; // Terima ID dari halaman sebelumnya
  final unavailableDates = <DateTime>[].obs;

  final authController = Get.find<AuthController>();

  // Form Field Controllers
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final peopleC = TextEditingController();
  final dateC = TextEditingController();
  final selectedDate = Rx<DateTime?>(null); // Jadikan selectedDate sebagai Rx
  final selectedDateFormatted =
      ''.obs; // Tambahkan variabel RxString untuk tanggal yang diformat

  final peopleCount = 0.obs; // Inisialisasi dengan 1
  final peopleNames = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("Detail Type: $itemType, ID: $itemId");
    fetchDetail();
    fetchUnavailableDates();
    if (authController.user != null) {
      nameC.text = authController.userName;
      phoneC.text = authController.userPhone;
      addressC.text = authController.userAddress;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    peopleC.dispose();
    dateC.dispose();
    for (var c in peopleNames) {
      c.dispose();
    }
    super.onClose();
  }

  void setPeopleCount(int count) {
    peopleCount.value = count;
    while (peopleNames.length < count) {
      peopleNames.add(TextEditingController());
    }
    if (peopleNames.length > count) {
      final toRemove = peopleNames.sublist(count);
      for (var c in toRemove) {
        c.dispose();
      }
      peopleNames.removeRange(count, peopleNames.length);
    }
  }

  Future<void> fetchDetail() async {
    try {
      isLoading.value = true;
      if (itemType == 'tour') {
        final TourPackage? result = await getPackageById(itemId);
        print("Fetched Tour: ${result?.toJson()}");
        detailItem.value = result;
        if (result == null) {
          Get.snackbar('Error', 'Paket tidak ditemukan');
        }
      } else if (itemType == 'event') {
        final Event? result = await getEventById(itemId);
        print("Fetched Event: ${result?.toJson()}");
        detailItem.value = result;
        if (result == null) {
          Get.snackbar('Error', 'Event tidak ditemukan');
        }
      } else {
        Get.snackbar('Error', 'Tipe item tidak valid');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('events').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Event.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching event by ID: $e");
      return null;
    }
  }

  Future<void> fetchUnavailableDates() async {
    if (itemType == 'tour') {
      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection("orders")
                .where("packageId", isEqualTo: itemId)
                .where("status", isEqualTo: "approved")
                .get();

        unavailableDates.assignAll(
          snapshot.docs.map((d) => (d['date'] as Timestamp).toDate()),
        );
      } catch (e) {
        print("Gagal mengambil tanggal tidak tersedia untuk tour: $e");
        Get.snackbar('Error', 'Gagal memuat tanggal tidak tersedia');
      }
    } else if (itemType == 'event') {
      unavailableDates
          .clear(); // Sementara, tidak ada tanggal tidak tersedia untuk event
    }
  }

  void resetForm() {
    peopleC.clear();
    dateC.clear();
    selectedDate.value = null;
    selectedDateFormatted.value = '';
    setPeopleCount(0); // Reset ke 1
    peopleNames.clear();
  }

  Future<void> submitOrder() async {
    if (nameC.text.isEmpty || phoneC.text.isEmpty || addressC.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Harap isi Nama Lengkap, Nomor Telepon, dan Alamat.",
      );
      return;
    }

    final peopleCountValue = int.tryParse(peopleC.text) ?? 0; // Default ke 1

    if (itemType == 'tour' &&
        (selectedDate.value == null ||
            (peopleCountValue > 0 && peopleNames.any((c) => c.text.isEmpty)))) {
      Get.snackbar("Error", "Harap pilih tanggal dan isi nama semua peserta.");
      return;
    }

    try {
      isOrdering.value = true;

      final pending =
          await FirebaseFirestore.instance
              .collection("orders")
              .where("phone", isEqualTo: phoneC.text)
              .where("status", isEqualTo: "pending")
              .get();

      if (pending.docs.isNotEmpty) {
        Get.snackbar("Gagal", "Anda memiliki pesanan yang belum diproses.");
        return;
      }

      await FirebaseFirestore.instance.collection("orders").add({
        "userId": authController.uid,
        "packageId": itemType == 'tour' ? itemId : null,
        "eventId": itemType == 'event' ? itemId : null,
        "itemType": itemType,
        "packageTitle": itemType == 'tour' ? detailItem.value?.title : null,
        "eventTitle": itemType == 'event' ? detailItem.value?.title : null,
        "name": nameC.text,
        "phone": phoneC.text,
        "address": addressC.text,
        "peopleCount": peopleCountValue,
        "peopleNames":
            itemType == 'tour' && peopleCountValue > 1
                ? peopleNames.map((c) => c.text).toList()
                : [],
        "date":
            itemType == 'tour' && selectedDate.value != null
                ? Timestamp.fromDate(selectedDate.value!)
                : itemType == 'event' && detailItem.value?.eventDate != null
                ? Timestamp.fromDate(detailItem.value!.eventDate)
                : null,
        "status": "pending",
      });

      resetForm();
      Get.back();
      Get.snackbar("Sukses", "Pemesanan berhasil dikirim.");
    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim pesanan: $e");
    } finally {
      isOrdering.value = false;
    }
  }

  @override
  Future<TourPackage?> getPackageById(String id) async {
    return await super.getPackageById(id);
  }
}
