import 'dart:io';
import 'package:flutter/material.dart'; // Diperlukan untuk Colors pada Snackbar dan debugPrint
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart'; // Pastikan path ini benar
import 'package:tangaya_apps/app/data/services/tour_service.dart'; // Pastikan path ini benar
// import 'package:tangaya_apps/app/routes/app_pages.dart'; // Uncomment jika Anda menggunakan Get.offNamed

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
  final RxList<File?> selectedTourPackageImages =
      <File?>[].obs; // Tetap File? untuk fleksibilitas picker
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
    debugPrint("[TourMixin] Memulai fetchTourPackages...");
    try {
      isTourLoading.value = true;
      final packages = await _tourPackageService.fetchTourPackages();
      tourPackages.assignAll(packages);
      debugPrint(
        "[TourMixin] Paket wisata diterima dari service: ${packages.length} item.",
      );
    } catch (e, s) {
      debugPrint(
        "[TourMixin] Error saat fetchTourPackages: $e\nStack trace: $s",
      );
      Get.snackbar(
        'Error',
        'Gagal mengambil paket wisata: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTourLoading.value = false;
    }
  }

  bool validateTourPackageForm() {
    debugPrint("[TourMixin] Memulai validasi form paket wisata...");
    // 1. Validasi FormFields (judul, deskripsi, harga) menggunakan GlobalKey
    if (!(tourPackageFormKey.currentState?.validate() ?? false)) {
      debugPrint("[TourMixin] Validasi dasar form (TextFormField) gagal.");
      // Pesan error dari validator TextFormField akan muncul
      // Get.snackbar('Invalid', 'Harap isi semua field formulir dengan benar.',
      //     backgroundColor: Colors.orange, colorText: Colors.white); // Pesan umum jika diperlukan
      return false;
    }

    // 2. Validasi Harga (jika ada logika khusus selain required & number)
    // Validator di TextFormField sudah menangani format angka dan wajib isi.
    // Di sini bisa ditambahkan jika harga harus > 0, dll.
    final priceText = tourPackagePriceController.text.trim();
    // Jika TextFormField validator sudah memastikan ini adalah angka, pengecekan tryParse bisa jadi redundan,
    // namun untuk keamanan tambahan tidak masalah.
    final price = double.tryParse(priceText);
    if (price == null && priceText.isNotEmpty) {
      // Jika tidak kosong tapi tidak bisa di-parse
      Get.snackbar(
        'Invalid',
        'Format harga tidak valid.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      debugPrint("[TourMixin] Validasi harga gagal: format tidak valid.");
      return false;
    }
    if (price != null && price < 0) {
      Get.snackbar(
        'Invalid',
        'Harga tidak boleh negatif.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      debugPrint("[TourMixin] Validasi harga gagal: harga negatif.");
      return false;
    }
    // Asumsi harga wajib diisi sudah ditangani oleh validator TextFormField.

    // 3. Validasi Gambar (minimal 1 gambar)
    if (selectedTourPackageImages.whereType<File>().isEmpty) {
      // Hitung hanya File yang valid
      Get.snackbar(
        'Invalid',
        'Minimal satu gambar harus dipilih.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      debugPrint(
        "[TourMixin] Validasi gambar gagal: tidak ada gambar dipilih.",
      );
      return false;
    }
    debugPrint("[TourMixin] Validasi form paket wisata berhasil.");
    return true;
  }

  Future<void> addTourPackage() async {
    // Panggil validasi terpusat
    if (!validateTourPackageForm()) {
      return; // Validasi gagal, snackbar sudah ditampilkan oleh validateTourPackageForm()
    }

    debugPrint(
      "[TourMixin] Memulai proses addTourPackage setelah validasi berhasil...",
    );
    try {
      isTourLoading.value = true;

      // Ambil dan parse harga dengan aman
      final price = double.parse(
        tourPackagePriceController.text.trim(),
      ); // Seharusnya aman karena sudah divalidasi

      await _tourPackageService.addTourPackage(
        title: tourPackageTitleController.text.trim(),
        description: tourPackageDescriptionController.text.trim(),
        price: price,
        // Pastikan mengirim List<File>, bukan List<File?>
        imageFiles: selectedTourPackageImages.whereType<File>().toList(),
      );
      debugPrint("[TourMixin] Paket wisata berhasil ditambahkan ke service.");

      clearTourPackageForm(); // Bersihkan form setelah sukses
      debugPrint("[TourMixin] Form paket wisata dibersihkan.");

      await fetchTourPackages(); // Tunggu data terbaru dimuat
      debugPrint(
        "[TourMixin] fetchTourPackages selesai setelah addTourPackage. Jumlah paket: ${tourPackages.length}",
      );

      // Perintah untuk kembali ke halaman sebelumnya
      if (Get.key.currentState?.mounted ?? false) {
        // Cek jika aman untuk navigasi
        if (Get.previousRoute.isNotEmpty) {
          Get.back();
          debugPrint("[TourMixin] Berhasil Get.back() ke rute sebelumnya.");
        } else {
          // Jika tidak ada halaman sebelumnya (kasus jarang untuk halaman 'tambah'),
          // mungkin navigasi ke halaman default atau halaman manajemen.
          // Get.offNamed(Routes.MANAGE_TOUR_EVENT); // Ganti dengan rute yang sesuai
          debugPrint(
            "[TourMixin] Tidak ada rute sebelumnya untuk Get.back(). Pertimbangkan Get.offNamed() jika perlu.",
          );
        }
      } else {
        debugPrint(
          "[TourMixin] Tidak bisa Get.back() karena state tidak mounted.",
        );
      }

      Get.snackbar(
        'Sukses',
        'Paket wisata berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      debugPrint("[TourMixin] Snackbar sukses ditampilkan.");
    } catch (e, s) {
      debugPrint(
        "[TourMixin] Error saat menambahkan paket wisata: $e\nStack trace: $s",
      );
      Get.snackbar(
        'Error',
        'Gagal menambahkan paket wisata: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTourLoading.value = false;
      debugPrint("[TourMixin] Proses addTourPackage selesai (finally block).");
    }
  }

  Future<void> editTourPackage({required String docId}) async {
    if (!validateTourPackageForm()) {
      // Gunakan validateTourPackageForm yang sudah disempurnakan
      // Get.snackbar('Invalid', 'Harap isi semua field dengan benar'); // Pesan sudah dari validateTourPackageForm
      return;
    }
    debugPrint(
      "[TourMixin] Memulai proses editTourPackage untuk docId: $docId",
    );
    try {
      isTourLoading.value = true;
      final price = double.parse(tourPackagePriceController.text.trim());

      await _tourPackageService.editTourPackage(
        docId: docId,
        newTitle: tourPackageTitleController.text.trim(),
        newDescription: tourPackageDescriptionController.text.trim(),
        newPrice: price,
        oldImageUrls: currentTourPackageImageUrls.toList(),
        newImageFiles: selectedTourPackageImages.whereType<File>().toList(),
        imagesToDelete: tourPackageImagesToDelete.toList(),
      );
      debugPrint("[TourMixin] Paket wisata $docId berhasil diubah di service.");

      clearTourPackageForm(); // Bersihkan form setelah edit
      debugPrint("[TourMixin] Form paket wisata dibersihkan setelah edit.");

      await fetchTourPackages(); // Muat ulang data
      debugPrint(
        "[TourMixin] fetchTourPackages selesai setelah editTourPackage. Jumlah paket: ${tourPackages.length}",
      );

      if (Get.key.currentState?.mounted ?? false) {
        if (Get.previousRoute.isNotEmpty) {
          Get.back();
          debugPrint("[TourMixin] Berhasil Get.back() setelah edit.");
        } else {
          debugPrint(
            "[TourMixin] Tidak ada rute sebelumnya untuk Get.back() setelah edit.",
          );
        }
      } else {
        debugPrint(
          "[TourMixin] Tidak bisa Get.back() setelah edit karena state tidak mounted.",
        );
      }

      Get.snackbar(
        'Sukses',
        'Paket wisata berhasil diubah',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, s) {
      debugPrint(
        "[TourMixin] Error saat mengedit paket wisata $docId: $e\nStack trace: $s",
      );
      Get.snackbar(
        'Error',
        'Gagal mengedit paket wisata: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTourLoading.value = false;
    }
  }

  Future<void> deleteTourPackage({
    required String docId,
    required List<String> imageUrls,
  }) async {
    debugPrint("[TourMixin] Mencoba menghapus paket wisata ID: $docId");
    try {
      isTourLoading.value = true;
      await _tourPackageService.deleteTourPackage(
        docId: docId,
        imageUrls: imageUrls,
      );
      debugPrint(
        "[TourMixin] Paket wisata $docId berhasil dihapus dari service.",
      );

      // Update UI optimis
      final index = tourPackages.indexWhere((pkg) => pkg.id == docId);
      if (index != -1) {
        tourPackages.removeAt(index);
        debugPrint(
          "[TourMixin] Paket wisata $docId dihapus dari RxList 'tourPackages' lokal.",
        );
      } else {
        debugPrint(
          "[TourMixin] Paket wisata $docId tidak ditemukan di list lokal, memanggil fetchTourPackages.",
        );
        await fetchTourPackages();
      }
      // fetchTourPackages(); // Bisa dipanggil lagi untuk memastikan konsistensi jika perlu
      Get.snackbar(
        'Sukses',
        'Paket wisata berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, s) {
      debugPrint(
        "[TourMixin] Error saat menghapus paket wisata $docId: $e\nStack trace: $s",
      );
      Get.snackbar(
        'Error',
        'Gagal menghapus paket wisata: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTourLoading.value = false;
    }
  }

  Future<TourPackage?> getPackageById(String id) async {
    // Tambahkan loading state jika diperlukan
    // isTourLoading.value = true;
    try {
      return await _tourPackageService.getPackageById(id);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil detail paket wisata: $e');
      return null;
    } finally {
      // isTourLoading.value = false;
    }
  }

  void fillTourPackageForm(TourPackage package) {
    tourPackageTitleController.text = package.title ?? '';
    tourPackageDescriptionController.text = package.description ?? '';
    tourPackagePriceController.text =
        package.price?.toStringAsFixed(0) ?? ''; // Format tanpa desimal
    currentTourPackageImageUrls.assignAll(package.imageUrls ?? []);
    selectedTourPackageImages.clear();
    tourPackageImagesToDelete.clear();
    debugPrint("[TourMixin] Form diisi dengan data paket: ${package.title}");
  }

  void clearTourPackageForm() {
    tourPackageTitleController.clear();
    tourPackageDescriptionController.clear();
    tourPackagePriceController.clear();
    selectedTourPackageImages.clear();
    tourPackageImagesToDelete.clear();
    currentTourPackageImageUrls.clear();
    // tourPackageFormKey.currentState?.reset(); // Hati-hati jika form tidak selalu visible
    debugPrint("[TourMixin] Form paket wisata dikosongkan.");
  }

  // Method untuk menambahkan gambar yang dipilih
  void addSelectedImage(File? image) {
    if (image != null) {
      selectedTourPackageImages.add(image);
    }
  }

  // Method untuk menghapus gambar yang dipilih (sebelum upload)
  void removeSelectedImage(int index) {
    if (index >= 0 && index < selectedTourPackageImages.length) {
      selectedTourPackageImages.removeAt(index);
    }
  }

  // Method untuk menandai gambar untuk dihapus (gambar yang sudah ada di Firestore)
  void markImageToDelete(String imageUrl) {
    if (currentTourPackageImageUrls.contains(imageUrl)) {
      // Hanya tandai jika ada di URL saat ini
      if (!tourPackageImagesToDelete.contains(imageUrl)) {
        tourPackageImagesToDelete.add(imageUrl);
      }
      currentTourPackageImageUrls.remove(
        imageUrl,
      ); // Hapus dari tampilan URL saat ini
    }
  }

  // Method untuk membatalkan penghapusan gambar
  void unmarkImageToDelete(String imageUrl) {
    if (tourPackageImagesToDelete.remove(imageUrl)) {
      // Jika berhasil dihapus dari daftar 'toDelete'
      if (!currentTourPackageImageUrls.contains(imageUrl)) {
        // Dan belum ada di current URLs
        currentTourPackageImageUrls.add(
          imageUrl,
        ); // Tambahkan kembali untuk ditampilkan
      }
    }
  }
}
