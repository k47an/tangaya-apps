import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class UpsertTourView extends StatelessWidget {
  final TourPackage? tourPackage;

  const UpsertTourView({super.key, this.tourPackage});

  bool get isEditMode => tourPackage != null;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourEventController>();
    final String appBarTitle =
        isEditMode ? "Edit Paket Wisata" : "Tambah Paket Wisata";
    final String buttonTitle =
        isEditMode ? "Simpan Perubahan" : "Simpan Paket Wisata";

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
        ),
        body: Padding(
          padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
          child: Form(
            key: controller.tourPackageFormKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextInput(
                    controller: controller.tourPackageTitleController,
                    label: 'Judul Paket Wisata',
                  ),
                  const SizedBox(height: 12),
                  _buildDescriptionInput(
                    controller: controller.tourPackageDescriptionController,
                    label: 'Deskripsi',
                  ),
                  const SizedBox(height: 12),
                  _buildTextInput(
                    controller: controller.tourPackagePriceController,
                    label: 'Harga',
                    isNumber: true,
                    prefixText: 'Rp ',
                  ),
                  const SizedBox(height: 16),
                  _buildImagePickerSection(controller),
                  const SizedBox(height: 24),
                  Obx(
                    () =>
                        controller.isTourLoading.value
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Primary.mainColor,
                              ),
                            )
                            : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Primary.mainColor,
                                  foregroundColor: Neutral.white1,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  textStyle: semiBold.copyWith(fontSize: 16),
                                ),
                                onPressed: () {
                                  if (isEditMode) {
                                    controller.editTourPackage(
                                      docId: tourPackage!.id!,
                                    );
                                  } else {
                                    controller.addTourPackage();
                                  }
                                },
                                child: Text(
                                  buttonTitle,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    String? prefixText,
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
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.black54, fontSize: 16),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      validator: (value) {
        if (value == null || value.isEmpty) return '$label wajib diisi';
        if (isNumber && double.tryParse(value) == null)
          return 'Masukkan angka yang valid';
        if (isNumber && (double.tryParse(value) ?? -1) < 0)
          return 'Harga tidak boleh negatif';
        return null;
      },
    );
  }

  Widget _buildDescriptionInput({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        labelStyle: TextStyle(color: Primary.mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
      ),
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value == null || value.isEmpty) return '$label wajib diisi';
        return null;
      },
    );
  }

  Widget _buildImagePickerSection(ManageTourEventController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gambar Paket Wisata (Minimal 1):",
            style: regular.copyWith(
              fontSize: 14,
              color: Neutral.dark1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                controller.currentTourPackageImageUrls.length +
                controller.selectedTourPackageImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              bool isNetworkImage =
                  index < controller.currentTourPackageImageUrls.length;

              if (isNetworkImage) {
                final imageUrl = controller.currentTourPackageImageUrls[index];
                return _buildImageTile(
                  imageWidget: Image.network(imageUrl, fit: BoxFit.cover),
                  onDelete: () => controller.markImageToDelete(imageUrl),
                );
              } else {
                final imageIndex =
                    index - controller.currentTourPackageImageUrls.length;
                final imageFile =
                    controller.selectedTourPackageImages[imageIndex];
                return _buildImageTile(
                  imageWidget: Image.file(imageFile, fit: BoxFit.cover),
                  onDelete: () => controller.removeSelectedImage(imageIndex),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                final pickedFiles = await ImagePicker().pickMultiImage(
                  imageQuality: 80,
                );
                controller.addSelectedImages(
                  pickedFiles.map((f) => File(f.path)).toList(),
                );
              },
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text("Tambah Gambar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Neutral.white2,
                foregroundColor: Primary.mainColor,
                elevation: 1,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildImageTile({
    required Widget imageWidget,
    required VoidCallback onDelete,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8.0), child: imageWidget),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onDelete,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black.withOpacity(0.6),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
