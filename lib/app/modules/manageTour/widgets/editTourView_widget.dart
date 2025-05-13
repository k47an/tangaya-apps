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
    final controller = Get.find<ManageTourController>();

    // Set initial values to the controller's reactive variables
    controller.title.value = initialTitle;
    controller.descriptionController.text = initialDescription;
    controller.price.value = initialPrice;
    controller.selectedImages.clear(); // Reset selected images
    controller.imagesToDelete.clear(); // Clear images to be deleted

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
        child: Obx(() {
          return Form(
            key: controller.formKey,
            child: ListView(
              children: [
                _buildTextInputField(
                  controller.title.value,
                  'Title',
                  (value) => controller.title.value = value,
                ),
                const SizedBox(height: 12),
                _buildTextInputField(
                  controller.price.value.toString(),
                  'Price',
                  (value) =>
                      controller.price.value = double.tryParse(value) ?? 0,
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _buildDescriptionField(controller),
                const SizedBox(height: 12),
                _buildImageSection(controller),
                const SizedBox(height: 16),
                _buildSaveButton(controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Get.back(),
      ),
      iconTheme: const IconThemeData(color: Neutral.white1),
      title: Text(
        'Edit Tour Package',
        style: semiBold.copyWith(
          fontSize: ScaleHelper.scaleTextForDevice(20),
          color: Neutral.white1,
        ),
      ),
      centerTitle: true,
      backgroundColor: Primary.mainColor,
    );
  }

  Widget _buildTextInputField(
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
        if (value == null || value.isEmpty) return '$label cannot be empty';
        if (isNumber && double.tryParse(value) == null)
          return 'Enter a valid number';
        return null;
      },
    );
  }

  Widget _buildDescriptionField(ManageTourController controller) {
    return TextField(
      controller: controller.descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: TextStyle(color: Primary.mainColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
      ),
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildImageSection(ManageTourController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Show initial image URLs
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var url in initialImageUrls)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        controller.imagesToDelete.add(url);
                        initialImageUrls.remove(url);
                        controller.selectedImages.refresh();
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Show picked new images
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var image in controller.selectedImages)
              if (image != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.selectedImages.remove(image);
                        },
                      ),
                    ),
                  ],
                ),
          ],
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
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
    );
  }

  Widget _buildSaveButton(ManageTourController controller) {
    return ElevatedButton(
      onPressed:
          controller.isLoading.value
              ? null
              : () async {
                if (controller.formKey.currentState?.validate() ?? false) {
                  await controller.editTourPackage(
                    docId: docId,
                    newTitle: controller.title.value,
                    newDescription: controller.descriptionController.text,
                    newPrice: controller.price.value,
                    oldImageUrls: initialImageUrls,
                    newImageFiles: controller.selectedImages,
                    imagesToDelete: controller.imagesToDelete,
                    initialTitle: '',
                  );

                  controller.selectedImages.clear();
                  controller.imagesToDelete.clear();

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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text('Save Changes', style: TextStyle(fontSize: 16)),
          if (controller.isLoading.value)
            const Positioned(
              child: CircularProgressIndicator(color: Neutral.white1),
            ),
        ],
      ),
    );
  }
}
