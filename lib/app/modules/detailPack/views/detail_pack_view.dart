import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';
import '../controllers/detail_pack_controller.dart';

class DetailPackView extends StatelessWidget {
  const DetailPackView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetailPackController());
    final auth = Get.find<AuthController>();

    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final addressC = TextEditingController();
    final peopleC = TextEditingController();
    final dateC = TextEditingController();
    DateTime? selectedDate;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Detail Paket Wisata',
          style: bold.copyWith(
            fontSize: ScaleHelper(context).scaleTextForDevice(20),
            color: Primary.darkColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.data;
        final imageUrls = List<String>.from(data['imageUrls'] ?? []);
        final title = data['title'] ?? '';
        final price = data['price'] ?? 0;
        final description = data['description'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.5, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrls.isNotEmpty)
                  Container(
                    height: 252,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrls.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: semiBold.copyWith(
                              fontSize: 16,
                              color: Neutral.dark1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Rp ${NumberFormat('#,###').format(price)}",
                            style: medium.copyWith(
                              fontSize: 14,
                              color: Primary.mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        nameC.text = auth.firestoreUserName.value;
                        phoneC.text = auth.userPhone.value;
                        addressC.text = auth.userAddress.value;

                        _showOrderBottomSheet(
                          context,
                          controller,
                          nameC,
                          phoneC,
                          addressC,
                          peopleC,
                          dateC,
                          () => selectedDate,
                          (picked) => selectedDate = picked,
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "Pesan",
                            style: medium.copyWith(
                              fontSize: 20,
                              color: Primary.mainColor,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_right_rounded,
                            color: Primary.mainColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: regular.copyWith(fontSize: 14, color: Neutral.dark1),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showOrderBottomSheet(
    BuildContext context,
    DetailPackController controller,
    TextEditingController nameC,
    TextEditingController phoneC,
    TextEditingController addressC,
    TextEditingController peopleC,
    TextEditingController dateC,
    DateTime? Function() getSelectedDate,
    void Function(DateTime) setSelectedDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Obx(
                () => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Form Pemesanan",
                        style: bold.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameC,
                        decoration: const InputDecoration(labelText: "Nama"),
                      ),
                      TextField(
                        controller: phoneC,
                        decoration: const InputDecoration(labelText: "No. HP"),
                        keyboardType: TextInputType.phone,
                      ),
                      TextField(
                        controller: addressC,
                        decoration: const InputDecoration(labelText: "Alamat"),
                      ),
                      TextField(
                        controller: peopleC,
                        decoration: const InputDecoration(
                          labelText: "Jumlah Orang",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final count = int.tryParse(value) ?? 0;
                          setState(() {
                            controller.setPeopleCount(count);
                          });
                        },
                      ),
                      TextField(
                        controller: dateC,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Tanggal Pemesanan",
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setSelectedDate(picked);
                            dateC.text = DateFormat(
                              'dd MMM yyyy',
                            ).format(picked);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: List.generate(controller.peopleCount.value, (
                          i,
                        ) {
                          if (i >= controller.peopleNames.length) {
                            controller.peopleNames.add(TextEditingController());
                          }
                          return TextField(
                            controller: controller.peopleNames[i],
                            decoration: InputDecoration(
                              labelText: "Nama Orang ${i + 1}",
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            controller.isOrdering.value
                                ? null
                                : () {
                                  final selectedDate = getSelectedDate();
                                  controller.packageOrder(
                                    customerName: nameC.text,
                                    phone: phoneC.text,
                                    address: addressC.text,
                                    peopleCount:
                                        int.tryParse(peopleC.text) ?? 0,
                                    date: selectedDate,
                                    peopleNames:
                                        controller.peopleNames
                                            .map((c) => c.text)
                                            .toList(),
                                  );
                                },
                        child:
                            controller.isOrdering.value
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text("Kirim"),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
