import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/modules/manageTour/controllers/manage_tour_controller.dart';
import 'package:tangaya_apps/app/modules/manageTour/views/manage_tour_view.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EditTourView extends StatelessWidget {
  final String docId;
  final String initialTitle;
  final String initialDescription;
  final double initialPrice;
  final List<String> initialImageUrls;

  EditTourView({
    required this.docId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialImageUrls,
  });

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ManageTourController());
    final controller = Get.find<ManageTourController>();

    controller.title.value = initialTitle;
    controller.descriptionController.text = initialDescription;
    controller.price.value = initialPrice;
    controller.selectedImages.value = [];

    controller.selectedImages.addAll(
      initialImageUrls.map((url) => null).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        iconTheme: const IconThemeData(color: Neutral.white1),
        title: Text(
          'Edit Tour Package',
          style: semiBold.copyWith(
            fontSize: ScaleHelper(context).scaleTextForDevice(20),
            color: Neutral.white1,
          ),
        ),
        centerTitle: true,
        backgroundColor: Primary.mainColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(ScaleHelper(context).scaleWidthForDevice(16)),
        child: Obx(() {
          return Form(
            key: controller.formKey,
            child: ListView(
              children: [
                _buildTextInput(controller.title.value, 'Title', (value) {
                  controller.title.value = value;
                }),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    labelStyle: TextStyle(color: Primary.mainColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Primary.mainColor),
                    ),
                  ),
                  maxLines: 5, // Pastikan maxLines lebih dari 1
                  keyboardType: TextInputType.multiline,
                  textInputAction:
                      TextInputAction
                          .newline, // Membuka newline saat tekan Enter
                ),

                const SizedBox(height: 12),
                _buildTextInput(controller.price.value.toString(), 'Price', (
                  value,
                ) {
                  controller.price.value = double.tryParse(value) ?? 0;
                }, isNumber: true),
                const SizedBox(height: 12),
                _buildImagePicker(controller),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : () async {
                              if (controller.formKey.currentState?.validate() ??
                                  false) {
                                final title = controller.title.value;
                                final description =
                                    controller.descriptionController.text;
                                final price = controller.price.value;

                                await controller.editTourPackage(
                                  docId,
                                  title,
                                  description,
                                  price,
                                  initialImageUrls,
                                  controller.selectedImages,
                                );
                                controller.titleController.clear();
                                controller.descriptionController.clear();
                                controller.priceController.clear();
                                controller.selectedImages.clear();
                                Get.snackbar(
                                  'Success',
                                  'Tour package updated successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                );

                                Get.offAll(() => ManageTourView());
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Primary.subtleColor,
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text('Save Changes', style: TextStyle(fontSize: 16)),
                        if (controller.isLoading.value)
                          Positioned(
                            child: CircularProgressIndicator(
                              color: Neutral.white1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Helper method to build text input fields
  Widget _buildTextInput(
    String initialValue,
    String label,
    Function(String) onChanged, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Primary.mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label cannot be empty';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  // Membuat bagian untuk memilih gambar dengan tampilan grid
  // Image Picker section
  Widget _buildImagePicker(ManageTourController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              for (var imageUrl in initialImageUrls)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              for (var imageFile in controller.selectedImages)
                if (imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              final XFile? image = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                controller.selectedImages.add(File(image.path));
              }
            },
            icon: const Icon(Icons.image),
            label: const Text('Pick Images'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Primary.mainColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
