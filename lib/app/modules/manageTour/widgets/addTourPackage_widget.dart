import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/modules/manageTour/controllers/manage_tour_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/app/modules/manageTour/views/manage_tour_view.dart';

class AddTourPackageView extends StatelessWidget {
  const AddTourPackageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Tambah Paket Wisata",
          style: semiBold.copyWith(
            fontSize: ScaleHelper(context).scaleTextForDevice(20),
            color: Neutral.white1,
          ),
        ),
        backgroundColor: Primary.mainColor,
        iconTheme: const IconThemeData(color: Neutral.white1),
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(ScaleHelper(context).scaleWidthForDevice(16)),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextInput(controller.titleController, 'Judul'),
                const SizedBox(height: 12),
                _buildDescriptionInput(controller),
                const SizedBox(height: 12),
                _buildTextInput(
                  controller.priceController,
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

  Widget _buildDescriptionInput(ManageTourController controller) {
    return TextField(
      controller: controller.descriptionController,
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

  Widget _buildImagePicker(ManageTourController controller) {
    return Obx(() {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final pickedFiles = await ImagePicker().pickMultiImage();
              if (pickedFiles.isNotEmpty) {
                controller.selectedImages.addAll(
                  pickedFiles.map((file) => File(file.path)),
                );
              }
            },
            icon: const Icon(Icons.image),
            label: const Text("Pilih Gambar"),
            style: ElevatedButton.styleFrom(backgroundColor: Neutral.white1),
          ),
          if (controller.selectedImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.selectedImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        controller.selectedImages[index]!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.selectedImages.removeAt(index);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSaveButton(ManageTourController controller) {
    return Obx(
      () =>
          controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Primary.subtleColor,
                ),
                onPressed: () async {
                  if (controller.formKey.currentState!.validate()) {
                    await controller.addTourPackage(
                      title: controller.titleController.text,
                      description: controller.descriptionController.text,
                      price: double.parse(controller.priceController.text),
                      imageFiles: controller.selectedImages,
                    );
                    Get.snackbar(
                      'Berhasil',
                      'Paket wisata berhasil ditambahkan',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    controller.titleController.clear();
                    controller.descriptionController.clear();
                    controller.priceController.clear();
                    controller.selectedImages.clear();
                    Get.off(() => ManageTourView());
                  }
                },
                child: const Text('Simpan', style: TextStyle(fontSize: 16)),
              ),
    );
  }
}
