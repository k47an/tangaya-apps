import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/utils/helper/formater_price.dart';

class UpsertEventView extends StatelessWidget {
  final Event? event;
  const UpsertEventView({super.key, this.event});

  bool get isEditMode => event != null;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManageTourEventController>();
    final String appBarTitle = isEditMode ? "Edit Event" : "Tambah Event";
    final String buttonTitle = isEditMode ? "Simpan Perubahan" : "Simpan Event";

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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.eventFormKey,
            child: ListView(
              children: [
                _buildTextField(controller.eventTitleController, 'Judul Event'),
                _buildTextField(
                  controller.eventDescriptionController,
                  'Deskripsi',
                  maxLines: 5,
                ),
                _buildTextField(controller.eventLocationController, 'Lokasi'),
                _buildTextField(
                  controller.eventPriceController,
                  'Harga (kosongkan jika gratis)',
                  isNumber: true,
                  prefixText: 'Rp ',
                ),
                _buildDatePicker(context, controller),
                const SizedBox(height: 16),
                _buildImagePicker(controller),
                const SizedBox(height: 24),
                Obx(
                  () =>
                      controller.isEventLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                            // Menggunakan SizedBox untuk styling yang konsisten
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
                                  controller.editEvent(docId: event!.id);
                                } else {
                                  controller.addEvent();
                                }
                              },
                              child: Text(buttonTitle),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String label, {
    int maxLines = 1,
    bool isNumber = false,
    String? prefixText,
  }) {
    final List<TextInputFormatter> inputFormatters = [];
    final bool isPriceField = label.toLowerCase().contains('harga');

    if (isNumber) {
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
      if (isPriceField) {
        inputFormatters.add(ThousandsSeparatorInputFormatter());
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: textController,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            // Harga boleh kosong
            if (isPriceField) return null;
            return '$label wajib diisi.';
          }

          if (isNumber && isPriceField) {
            final numericValue = value.replaceAll('.', '');
            if (numericValue.isNotEmpty &&
                double.tryParse(numericValue) == null) {
              return 'Masukkan format angka yang valid.';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    ManageTourEventController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: controller.selectedEventDate.value ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            controller.selectedEventDate.value = pickedDate;
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Tanggal Event',
            labelStyle: TextStyle(color: Primary.mainColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Primary.mainColor),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Obx(
            () => Text(
              controller.selectedEventDate.value == null
                  ? 'Pilih Tanggal'
                  : DateFormat(
                    'd MMMM yyyy',
                    'id_ID',
                  ).format(controller.selectedEventDate.value!),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ManageTourEventController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gambar Event",
            style: regular.copyWith(
              fontSize: 14,
              color: Neutral.dark1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => controller.pickEventImage(),
            child: Obx(() {
              Widget imagePreview;
              if (controller.selectedEventImage.value != null) {
                imagePreview = Image.file(
                  controller.selectedEventImage.value!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              } else if (controller.currentEventImageUrl.value != null &&
                  controller.currentEventImageUrl.value!.isNotEmpty) {
                imagePreview = Image.network(
                  controller.currentEventImageUrl.value!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              } else {
                imagePreview = Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text("Ketuk untuk memilih gambar"),
                      ],
                    ),
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: imagePreview,
              );
            }),
          ),
        ],
      ),
    );
  }
}
