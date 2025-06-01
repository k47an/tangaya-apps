import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/views/manage_tour_event_view.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EditTourView extends StatefulWidget {
  final String docId;
  final String initialTitle;
  final String initialDescription;
  final double initialPrice;
  final List<String> initialImageUrls;

  const EditTourView({
    super.key,
    required this.docId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialImageUrls,
  });

  @override
  State<EditTourView> createState() => _EditTourViewState();
}

class _EditTourViewState extends State<EditTourView> {
  final controller = Get.find<ManageTourEventController>();

  @override
  void initState() {
    super.initState();
    controller.fillTourPackageForm(
      TourPackage(
        id: widget.docId,
        title: widget.initialTitle,
        description: widget.initialDescription,
        price: widget.initialPrice,
        imageUrls: widget.initialImageUrls,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
        child: Form(
          key: controller.tourPackageFormKey,
          child: ListView(
            children: [
              _buildTextInputField(
                controller.tourPackageTitleController,
                'Title',
              ),
              const SizedBox(height: 12),
              _buildTextInputField(
                controller.tourPackagePriceController,
                'Price',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              _buildDescriptionField(controller),
              const SizedBox(height: 12),
              _buildImageSection(controller, widget.initialImageUrls),
              const SizedBox(height: 16),
              _buildSaveButton(
                controller,
                widget.docId,
                widget.initialImageUrls,
              ),
            ],
          ),
        ),
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
      backgroundColor: Primary.darkColor,
    );
  }

  Widget _buildTextInputField(
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Primary.mainColor),
        ),
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return '$label cannot be empty';
        if (isNumber && double.tryParse(value) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(ManageTourEventController controller) {
    return TextField(
      controller: controller.tourPackageDescriptionController,
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

  Widget _buildImageSection(
    ManageTourEventController controller,
    List<String> initialImageUrls,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
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
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.tourPackageImagesToDelete.add(
                            url,
                          ); // Use the correct property name
                          initialImageUrls.remove(url);
                          controller.currentTourPackageImageUrls.remove(url);
                        },
                      ),
                    ),
                  ],
                ),
              for (var image
                  in controller
                      .selectedTourPackageImages) // Use the correct property name
                if (image != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            controller.selectedTourPackageImages.remove(
                              image,
                            ); // Use the correct property name
                          },
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              controller.selectedTourPackageImages.add(
                File(image.path),
              ); // Use the correct property name
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

  Widget _buildSaveButton(
    ManageTourEventController controller,
    String docId,
    List<String> initialImageUrls,
  ) {
    return Obx(
      () => ElevatedButton(
        onPressed:
            controller.isTourLoading.value
                ? null
                : () async {
                  if (controller.tourPackageFormKey.currentState?.validate() ??
                      false) {
                    await controller.editTourPackage(docId: docId);
                    Get.snackbar(
                      'Success',
                      'Tour package updated successfully',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    Get.offAll(() => ManageTourEventView());
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
            if (controller.isTourLoading.value)
              const Positioned(
                child: CircularProgressIndicator(color: Neutral.white1),
              ),
          ],
        ),
      ),
    );
  }
}
