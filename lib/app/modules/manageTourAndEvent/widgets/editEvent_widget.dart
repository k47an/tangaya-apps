import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EditEventView extends StatefulWidget {
  final Event event;

  const EditEventView({super.key, required this.event});

  @override
  State<EditEventView> createState() => _EditEventViewState();
}

class _EditEventViewState extends State<EditEventView> {
  final controller = Get.find<ManageTourEventController>();

  @override
  void initState() {
    super.initState();
    controller.fillEventForm(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Event',
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
        iconTheme: const IconThemeData(color: Neutral.white1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
        child: Form(
          key: controller.eventFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              _buildImageSection(controller, widget.event.imageUrl),
              const SizedBox(height: 24),
              _buildSaveButton(controller, widget.event.id),
            ],
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
          (value) =>
              value == null || value.isEmpty ? '$label wajib diisi' : null,
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
          (value) =>
              value == null || value.isEmpty ? '$label wajib diisi' : null,
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
                initialDate:
                    controller.selectedEventDate.value ?? DateTime.now(),
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

  Widget _buildImageSection(
    ManageTourEventController controller,
    String? initialImageUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gambar Event:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedImage = controller.selectedEventImage.value;
          final currentImageUrl = controller.currentEventImageUrl.value;

          if (selectedImage != null) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: Image.file(selectedImage, fit: BoxFit.cover),
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
            );
          } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: Image.network(currentImageUrl, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      controller.currentEventImageUrl.value = null;
                      // Anda mungkin ingin menambahkan logika untuk menandai gambar untuk dihapus
                      // jika Anda mengizinkan penghapusan gambar yang sudah ada tanpa menggantinya.
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Text('Tidak ada gambar dipilih');
          }
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            await controller.pickEventImage();
          },
          icon: const Icon(Icons.image),
          label: const Text("Pilih Gambar Baru"),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ManageTourEventController controller, String docId) {
    return Obx(() {
      final isLoading = controller.isEventLoading.value;
      final hasDate = controller.selectedEventDate.value != null;

      return isLoading
          ? const CircularProgressIndicator()
          : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final isFormValid =
                    controller.eventFormKey.currentState?.validate() ?? false;

                if (isFormValid && hasDate) {
                  await controller.editEvent(docId: docId);
                } else {
                  Get.snackbar(
                    'Error',
                    'Pastikan semua field dan tanggal sudah diisi!',
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
              child: const Text(
                "Simpan Perubahan",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
    });
  }
}
