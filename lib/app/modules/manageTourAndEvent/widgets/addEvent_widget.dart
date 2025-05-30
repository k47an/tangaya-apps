import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class AddEventView extends StatelessWidget {
  const AddEventView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourEventController>();
    // Bersihkan form setiap kali view ini dibuat (misalnya saat navigasi baru)
    // Namun, jika Anda ingin mempertahankan state saat kembali (misalnya dari pick image),
    // pembersihan ini lebih baik dilakukan saat navigasi keluar atau sukses.
    // Untuk form tambah, biasanya lebih baik bersih saat masuk.
    // controller.clearEventForm(); // Pertimbangkan penempatan ini

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
          onPressed: () {
            controller.clearEventForm(); // Bersihkan form saat kembali manual
            Get.back();
          },
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
                _buildPriceInput(
                  // <-- Tambahkan input harga
                  controller.eventPriceController,
                  'Harga Event',
                ),
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
          (value) =>
              value == null || value.isEmpty ? '$label wajib diisi' : null,
    );
  }

  Widget _buildPriceInput(TextEditingController controller, String label) {
    // <-- Widget baru untuk harga
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Kosongkan jika gratis',
        labelStyle: TextStyle(color: Primary.mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
        prefixText: 'Rp ', // Opsional: tambahkan prefix Rupiah
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: false,
      ), // Ubah ke false jika tidak perlu desimal
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
          Text(
            "Gambar Event:",
            style: regular.copyWith(fontSize: 12, color: Neutral.dark2),
          ),
          const SizedBox(height: 4),
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
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.delete, color: Colors.white, size: 20),
                    ),
                    onPressed: () => controller.selectedEventImage.value = null,
                  ),
                ),
              ],
            )
          else
            InkWell(
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
            ),
          if (imageFile != null) // Tombol ganti gambar jika sudah ada gambar
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                onPressed: () async => await controller.pickEventImage(),
                icon: const Icon(Icons.edit),
                label: const Text("Ganti Gambar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
              ),
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
                // Logika validasi, penambahan event, snackbar, dan navigasi
                // sekarang sepenuhnya ditangani oleh controller.addEvent()
                await controller.addEvent();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Primary.mainColor, // Ubah warna agar konsisten
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: semiBold.copyWith(
                  fontSize: 16,
                  color: Neutral.white1,
                ),
              ),
              child: Text(
                "Simpan",
                style: semiBold.copyWith(fontSize: 16, color: Neutral.white1),
              ),
            ),
          );
    });
  }
}
