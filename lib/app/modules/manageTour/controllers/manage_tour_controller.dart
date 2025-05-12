import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/tourPackageModel.dart';
import 'package:tangaya_apps/app/data/services/tourPackageService.dart';

class ManageTourController extends GetxController {
  final TourPackageService _tourPackageService = TourPackageService();
  final RxList<TourPackage> tourPackages = <TourPackage>[].obs;
  final RxBool isLoading = false.obs;

  // Form-related variables
  final formKey = GlobalKey<FormState>(); // Form key for validation
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  RxList<File?> selectedImages = <File?>[].obs; // bisa File atau String (URL)
  final RxList<String> imagesToDelete = <String>[].obs;

  // Reactive variables for form fields
  var title = ''.obs;
  var description = ''.obs;
  var price = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTourPackages();
  }

  // Mengambil daftar paket wisata
  Future<void> fetchTourPackages() async {
    try {
      isLoading.value = true;
      final packages = await _tourPackageService.fetchTourPackages();
      tourPackages.assignAll(packages);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil paket wisata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Menambahkan paket wisata
  Future<void> addTourPackage({
    required String title,
    required String description,
    required double price,
    required List<File?> imageFiles,
  }) async {
    try {
      isLoading.value = true;
      await _tourPackageService.addTourPackage(
        title: title,
        description: description,
        price: price,
        imageFiles: imageFiles,
      );
      fetchTourPackages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan paket wisata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mengedit paket wisata
  Future<void> editTourPackage({
    required String docId,
    required String newTitle,
    required String newDescription,
    required double newPrice,
    required List<String> oldImageUrls,
    required List<File?> newImageFiles,
    required List<String> imagesToDelete, required String initialTitle,
  }) async {
    try {
      isLoading.value = true;
      await _tourPackageService.editTourPackage(
        docId: docId,
        newTitle: newTitle,
        newDescription: newDescription,
        newPrice: newPrice,
        oldImageUrls: oldImageUrls,
        newImageFiles: newImageFiles,
        imagesToDelete: imagesToDelete,
      );
      fetchTourPackages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengedit paket wisata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Menghapus paket wisata
  Future<void> deleteTourPackage({
    required String docId,
    required List<String> imageUrls,
  }) async {
    try {
      isLoading.value = true;
      await _tourPackageService.deleteTourPackage(
        docId: docId,
        imageUrls: imageUrls,
      );
      fetchTourPackages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus paket wisata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // // Inisialisasi form edit
  // void initializeEditForm({
  //   required String title,
  //   required String description,
  //   required double price,
  //   required List<String> imageUrls,
  // }) {
  //   this.title.value = title;
  //   this.descriptionController.text = description;
  //   this.price.value = price;
  //   selectedImages.assignAll([]); // reset
  //   imagesToDelete.clear();
  // }
}
