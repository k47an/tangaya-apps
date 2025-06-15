import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/services/event_service.dart';

mixin EventMixin on GetxController {
  final EventService _eventService = Get.find<EventService>();
  final RxBool isEventLoading = false.obs;
  final GlobalKey<FormState> eventFormKey = GlobalKey<FormState>();
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  final TextEditingController eventPriceController = TextEditingController();
  final Rxn<DateTime> selectedEventDate = Rxn<DateTime>();
  final Rx<File?> selectedEventImage = Rx<File?>(null);
  final RxnString currentEventImageUrl = RxnString();
  final RxList<Event> events = <Event>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  @override
  void onClose() {
    eventTitleController.dispose();
    eventDescriptionController.dispose();
    eventLocationController.dispose();
    eventPriceController.dispose();
    super.onClose();
  }

  Future<void> fetchEvents() async {
    try {
      isEventLoading.value = true;
      final result = await _eventService.fetchEvents();
      events.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat event: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isEventLoading.value = false;
    }
  }

  bool _validateEventForm({bool isEditMode = false}) {
    if (!(eventFormKey.currentState?.validate() ?? false)) {
      return false;
    }
    if (selectedEventDate.value == null) {
      Get.snackbar(
        'Tanggal Wajib',
        'Tanggal event harus dipilih.',
        backgroundColor: Colors.orange,
      );
      return false;
    }
    if (!isEditMode && selectedEventImage.value == null) {
      Get.snackbar(
        'Gambar Wajib',
        'Gambar event harus dipilih.',
        backgroundColor: Colors.orange,
      );
      return false;
    }
    return true;
  }

  double? _parsePrice() {
    final priceText = eventPriceController.text.trim();
    return priceText.isEmpty ? null : double.tryParse(priceText);
  }

  Future<void> addEvent() async {
    if (!_validateEventForm(isEditMode: false)) return;

    try {
      isEventLoading.value = true;
      await _eventService.addEvent(
        title: eventTitleController.text.trim(),
        description: eventDescriptionController.text.trim(),
        location: eventLocationController.text.trim(),
        eventDate: selectedEventDate.value!,
        imageFile: selectedEventImage.value!,
        price: _parsePrice(),
      );
      fetchEvents();
      Get.back();
      Get.snackbar(
        'Sukses',
        'Event berhasil ditambahkan.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan event: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isEventLoading.value = false;
    }
  }

  Future<void> editEvent({required String docId}) async {
    if (!_validateEventForm(isEditMode: true)) return;

    try {
      isEventLoading.value = true;
      await _eventService.editEvent(
        docId: docId,
        title: eventTitleController.text.trim(),
        description: eventDescriptionController.text.trim(),
        location: eventLocationController.text.trim(),
        eventDate: selectedEventDate.value!,
        oldImageUrl: currentEventImageUrl.value,
        newImageFile: selectedEventImage.value,
        price: _parsePrice(),
      );
      fetchEvents();
      Get.back();
      Get.snackbar(
        'Sukses',
        'Event berhasil diubah.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengedit event: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isEventLoading.value = false;
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      isEventLoading.value = true;
      await _eventService.deleteEvent(
        docId: event.id,
        imageUrl: event.imageUrl,
      );
      events.removeWhere((e) => e.id == event.id);
      Get.snackbar(
        'Sukses',
        'Event berhasil dihapus.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus event: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isEventLoading.value = false;
    }
  }

  void prepareForAddEvent() {
    eventFormKey.currentState?.reset();
    eventTitleController.clear();
    eventDescriptionController.clear();
    eventLocationController.clear();
    eventPriceController.clear();
    selectedEventDate.value = null;
    selectedEventImage.value = null;
    currentEventImageUrl.value = null;
  }

  void prepareForEditEvent(Event event) {
    prepareForAddEvent();
    eventTitleController.text = event.title;
    eventDescriptionController.text = event.description;
    eventLocationController.text = event.location;
    eventPriceController.text = event.price?.toStringAsFixed(0) ?? '';
    selectedEventDate.value = event.eventDate;
    currentEventImageUrl.value = event.imageUrl;
  }

  Future<void> pickEventImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      selectedEventImage.value = File(pickedFile.path);
    }
  }
}
