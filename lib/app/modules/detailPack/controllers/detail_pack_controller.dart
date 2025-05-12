import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/home/mixin/tourPackage_mixin.dart';

class DetailPackController extends GetxController with TourpackageMixin {
  final isLoading = false.obs;
  final isOrdering = false.obs;
  final data = {}.obs;
  late String id;
  final auth = Get.find<AuthController>();

  final RxInt peopleCount = 0.obs;
  final RxList<TextEditingController> peopleNames =
      <TextEditingController>[].obs;

  void setPeopleCount(int count) {
    peopleCount.value = count;
    while (peopleNames.length < count) {
      peopleNames.add(TextEditingController());
    }
    if (peopleNames.length > count) {
      peopleNames.removeRange(count, peopleNames.length);
    }
  }

  void resetOrderForm() {
    peopleCount.value = 0;
    for (var controller in peopleNames) {
      controller.dispose();
    }
    peopleNames.clear();
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      id = Get.arguments as String;
      fetchTourDetailById();
    } else {
      Get.snackbar("Error", "ID paket wisata tidak ditemukan.");
    }
  }

  Future<void> fetchTourDetailById() async {
    try {
      isLoading.value = true;
      final selected = await getPackageById(id);
      if (selected != null) {
        data.value = {
          'title': selected.title,
          'description': selected.description,
          'price': selected.price,
          'imageUrls': selected.imageUrls,
        };
      } else {
        Get.snackbar('Error', 'Paket wisata tidak ditemukan.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> packageOrder({
    required String customerName,
    required String phone,
    required String address,
    required int peopleCount,
    required DateTime? date,
    required List<String> peopleNames,
  }) async {
    if (customerName.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        date == null ||
        peopleNames.any((name) => name.isEmpty)) {
      Get.snackbar("Error", "Harap lengkapi semua field");
      return;
    }

    try {
      isOrdering.value = true;

      // ✅ Cek apakah ada order dengan status pending dari user ini
      final existingPending =
          await FirebaseFirestore.instance
              .collection("orders")
              .where("phone", isEqualTo: phone)
              .where("status", isEqualTo: "pending")
              .get();

      if (existingPending.docs.isNotEmpty) {
        Get.snackbar(
          "Pesanan Gagal",
          "Anda masih memiliki pesanan yang belum diproses.",
        );
        return;
      }

      // ✅ Tambahkan field status = pending
      await FirebaseFirestore.instance.collection("orders").add({
        "userId": auth.uid, // 👈 penting agar bisa difilter berdasarkan user
        "packageId": id,
        "packageTitle": data['title'],
        "name": customerName,
        "phone": phone,
        "address": address,
        "peopleCount": peopleCount,
        "peopleNames": peopleNames,
        "date": Timestamp.fromDate(date),
        "status": "pending",
      });

      resetOrderForm();
      Get.back();
      Get.snackbar("Sukses", "Pemesanan berhasil dikirim");
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan saat mengirim pemesanan");
    } finally {
      isOrdering.value = false;
    }
  }
}
