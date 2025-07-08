import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/modules/details/controllers/detail_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class BookingFormWidget extends GetView<DetailController> {
  const BookingFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetTitle(),
              const SizedBox(height: 20),
              _buildTextField(controller.nameC, "Nama Lengkap"),
              _buildTextField(
                controller.phoneC,
                "Nomor Telepon",
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(controller.addressC, "Alamat"),
              const SizedBox(height: 12),
              _buildPeopleSection(),
              const SizedBox(height: 16),
              if (controller.itemType == 'tour') ...[
                _buildDatePickerSection(context),
                const SizedBox(height: 24),
              ],
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetTitle() {
    return Text(
      controller.itemType == 'tour'
          ? "Form Pemesanan Paket Wisata"
          : "Form Pendaftaran Event",
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Primary.darkColor,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController tc,
    String label, {
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: tc,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Primary.mainColor.withOpacity(0.8)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Primary.mainColor, width: 1.5),
          ),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jumlah Orang",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Primary.darkColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller.peopleC,
          "Masukkan jumlah orang (maks 20)",
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final count = int.tryParse(value) ?? 0;
            if (count > 20) {
              controller.setPeopleCount(20);
              controller.peopleC.text = '20';
              controller.peopleC.selection = TextSelection.fromPosition(
                const TextPosition(offset: 2),
              );
            } else {
              controller.setPeopleCount(count);
            }
          },
        ),
        Obx(() {
          if (controller.peopleCount.value > 1) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Nama Peserta:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(controller.peopleCount.value, (i) {
                  return _buildTextField(
                    controller.peopleNames[i],
                    "Nama Orang ke-${i + 1}",
                  );
                }),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildDatePickerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Tanggal Booking",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Primary.darkColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  controller.selectedDate.value ??
                  DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              selectableDayPredicate:
                  (date) =>
                      !controller.unavailableDates.any(
                        (d) => DateUtils.isSameDay(d, date),
                      ),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Primary.mainColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.selectedDate.value = picked;
              controller.selectedDateFormatted.value = DateFormat(
                'dd MMMM yyyy',
                'id_ID',
              ).format(picked);
            }
          },
          child: AbsorbPointer(
            child: Obx(
              () => TextField(
                controller: TextEditingController(
                  text:
                      controller.selectedDateFormatted.value.isNotEmpty
                          ? controller.selectedDateFormatted.value
                          : "",
                ),
                decoration: InputDecoration(
                  labelText: 'Tanggal Booking',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Primary.mainColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed:
              controller.isOrdering.value
                  ? null
                  : () => controller.submitOrder(),
          child:
              controller.isOrdering.value
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : Text(
                    controller.itemType == 'tour'
                        ? "Kirim Pemesanan"
                        : "Daftar Event",
                  ),
        ),
      ),
    );
  }
}
