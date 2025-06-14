import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Diperlukan untuk format tanggal
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class UpsertEventView extends StatelessWidget {
  final Event? event;
  const UpsertEventView({super.key, this.event});

  bool get isEditMode => event != null;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourEventController>();
    final String appBarTitle = isEditMode ? "Edit Event" : "Tambah Event";
    final String buttonTitle = isEditMode ? "Simpan Perubahan" : "Simpan Event";

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Get.back(),
          ),
          title: Text(
            appBarTitle,
            style: semiBold.copyWith(
              fontSize: ScaleHelper.scaleTextForDevice(20),
              color: Neutral.white1,
            ),
          ),
          backgroundColor: Primary.darkColor,
          iconTheme: const IconThemeData(color: Neutral.white1),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ), // Sederhanakan AppBar untuk contoh
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.eventFormKey,
            child: ListView(
              children: [
                _buildTextField(controller.eventTitleController, 'Judul Event'),
                _buildTextField(
                  controller.eventDescriptionController,
                  'Deskripsi',
                  maxLines: 5,
                ),
                _buildTextField(controller.eventLocationController, 'Lokasi'),
                _buildTextField(
                  controller.eventPriceController,
                  'Harga (kosongkan jika gratis)',
                  isNumber: true,
                  prefixText: 'Rp ',
                ),
                _buildDatePicker(context, controller),
                const SizedBox(height: 16),
                _buildImagePicker(controller),
                const SizedBox(height: 24),
                Obx(
                  () =>
                      controller.isEventLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: () {
                              if (isEditMode) {
                                controller.editEvent(docId: event!.id);
                              } else {
                                controller.addEvent();
                              }
                            },
                            child: Text(buttonTitle),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String label, {
    int maxLines = 1,
    bool isNumber = false,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: textController,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            // Pengecualian untuk harga, boleh kosong
            if (label.contains('Harga')) return null;
            return '$label wajib diisi.';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Masukkan format angka yang valid.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    ManageTourEventController controller,
  ) {
    return Obx(
      () => ListTile(
        title: Text(
          controller.selectedEventDate.value == null
              ? 'Pilih Tanggal Event'
              : 'Tanggal: ${DateFormat('dd MMMM yyyy').format(controller.selectedEventDate.value!)}',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: controller.selectedEventDate.value ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            controller.selectedEventDate.value = pickedDate;
          }
        },
      ),
    );
  }

  Widget _buildImagePicker(ManageTourEventController controller) {
    return Obx(() {
      Widget imagePreview;
      if (controller.selectedEventImage.value != null) {
        // Tampilkan gambar baru yang dipilih
        imagePreview = Image.file(controller.selectedEventImage.value!);
      } else if (controller.currentEventImageUrl.value != null &&
          controller.currentEventImageUrl.value!.isNotEmpty) {
        // Tampilkan gambar lama dari network
        imagePreview = Image.network(controller.currentEventImageUrl.value!);
      } else {
        // Tampilan placeholder jika tidak ada gambar
        imagePreview = Container(
          height: 150,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.camera_alt, color: Colors.grey),
          ),
        );
      }

      return Column(
        children: [
          const Text("Gambar Event"),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => controller.pickEventImage(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePreview,
            ),
          ),
        ],
      );
    });
  }
}
