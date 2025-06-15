import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/data/services/tourPackage_service.dart';
import 'package:tangaya_apps/utils/global_components/snackbar.dart';

mixin TourMixin on GetxController {
  final TourPackageService _tourPackageService = Get.find<TourPackageService>();
  final RxBool isTourLoading = false.obs;
  final GlobalKey<FormState> tourPackageFormKey = GlobalKey<FormState>();
  final TextEditingController tourPackageTitleController =
      TextEditingController();
  final TextEditingController tourPackageDescriptionController =
      TextEditingController();
  final TextEditingController tourPackagePriceController =
      TextEditingController();
  final RxList<File> selectedTourPackageImages = <File>[].obs;
  final RxList<String> currentTourPackageImageUrls = <String>[].obs;
  final RxList<String> tourPackageImagesToDelete = <String>[].obs;

  final RxList<TourPackage> tourPackages = <TourPackage>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTourPackages();
  }

  @override
  void onClose() {
    tourPackageTitleController.dispose();
    tourPackageDescriptionController.dispose();
    tourPackagePriceController.dispose();
    super.onClose();
  }

  Future<void> fetchTourPackages() async {
    try {
      isTourLoading.value = true;
      final packages = await _tourPackageService.fetchTourPackages();
      tourPackages.assignAll(packages);
    } catch (e) {
      debugPrint('Error fetching tour packages: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  bool _validateTourPackageForm() {
    if (!(tourPackageFormKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (currentTourPackageImageUrls.isEmpty &&
        selectedTourPackageImages.isEmpty) {
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Pilih minimal satu gambar untuk paket wisata.',
        type: SnackBarType.warning,
      );
      return false;
    }

    return true;
  }

  Future<void> addTourPackage() async {
    if (!_validateTourPackageForm()) return;

    try {
      isTourLoading.value = true;
      final String cleanPrice = tourPackagePriceController.text
          .trim()
          .replaceAll('.', '');

      await _tourPackageService.addTourPackage(
        title: tourPackageTitleController.text.trim(),
        description: tourPackageDescriptionController.text.trim(),
        price: double.parse(cleanPrice),
        imageFiles: selectedTourPackageImages.toList(),
      );

      await fetchTourPackages();
      Get.back();
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Paket wisata berhasil ditambahkan',
        type: SnackBarType.success,
      );
    } catch (e) {
      debugPrint('Error adding tour package: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  Future<void> editTourPackage({required String docId}) async {
    if (!_validateTourPackageForm()) return;

    try {
      isTourLoading.value = true;
      final String cleanPrice = tourPackagePriceController.text
          .trim()
          .replaceAll('.', '');

      await _tourPackageService.editTourPackage(
        docId: docId,
        newTitle: tourPackageTitleController.text.trim(),
        newDescription: tourPackageDescriptionController.text.trim(),
        newPrice: double.parse(cleanPrice),
        oldImageUrls: currentTourPackageImageUrls.toList(),
        newImageFiles: selectedTourPackageImages.toList(),
        imagesToDelete: tourPackageImagesToDelete.toList(),
      );

      await fetchTourPackages();
      Get.back();
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Paket wisata berhasil diedit',
        type: SnackBarType.success,
      );
    } catch (e) {
      debugPrint('Error editing tour package: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  Future<void> deleteTourPackage({required TourPackage package}) async {
    try {
      isTourLoading.value = true;
      await _tourPackageService.deleteTourPackage(
        docId: package.id!,
        imageUrls: package.imageUrls ?? [],
      );
      tourPackages.removeWhere((p) => p.id == package.id);
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Paket wisata berhasil dihapus',
        type: SnackBarType.success,
      );
    } catch (e) {
      debugPrint('Error deleting tour package: $e');
    } finally {
      isTourLoading.value = false;
    }
  }

  void prepareForAddTour() {
    tourPackageTitleController.clear();
    tourPackageDescriptionController.clear();
    tourPackagePriceController.clear();
    selectedTourPackageImages.clear();
    currentTourPackageImageUrls.clear();
    tourPackageImagesToDelete.clear();
  }

  void prepareForEditTour(TourPackage package) {
    prepareForAddTour();
    tourPackageTitleController.text = package.title ?? '';
    tourPackageDescriptionController.text = package.description ?? '';

    if (package.price != null) {
      final formatter = NumberFormat.decimalPattern('id_ID');
      tourPackagePriceController.text = formatter.format(package.price);
    } else {
      tourPackagePriceController.clear();
    }

    currentTourPackageImageUrls.assignAll(package.imageUrls ?? []);
  }

  void addSelectedImages(List<File> images) {
    selectedTourPackageImages.addAll(images);
  }

  void removeSelectedImage(int index) {
    selectedTourPackageImages.removeAt(index);
  }

  void markImageToDelete(String imageUrl) {
    if (currentTourPackageImageUrls.remove(imageUrl)) {
      tourPackageImagesToDelete.add(imageUrl);
    }
  }

  void unmarkImageToDelete(String imageUrl) {
    if (tourPackageImagesToDelete.remove(imageUrl)) {
      currentTourPackageImageUrls.add(imageUrl);
    }
  }
}
