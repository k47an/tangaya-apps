import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart'; // Pastikan path ini benar
import 'package:tangaya_apps/app/data/services/tour_service.dart';

mixin TourMixin on GetxController {
  final TourPackageService _tourPackageService = TourPackageService();
  final RxBool isTourLoading = false.obs;

  // Form and Input Controllers
  final GlobalKey<FormState> tourPackageFormKey = GlobalKey<FormState>();
  final TextEditingController tourPackageTitleController =
      TextEditingController();
  final TextEditingController tourPackageDescriptionController =
      TextEditingController();
  final TextEditingController tourPackagePriceController =
      TextEditingController();

  // Image Management
  final RxList<File?> selectedTourPackageImages = <File?>[].obs;
  final RxList<String> tourPackageImagesToDelete = <String>[].obs;
  final RxList<String> currentTourPackageImageUrls = <String>[].obs;

  // Data List
  final RxList<TourPackage> tourPackages = <TourPackage>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTourPackages();
    debugPrint('TourMixin initialized');
  }

  Future<void> fetchTourPackages() async {
    try {
      isTourLoading.value = true;
      final packages = await _tourPackageService.fetchTourPackages();
      tourPackages.assignAll(packages);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil paket wisata: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  bool validateTourPackageForm() {
    return tourPackageFormKey.currentState?.validate() ?? false;
  }

  Future<void> addTourPackage() async {
    if (!validateTourPackageForm()) {
      Get.snackbar('Invalid', 'Harap isi semua field dengan benar');
      return;
    }

    try {
      isTourLoading.value = true;
      await _tourPackageService.addTourPackage(
        title: tourPackageTitleController.text.trim(),
        description: tourPackageDescriptionController.text.trim(),
        price: double.parse(tourPackagePriceController.text.trim()),
        imageFiles: selectedTourPackageImages.toList(),
      );
      fetchTourPackages();
      clearTourPackageForm();
      Get.snackbar('Sukses', 'Paket wisata berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan paket wisata: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  Future<void> editTourPackage({required String docId}) async {
    if (!validateTourPackageForm()) {
      Get.snackbar('Invalid', 'Harap isi semua field dengan benar');
      return;
    }

    try {
      isTourLoading.value = true;
      await _tourPackageService.editTourPackage(
        docId: docId,
        newTitle: tourPackageTitleController.text.trim(),
        newDescription: tourPackageDescriptionController.text.trim(),
        newPrice: double.parse(tourPackagePriceController.text.trim()),
        oldImageUrls: currentTourPackageImageUrls.toList(),
        newImageFiles: selectedTourPackageImages.whereType<File>().toList(),
        imagesToDelete: tourPackageImagesToDelete.toList(),
      );
      fetchTourPackages();
      clearTourPackageForm();
      Get.snackbar('Sukses', 'Paket wisata berhasil diubah');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengedit paket wisata: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  Future<void> deleteTourPackage({
    required String docId,
    required List<String> imageUrls,
  }) async {
    try {
      isTourLoading.value = true;
      await _tourPackageService.deleteTourPackage(
        docId: docId,
        imageUrls: imageUrls,
      );
      fetchTourPackages();
      Get.snackbar('Sukses', 'Paket wisata berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus paket wisata: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  Future<TourPackage?> getPackageById(String id) async {
    return await _tourPackageService.getPackageById(id);
  }

  void fillTourPackageForm(TourPackage package) {
    tourPackageTitleController.text = package.title ?? '';
    tourPackageDescriptionController.text = package.description ?? '';
    tourPackagePriceController.text = package.price?.toString() ?? '';
    currentTourPackageImageUrls.assignAll(package.imageUrls ?? []);
    selectedTourPackageImages.clear();
    tourPackageImagesToDelete.clear();
  }

  void clearTourPackageForm() {
    tourPackageTitleController.clear();
    tourPackageDescriptionController.clear();
    tourPackagePriceController.clear();
    selectedTourPackageImages.clear();
    tourPackageImagesToDelete.clear();
    currentTourPackageImageUrls.clear();
  }

  // Method untuk menambahkan gambar yang dipilih
  void addSelectedImage(File? image) {
    if (image != null) {
      selectedTourPackageImages.add(image);
    }
  }

  // Method untuk menghapus gambar yang dipilih (sebelum upload)
  void removeSelectedImage(int index) {
    selectedTourPackageImages.removeAt(index);
  }

  // Method untuk menandai gambar untuk dihapus (gambar yang sudah ada di Firestore)
  void markImageToDelete(String imageUrl) {
    if (!tourPackageImagesToDelete.contains(imageUrl)) {
      tourPackageImagesToDelete.add(imageUrl);
    }
    // Juga hapus dari list URL saat ini agar tidak ditampilkan lagi di UI edit
    currentTourPackageImageUrls.remove(imageUrl);
  }

  // Method untuk membatalkan penghapusan gambar
  void unmarkImageToDelete(String imageUrl) {
    tourPackageImagesToDelete.remove(imageUrl);
    if (!currentTourPackageImageUrls.contains(imageUrl)) {
      currentTourPackageImageUrls.add(imageUrl);
    }
  }
}
