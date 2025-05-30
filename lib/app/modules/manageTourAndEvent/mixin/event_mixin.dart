import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/services/event_service.dart';

mixin EventMixin on GetxController {
  final EventService _eventService = EventService();
  final RxBool isEventLoading = false.obs;

  // Form and Input Controllers
  final GlobalKey<FormState> eventFormKey = GlobalKey<FormState>();
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  final TextEditingController eventPriceController = TextEditingController();
  final Rxn<DateTime> selectedEventDate = Rxn<DateTime>();
  // Variabel untuk melacak ID event yang datanya sedang dimuat di form
  final RxnString _idOfDataInEventForm = RxnString();

  // Image Management
  final Rx<File?> selectedEventImage = Rx<File?>(null);
  final RxnString currentEventImageUrl = RxnString();

  // Data List
  final RxList<Event> events = <Event>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    debugPrint('EventMixin initialized');
  }

  Future<void> fetchEvents() async {
    try {
      isEventLoading.value = true;
      final result = await _eventService.fetchEvents();
      events.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat event: ${e.toString()}');
    } finally {
      isEventLoading.value = false;
    }
  }

  Future<void> pickEventImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedEventImage.value = File(picked.path);
    }
  }

  bool validateEventForm() {
    final priceText = eventPriceController.text.trim();
    // Validasi harga: jika tidak kosong, harus berupa angka yang valid. Jika kosong, itu valid (gratis).
    if (priceText.isNotEmpty && double.tryParse(priceText) == null) {
      Get.snackbar(
        'Invalid',
        'Format harga tidak valid. Kosongkan jika gratis.',
      );
      return false;
    }
    // Validasi form umum
    if (!(eventFormKey.currentState?.validate() ?? false)) {
      return false;
    }
    // Validasi tambahan yang tidak dicakup oleh Form widget
    if (selectedEventDate.value == null) {
      Get.snackbar('Invalid', 'Tanggal event harus dipilih.');
      return false;
    }
    // Untuk addEvent, gambar wajib. Untuk editEvent, gambar tidak selalu wajib diubah.
    // Validasi gambar akan ditangani spesifik di addEvent/editEvent jika perlu.
    return true;
  }

  double? _parsePrice() {
    final priceText = eventPriceController.text.trim();
    if (priceText.isEmpty) {
      return null; // Gratis
    }
    return double.tryParse(priceText); // Akan null jika format tidak valid
  }

  Future<void> addEvent() async {
    if (!validateEventForm() || selectedEventImage.value == null) {
      // Gambar wajib untuk event baru
      Get.snackbar(
        'Invalid',
        'Isi semua field yang wajib, pilih tanggal, dan pilih gambar.',
      );
      return;
    }

    final price = _parsePrice();
    // Jika priceText tidak kosong tapi parsing gagal, price akan null.
    // Kita sudah validasi ini di validateEventForm, tapi double check di sini bisa lebih aman.
    if (eventPriceController.text.trim().isNotEmpty && price == null) {
      Get.snackbar(
        'Invalid',
        'Format harga tidak valid. Kosongkan jika gratis.',
      );
      return;
    }

    try {
      isEventLoading.value = true;
      await _eventService.addEvent(
        title: eventTitleController.text.trim(),
        description: eventDescriptionController.text.trim(),
        location: eventLocationController.text.trim(),
        eventDate: selectedEventDate.value!,
        imageFile: selectedEventImage.value!,
        price: price, // Kirim harga (bisa null)
      );
      clearEventForm();
      fetchEvents();
      Get.back();
      Get.snackbar('Sukses', 'Event berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan event: ${e.toString()}');
    } finally {
      isEventLoading.value = false;
    }
  }

  Future<void> editEvent({required String docId}) async {
    if (!validateEventForm()) {
      // Pesan error sudah ditampilkan oleh validateEventForm
      return;
    }

    final price = _parsePrice();
    if (eventPriceController.text.trim().isNotEmpty && price == null) {
      Get.snackbar(
        'Invalid',
        'Format harga tidak valid. Kosongkan jika gratis.',
      );
      return;
    }

    try {
      isEventLoading.value = true;
      await _eventService.editEvent(
        docId: docId,
        title: eventTitleController.text.trim(),
        description: eventDescriptionController.text.trim(),
        location: eventLocationController.text.trim(),
        eventDate: selectedEventDate.value!,
        oldImageUrl: currentEventImageUrl.value ?? '',
        newImageFile: selectedEventImage.value,
        // Jika ada gambar baru, atau jika gambar lama ada dan tidak ada gambar baru (artinya mau hapus gambar lama)
        deleteOldImage:
            selectedEventImage.value != null ||
            (currentEventImageUrl.value != null &&
                currentEventImageUrl.value!.isNotEmpty &&
                selectedEventImage.value == null),
        price: price, // Kirim harga (bisa null)
      );
      clearEventForm();
      fetchEvents();
      Get.back();
      Get.snackbar('Sukses', 'Event berhasil diubah');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengedit event: ${e.toString()}');
    } finally {
      isEventLoading.value = false;
    }
  }

  Future<void> deleteEvent({
    required String docId,
    required String imageUrl,
  }) async {
    try {
      isEventLoading.value = true;
      await _eventService.deleteEvent(docId: docId, imageUrl: imageUrl);
      fetchEvents();
      Get.snackbar('Sukses', 'Event berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus event: ${e.toString()}');
    } finally {
      isEventLoading.value = false;
    }
  }

  void fillEventForm(Event event) {
    // Jika ID event yang sama sudah ada di form, jangan isi ulang.
    // Ini mencegah penimpaan input pengguna jika build method dipanggil lagi.
    if (_idOfDataInEventForm.value == event.id) {
      // Anda bisa menambahkan pengecekan lebih lanjut di sini jika diperlukan,
      // misalnya, apakah isi TextEditingController masih sesuai dengan data event.
      // Untuk saat ini, asumsi jika ID sama, form sudah terisi dengan benar.
      return;
    }

    eventTitleController.text = event.title;
    eventDescriptionController.text = event.description;
    eventLocationController.text = event.location;
    eventPriceController.text = event.price?.toString() ?? '';
    selectedEventDate.value = event.eventDate;
    currentEventImageUrl.value =
        event.imageUrl; // Untuk menampilkan gambar lama
    selectedEventImage.value = null; // Reset gambar baru yang mungkin dipilih

    _idOfDataInEventForm.value =
        event.id; // Tandai bahwa data event ini sudah dimuat ke form
  }

  void clearEventForm() {
    eventTitleController.clear();
    eventDescriptionController.clear();
    eventLocationController.clear();
    eventPriceController.clear();
    selectedEventDate.value = null;
    selectedEventImage.value = null;
    currentEventImageUrl.value = null;
    _idOfDataInEventForm.value = null; // Bersihkan juga ID pelacak ini
    // eventFormKey.currentState?.reset(); // Pertimbangkan ini jika perlu
  }
}
