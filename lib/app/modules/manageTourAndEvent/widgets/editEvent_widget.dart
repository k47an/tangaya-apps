import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk DateFormat dan NumberFormat
import 'package:tangaya_apps/app/data/models/event_model.dart'; // Model Event Anda
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart'; // Controller Anda
import 'package:tangaya_apps/constant/constant.dart'; // Konstanta aplikasi Anda (warna, style, dll.)

// --- Helper Functions untuk Membangun UI ---

Widget _buildEditTextInput(TextEditingController ctrl, String label) {
  return TextFormField(
    controller: ctrl,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Primary.mainColor,
      ), // Asumsi Primary.mainColor dari constant.dart
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Primary.mainColor),
      ),
    ),
    validator:
        (value) => value == null || value.isEmpty ? '$label wajib diisi' : null,
  );
}

Widget _buildEditPriceInput(TextEditingController ctrl, String label) {
  return TextFormField(
    controller: ctrl,
    decoration: InputDecoration(
      labelText: label,
      hintText: 'Kosongkan jika gratis',
      labelStyle: TextStyle(color: Primary.mainColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Primary.mainColor),
      ),
      prefixText: 'Rp ',
    ),
    keyboardType: TextInputType.numberWithOptions(
      decimal: false,
    ), // Set true jika butuh desimal
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly, // Hanya izinkan angka
    ],
    validator: (value) {
      if (value == null || value.isEmpty) {
        return null; // Boleh kosong (gratis)
      }
      final price = double.tryParse(value);
      if (price == null) {
        return 'Masukkan format angka yang valid';
      }
      if (price < 0) {
        return 'Harga tidak boleh negatif';
      }
      return null;
    },
  );
}

Widget _buildEditTextArea(TextEditingController ctrl, String label) {
  return TextFormField(
    controller: ctrl,
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
        (value) => value == null || value.isEmpty ? '$label wajib diisi' : null,
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
              initialDate: controller.selectedEventDate.value ?? DateTime.now(),
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

Widget _buildEditImageSection(ManageTourEventController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Gambar Event:",
        style: regular.copyWith(fontSize: 12, color: Neutral.dark2),
      ),
      const SizedBox(height: 8),
      Obx(() {
        // Membungkus dengan Obx untuk mereaksikan perubahan gambar
        final selectedImageFile = controller.selectedEventImage.value;
        final currentImageUrl = controller.currentEventImageUrl.value;
        Widget imageDisplayWidget;

        if (selectedImageFile != null) {
          // Tampilkan gambar baru yang dipilih dari galeri
          imageDisplayWidget = Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  selectedImageFile,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                  onPressed:
                      () =>
                          controller.selectedEventImage.value =
                              null, // Hapus gambar yang baru dipilih
                ),
              ),
            ],
          );
        } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
          // Tampilkan gambar lama dari URL
          imageDisplayWidget = Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  currentImageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[600],
                            size: 40,
                          ),
                        ),
                      ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    controller.currentEventImageUrl.value =
                        null; // Hapus URL gambar saat ini
                    controller.selectedEventImage.value =
                        null; // Pastikan juga selected image null
                  },
                ),
              ),
            ],
          );
        } else {
          // Placeholder jika tidak ada gambar sama sekali
          imageDisplayWidget = InkWell(
            onTap: () async => await controller.pickEventImage(),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 40,
                      color: Primary.mainColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pilih Gambar Event",
                      style: TextStyle(color: Primary.mainColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            imageDisplayWidget,
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await controller.pickEventImage(); // Fungsi dari EventMixin
              },
              icon: const Icon(Icons.image_outlined),
              label: Text(
                (selectedImageFile != null ||
                        (currentImageUrl != null && currentImageUrl.isNotEmpty))
                    ? "Ganti Gambar"
                    : "Pilih Gambar",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200], // Warna tombol yang netral
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      }),
    ],
  );
}

Widget _buildEditSaveButton(
  ManageTourEventController controller,
  String docId,
) {
  return Obx(() {
    // Membungkus dengan Obx untuk mereaksikan perubahan isEventLoading
    final isLoading = controller.isEventLoading.value;
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              // Panggil metode editEvent dari controller
              // Validasi dan feedback (snackbar, navigasi) ditangani di dalam controller
              await controller.editEvent(docId: docId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Primary.mainColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: semiBold.copyWith(
                fontSize: 16,
                color: Neutral.white1,
              ), // Asumsi style dari constant.dart
            ),
            child: Text(
              "Simpan Perubahan",
              style: semiBold.copyWith(fontSize: 16, color: Neutral.white1),
            ),
          ),
        );
  });
}

// --- Widget Utama EditEventView (StatelessWidget) ---

class EditEventView extends StatelessWidget {
  final Event event;

  const EditEventView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance controller.
    // Pastikan controller sudah diinisialisasi (misalnya melalui Get.put di AppBinding atau halaman sebelumnya).
    final controller = Get.find<ManageTourEventController>();

    // Panggil fillEventForm untuk mengisi data awal ke form.
    // Modifikasi di EventMixin memastikan ini hanya mengisi jika event.id berbeda
    // dengan yang sudah ada di form, atau jika form belum terisi.
    controller.fillEventForm(event);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Event',
          style: semiBold.copyWith(
            // Asumsi style dari constant.dart
            fontSize: ScaleHelper.scaleTextForDevice(
              20,
            ), // Asumsi ScaleHelper dari constant.dart
            color: Neutral.white1, // Asumsi Neutral.white1 dari constant.dart
          ),
        ),
        backgroundColor: Primary.mainColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // Pertimbangkan untuk memanggil controller.clearEventForm() di sini jika
            // Anda ingin form selalu bersih saat pengguna menekan tombol kembali secara manual,
            // sebelum memilih event lain untuk diedit.
            // Jika tidak, _idOfDataInEventForm akan tetap, dan jika pengguna kembali
            // lalu memilih event yang sama, form tidak akan diisi ulang (sesuai logika fillEventForm).
            // controller.clearEventForm(); // Opsional, tergantung behavior yang diinginkan
            Get.back();
          },
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Neutral.white1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
        child: Form(
          key: controller.eventFormKey, // eventFormKey dari EventMixin
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditTextInput(
                controller.eventTitleController,
                'Judul Event',
              ),
              const SizedBox(height: 12),
              _buildEditTextArea(
                controller.eventDescriptionController,
                'Deskripsi Event',
              ),
              const SizedBox(height: 12),
              _buildEditTextInput(controller.eventLocationController, 'Lokasi'),
              const SizedBox(height: 12),
              _buildEditPriceInput(
                controller.eventPriceController,
                'Harga Event',
              ),
              const SizedBox(height: 12),
              _buildDatePicker(controller),
              const SizedBox(height: 12),
              _buildEditImageSection(controller),
              const SizedBox(height: 24),
              _buildEditSaveButton(
                controller,
                event.id,
              ), // Menggunakan event.id dari parameter widget
            ],
          ),
        ),
      ),
    );
  }
}
