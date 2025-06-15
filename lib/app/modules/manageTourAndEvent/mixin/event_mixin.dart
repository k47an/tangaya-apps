import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/services/event_service.dart';
import 'package:tangaya_apps/utils/global_components/snackbar.dart';

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
      debugPrint('Error fetching events: $e');
    } finally {
      isEventLoading.value = false;
    }
  }

  bool _validateEventForm({bool isEditMode = false}) {
    if (!(eventFormKey.currentState?.validate() ?? false)) {
      return false;
    }
    if (selectedEventDate.value == null) {
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Masukan tanggal event.',
        type: SnackBarType.warning,
      );
      return false;
    }
    if (!isEditMode && selectedEventImage.value == null) {
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Masukan gambar event.',
        type: SnackBarType.warning,
      );
      return false;
    }
    return true;
  }

  double? _parsePrice() {
    // 2. BERSIHKAN FORMATTER SEBELUM PARSING
    final priceText = eventPriceController.text.trim().replaceAll('.', '');
    if (priceText.isEmpty) {
      return null;
    }
    return double.tryParse(priceText);
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
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Event berhasil ditambahkan.',
        type: SnackBarType.success,
      );
    } catch (e) {
      debugPrint('Gagal menambahkan event');
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
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Berhasil mengedit event.',
        type: SnackBarType.success,
      );
    } catch (e) {
      debugPrint('Gagal mengedit event');
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
      CustomSnackBar.show(
        context: Get.context!,
        message: 'Event berhasil dihapus.',
        type: SnackBarType.success,
      );
    } catch (e) {
      debugPrint('Gagal menghapus event: $e');
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

    if (event.price != null && event.price! > 0) {
      final formatter = NumberFormat.decimalPattern('id_ID');
      eventPriceController.text = formatter.format(event.price);
    } else {
      eventPriceController.clear();
    }

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
