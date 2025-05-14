import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/home/mixin/tourPackage_mixin.dart';

class DetailPackController extends GetxController with TourpackageMixin {
  final isLoading = false.obs;
  final isOrdering = false.obs;

  final package = <String, dynamic>{}.obs;
  final unavailableDates = <DateTime>[].obs;

  late final String id;
  final auth = Get.find<AuthController>();

  // Form Field Controllers
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final peopleC = TextEditingController();
  final dateC = TextEditingController();
  DateTime? selectedDate;

  final peopleCount = 0.obs;
  final peopleNames = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments;
    fetchTourDetailById();
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

  Future<void> fetchTourDetailById() async {
    try {
      isLoading.value = true;
      final result = await getPackageById(id);
      if (result != null) {
        package.value = {
          'title': result.title,
          'description': result.description,
          'price': result.price,
          'imageUrls': result.imageUrls,
        };
      } else {
        Get.snackbar('Error', 'Paket tidak ditemukan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnavailableDates() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("orders")
              .where("packageId", isEqualTo: id)
              .where("status", isEqualTo: "approved")
              .get();

      unavailableDates.assignAll(
        snapshot.docs.map((d) => (d['date'] as Timestamp).toDate()),
      );
    } catch (e) {
      print("Gagal mengambil tanggal: $e");
    }
  }

  void resetForm() {
    nameC.clear();
    phoneC.clear();
    addressC.clear();
    peopleC.clear();
    dateC.clear();
    selectedDate = null;
    setPeopleCount(0);
  }

  Future<void> submitOrder() async {
    if (nameC.text.isEmpty ||
        phoneC.text.isEmpty ||
        addressC.text.isEmpty ||
        selectedDate == null ||
        peopleNames.any((c) => c.text.isEmpty)) {
      Get.snackbar("Error", "Harap isi semua field.");
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
        "userId": auth.uid,
        "packageId": id,
        "packageTitle": package['title'],
        "name": nameC.text,
        "phone": phoneC.text,
        "address": addressC.text,
        "peopleCount": peopleCount.value,
        "peopleNames": peopleNames.map((c) => c.text).toList(),
        "date": Timestamp.fromDate(selectedDate!),
        "status": "pending",
      });

      resetForm();
      Get.back();
      Get.snackbar("Sukses", "Pemesanan berhasil dikirim.");
    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim pesanan.");
    } finally {
      isOrdering.value = false;
    }
  }
}
