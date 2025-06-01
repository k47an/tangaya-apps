import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk TextInputFormatter jika Anda menggunakannya di _buildTextInput
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/views/manage_tour_event_view.dart';
import 'package:tangaya_apps/constant/constant.dart'; // Pastikan semua konstanta (Primary, Neutral, ScaleHelper, semiBold, regular) ada di sini

class AddTourPackageView extends StatelessWidget {
  const AddTourPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourEventController>();
    // Pertimbangkan untuk memanggil controller.clearTourPackageForm() di sini atau di onInit controller
    // jika Anda ingin form selalu bersih saat halaman ini dibuka.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.clearTourPackageForm();
    // });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // controller.clearTourPackageForm(); // Opsional: Bersihkan form saat kembali manual
            Get.back();
          },
        ),
        title: Text(
          "Tambah Paket Wisata",
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(20),
            color: Neutral.white1,
          ),
        ),
        backgroundColor: Primary.darkColor,
        iconTheme: const IconThemeData(color: Neutral.white1),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
        child: Form(
          key:
              controller
                  .tourPackageFormKey, // Menggunakan formKey dari TourMixin
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Agar label rata kiri
              children: [
                _buildTextInput(
                  controller.tourPackageTitleController,
                  'Judul Paket Wisata',
                ),
                const SizedBox(height: 12),
                _buildDescriptionInput(
                  controller.tourPackageDescriptionController,
                  'Deskripsi',
                ), // Menggunakan controller dari TourMixin
                const SizedBox(height: 12),
                _buildTextInput(
                  controller.tourPackagePriceController,
                  'Harga',
                  isNumber: true,
                  prefixText: 'Rp ', // Tambahkan prefix Rp
                ),
                const SizedBox(
                  height: 16,
                ), // Beri jarak lebih sebelum image picker
                _buildImagePicker(controller), // Image Picker yang dimodifikasi
                const SizedBox(height: 24), // Jarak sebelum tombol simpan
                _buildSaveButton(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool isNumber = false,
    String? prefixText, // Tambahkan parameter prefixText
  }) {
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
        prefixText: prefixText, // Gunakan prefixText di sini
        prefixStyle: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        ), // Style untuk prefix jika perlu
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : [], // Hanya angka untuk tipe number
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label wajib diisi';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'Masukkan angka yang valid';
        }
        if (isNumber && (double.tryParse(value) ?? -1) < 0) {
          return 'Harga tidak boleh negatif';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionInput(
    TextEditingController controller,
    String label,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true, // Agar label sejajar dengan teks di atas
        labelStyle: TextStyle(color: Primary.mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
      ),
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      validator: (value) {
        // Tambahkan validator untuk deskripsi
        if (value == null || value.isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }

  // --- MODIFIKASI _buildImagePicker ---
  Widget _buildImagePicker(ManageTourEventController controller) {
    return Obx(() {
      // Obx untuk mereaksikan perubahan pada selectedTourPackageImages
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gambar Paket Wisata (Minimal 1):",
            // Asumsi 'regular' dan 'Neutral.dark2' ada di constant.dart
            style: regular.copyWith(
              fontSize: 14,
              color: Neutral.dark1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Grid untuk menampilkan gambar yang sudah dipilih
          if (controller.selectedTourPackageImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Agar tidak bisa di-scroll di dalam SingleChildScrollView
              itemCount: controller.selectedTourPackageImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Jumlah gambar per baris
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final imageFile = controller.selectedTourPackageImages[index];
                return Stack(
                  fit:
                      StackFit
                          .expand, // Agar gambar mengisi sel grid dan ikon posisi tepat
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        imageFile!, // selectedTourPackageImages adalah List<File>, bukan List<File?>
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 4, // Posisi ikon hapus
                      right: 4,
                      child: InkWell(
                        // InkWell agar area tap lebih besar
                        onTap: () {
                          controller.selectedTourPackageImages.removeAt(index);
                        },
                        child: CircleAvatar(
                          radius: 12, // Ukuran ikon hapus
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          if (controller.selectedTourPackageImages.isNotEmpty)
            const SizedBox(height: 12), // Jarak jika sudah ada gambar
          // Tombol untuk memilih/menambah gambar
          Center(
            // Tombol ditengah
            child: ElevatedButton.icon(
              onPressed: () async {
                final pickedFiles = await ImagePicker().pickMultiImage(
                  imageQuality: 80, // Opsional: atur kualitas gambar
                );
                // Tidak perlu pickedFiles.isNotEmpty karena addAll akan handle list kosong
                controller.selectedTourPackageImages.addAll(
                  pickedFiles.map((file) => File(file.path)),
                );
              },
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                controller.selectedTourPackageImages.isEmpty
                    ? "Pilih Gambar"
                    : "Tambah Gambar Lain",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Neutral.white2, // Asumsi ada di constant.dart
                foregroundColor: Primary.mainColor, // Warna teks dan ikon
                elevation: 1,
                side: BorderSide(color: Primary.mainColor.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      );
    });
  }
  // --- AKHIR MODIFIKASI _buildImagePicker ---

  Widget _buildSaveButton(ManageTourEventController controller) {
    return Obx(
      () =>
          controller
                  .isTourLoading
                  .value // Menggunakan isTourLoading dari TourMixin
              ? const Center(
                child: CircularProgressIndicator(color: Primary.mainColor),
              )
              : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Primary.mainColor, // Warna utama untuk tombol simpan
                    foregroundColor: Neutral.white1,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    textStyle: semiBold.copyWith(fontSize: 16),
                  ),
                  onPressed: () async {
                    // Panggil validasi dari controller (TourMixin)
                    if (controller.validateTourPackageForm()) {
                      // Asumsi validateTourPackageForm ada di TourMixin
                      await controller.addTourPackage();
                      // kembali ke management view setelah berhasil
                      Get.offAll(() => const ManageTourEventView());
                      // Feedback (snackbar, navigasi) sudah dihandle di dalam addTourPackage()
                    }
                    // Jika validasi gagal, snackbar error akan ditampilkan oleh validateTourPackageForm()
                  },
                  child: const Text(
                    'Simpan Paket Wisata',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
    );
  }
}
