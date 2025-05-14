import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/views/manage_tour_event_view.dart';
import 'package:tangaya_apps/constant/constant.dart';

class AddTourPackageView extends StatelessWidget {
  const AddTourPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourEventController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Tambah Paket Wisata",
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(20),
            color: Neutral.white1,
          ),
        ),
        backgroundColor: Primary.mainColor,
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
              children: [
                _buildTextInput(
                  controller.tourPackageTitleController,
                  'Judul',
                ), // Menggunakan controller dari TourMixin
                const SizedBox(height: 12),
                _buildDescriptionInput(controller),
                const SizedBox(height: 12),
                _buildTextInput(
                  controller
                      .tourPackagePriceController, // Menggunakan controller dari TourMixin
                  'Harga',
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _buildImagePicker(controller),
                const SizedBox(height: 20),
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
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Wajib diisi';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'Masukkan angka valid';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionInput(ManageTourEventController controller) {
    return TextFormField(
      controller:
          controller
              .tourPackageDescriptionController, // Menggunakan controller dari TourMixin
      decoration: InputDecoration(
        labelText: 'Deskripsi',
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
    );
  }

  Widget _buildImagePicker(ManageTourEventController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final pickedFiles = await ImagePicker().pickMultiImage();
              if (pickedFiles.isNotEmpty) {
                controller.selectedTourPackageImages.addAll(
                  // Menggunakan selectedTourPackageImages dari TourMixin
                  pickedFiles.map((file) => File(file.path)),
                );
              }
            },
            icon: const Icon(Icons.image),
            label: const Text("Pilih Gambar"),
            style: ElevatedButton.styleFrom(backgroundColor: Neutral.white1),
          ),
          const SizedBox(height: 10),
          if (controller.selectedTourPackageImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  controller
                      .selectedTourPackageImages
                      .length, // Menggunakan selectedTourPackageImages dari TourMixin
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final imageFile =
                    controller
                        .selectedTourPackageImages[index]; // Menggunakan selectedTourPackageImages dari TourMixin
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        imageFile!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.selectedTourPackageImages.removeAt(
                            index,
                          ); // Menggunakan selectedTourPackageImages dari TourMixin
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      );
    });
  }

  Widget _buildSaveButton(ManageTourEventController controller) {
    return Obx(
      () =>
          controller
                  .isTourLoading
                  .value // Menggunakan isLoading dari TourMixin (karena addTourPackage ada di TourMixin)
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Primary.subtleColor,
                  ),
                  onPressed: () async {
                    if (controller.tourPackageFormKey.currentState!
                            .validate() &&
                        controller.selectedTourPackageImages.isNotEmpty) {
                      await controller.addTourPackage();
                      Get.snackbar(
                        'Berhasil',
                        'Paket wisata berhasil ditambahkan',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                      controller.clearTourPackageForm();
                      controller.fetchTourPackages();
                      Get.off(() => const ManageTourEventView());
                    } else {
                      Get.snackbar(
                        'Error',
                        'Pastikan semua field dan minimal satu gambar sudah diisi!',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),
    );
  }
}
