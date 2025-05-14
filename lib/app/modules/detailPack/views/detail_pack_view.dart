import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_pack_controller.dart';

class DetailPackView extends GetView<DetailPackController> {
  const DetailPackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Paket Wisata")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              controller.package['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(controller.package['description'] ?? ''),
            const SizedBox(height: 20),
            Text("Harga: Rp${controller.package['price'] ?? '0'}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showOrderBottomSheet(context),
              child: const Text("Pesan Paket"),
            ),
          ],
        );
      }),
    );
  }

  void showOrderBottomSheet(BuildContext context) {
    controller.fetchUnavailableDates();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Form Pemesanan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildTextField(controller.nameC, "Nama Lengkap"),
                _buildTextField(controller.phoneC, "Nomor Telepon"),
                _buildTextField(controller.addressC, "Alamat"),

                const SizedBox(height: 16),
                const Text("Jumlah Orang"),
                const SizedBox(height: 4),
                TextField(
                  controller: controller.peopleC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan jumlah orang',
                  ),
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 0;
                    controller.setPeopleCount(count);
                  },
                ),

                const SizedBox(height: 12),
                ...List.generate(controller.peopleCount.value, (i) {
                  return _buildTextField(
                    controller.peopleNames[i],
                    "Nama Orang ke-${i + 1}",
                  );
                }),

                const SizedBox(height: 16),
                const Text("Pilih Tanggal"),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      selectableDayPredicate: (date) {
                        return !controller.unavailableDates.any(
                          (d) =>
                              d.year == date.year &&
                              d.month == date.month &&
                              d.day == date.day,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.selectedDate = picked;
                      controller.dateC.text = DateFormat(
                        'dd MMMM yyyy',
                      ).format(picked);
                    }
                  },
                  child: IgnorePointer(
                    child: _buildTextField(controller.dateC, "Tanggal"),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        controller.isOrdering.value
                            ? null
                            : controller.submitOrder,
                    child:
                        controller.isOrdering.value
                            ? const CircularProgressIndicator()
                            : const Text("Kirim Pemesanan"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
