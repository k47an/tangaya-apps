import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class AddEventView extends StatelessWidget {
  const AddEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourEventController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tambah Event",
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(20),
            color: Neutral.white1,
          ),
        ),
        backgroundColor: Primary.mainColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        elevation: 5.0,
        iconTheme: const IconThemeData(color: Neutral.white1),
      ),
      body: Padding(
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
        child: Form(
          key: controller.eventFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextInput(controller.eventTitleController, 'Judul Event'),
                const SizedBox(height: 12),
                _buildTextArea(
                  controller.eventDescriptionController,
                  'Deskripsi Event',
                ),
                const SizedBox(height: 12),
                _buildTextInput(controller.eventLocationController, 'Lokasi'),
                const SizedBox(height: 12),
                _buildDatePicker(controller),
                const SizedBox(height: 12),
                _buildImagePicker(controller),
                const SizedBox(height: 24),
                _buildSaveButton(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Primary.mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
      ),
      validator:
          (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildTextArea(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Primary.mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
      ),
      validator:
          (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildDatePicker(ManageTourEventController controller) {
    return Obx(() {
      final selectedDate = controller.selectedEventDate.value;
      final dateText =
          selectedDate != null
              ? DateFormat('dd MMM yyyy').format(selectedDate)
              : 'Pilih Tanggal Event';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateText, style: medium.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: const Text("Pilih Tanggal"),
            onPressed: () async {
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.selectedEventDate.value = picked;
              }
            },
          ),
        ],
      );
    });
  }

  Widget _buildImagePicker(ManageTourEventController controller) {
    return Obx(() {
      final imageFile = controller.selectedEventImage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) {
                controller.selectedEventImage.value = File(picked.path);
              }
            },
            icon: const Icon(Icons.image),
            label: const Text("Pilih Gambar"),
          ),
          const SizedBox(height: 10),
          if (imageFile != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    imageFile,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.selectedEventImage.value = null,
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildSaveButton(ManageTourEventController controller) {
    return Obx(() {
      final isLoading = controller.isEventLoading.value;

      return isLoading
          ? const CircularProgressIndicator()
          : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Lakukan validasi hanya saat tombol ditekan
                final isFormValid =
                    controller.eventFormKey.currentState?.validate() ?? false;
                final hasImage = controller.selectedEventImage.value != null;
                final hasDate = controller.selectedEventDate.value != null;

                if (isFormValid && hasImage && hasDate) {
                  await controller.addEvent();
                  Get.snackbar(
                    'Berhasil',
                    'Event berhasil ditambahkan',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  controller.clearEventForm();
                  Get.back();
                } else {
                  Get.snackbar(
                    'Error',
                    'Pastikan semua field, tanggal dan gambar sudah diisi!',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Primary.subtleColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Simpan", style: TextStyle(fontSize: 16)),
            ),
          );
    });
  }
}
