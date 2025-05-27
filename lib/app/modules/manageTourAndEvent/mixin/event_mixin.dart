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
  final Rxn<DateTime> selectedEventDate = Rxn<DateTime>();

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
      Get.snackbar('Error', 'Gagal memuat event');
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
    return eventFormKey.currentState?.validate() ?? false;
  }

  Future<void> addEvent() async {
    if (!validateEventForm() || selectedEventImage.value == null) {
      Get.snackbar('Invalid', 'Isi semua field dan pilih gambar');
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
      );
      clearEventForm();
      fetchEvents();
      Get.back();
      Get.snackbar('Sukses', 'Event berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan event: $e');
    } finally {
      isEventLoading.value = false;
    }
  }

  Future<void> editEvent({required String docId}) async {
    if (!validateEventForm() || currentEventImageUrl.value == null) {
      Get.snackbar('Invalid', 'Isi semua field dan pilih tanggal');
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
        oldImageUrl: currentEventImageUrl.value!,
        newImageFile: selectedEventImage.value,
        deleteOldImage: selectedEventImage.value != null,
      );
      clearEventForm();
      fetchEvents();
      Get.back();
      Get.snackbar('Sukses', 'Event berhasil diubah');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengedit event');
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
      Get.snackbar('Error', 'Gagal menghapus event');
    } finally {
      isEventLoading.value = false;
    }
  }

  void fillEventForm(Event event) {
    eventTitleController.text = event.title;
    eventDescriptionController.text = event.description;
    eventLocationController.text = event.location;
    selectedEventDate.value = event.eventDate;
    currentEventImageUrl.value = event.imageUrl;
    selectedEventImage.value = null;
  }

  void clearEventForm() {
    eventTitleController.clear();
    eventDescriptionController.clear();
    eventLocationController.clear();
    selectedEventDate.value = null;
    selectedEventImage.value = null;
    currentEventImageUrl.value = null;
  }
}
