// detail_pack_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/details/controllers/detail_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Primary.mainColor),
          );
        }
        return _buildBody(context);
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        controller.itemType == 'tour' ? "Detail Paket Wisata" : "Detail Event",
      ),
      backgroundColor: Primary.mainColor,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBody(BuildContext context) {
    final item = controller.detailItem.value;

    if (item == null) {
      return Center(
        child: Text(
          "${controller.itemType == 'tour' ? 'Paket wisata' : 'Event'} tidak ditemukan.",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemImage(item),
          const SizedBox(height: 16),
          Text(
            item.title ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Primary.darkColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildItemPriceLocation(item),
          const SizedBox(height: 16),
          Text(
            item.description ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          _buildActionButton(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildItemImage(dynamic item) {
    if (item is TourPackage &&
        item.imageUrls != null &&
        item.imageUrls!.isNotEmpty) {
      return _buildImageCarousel(item.imageUrls!);
    }
    if (item is Event && item.imageUrl.isNotEmpty) {
      return _buildEventImage(item.imageUrl);
    }
    return const SizedBox.shrink();
  }

  Widget _buildItemPriceLocation(dynamic item) {
    if (item is TourPackage) {
      return Text(
        "Rp ${NumberFormat('#,###', 'id_ID').format(item.price ?? 0)}",
        style: TextStyle(
          fontSize: 20,
          color: Primary.mainColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (item is Event) {
      return Text(
        item.location,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 16 / 9,
          enlargeCenterPage: true,
          viewportFraction: 0.8,
        ),
        items: imageUrls.map((url) => _buildCarouselItem(url)).toList(),
      ),
    );
  }

  Widget _buildCarouselItem(String url) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => _buildImageErrorWidget(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventImage(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Builder(
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 200,
                errorBuilder:
                    (context, error, stackTrace) => _buildImageErrorWidget(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageErrorWidget() {
    return const Center(
      child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Primary.mainColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => showOrderBottomSheet(context),
        child: Text(
          controller.itemType == 'tour' ? "Pesan Paket Ini" : "Ikuti Event Ini",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        readOnly: readOnly,
        onTap: onTap,
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBottomSheetTitle(),
              const SizedBox(height: 16),
              _buildTextField(controller.nameC, "Nama Lengkap"),
              _buildTextField(controller.phoneC, "Nomor Telepon"),
              _buildTextField(controller.addressC, "Alamat"),
              const SizedBox(height: 16),
              const Text(
                "Jumlah Orang (Opsional)",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.peopleC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Masukkan jumlah orang',
                ),
                onChanged: (value) {
                  final count = int.tryParse(value) ?? 0;
                  controller.setPeopleCount(count);
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () =>
                    controller.peopleCount.value > 0
                        ? Column(
                          children: List.generate(
                            controller.peopleCount.value,
                            (i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildTextField(
                                  controller.peopleNames[i],
                                  "Nama Orang ke-${i + 1}",
                                ),
                              );
                            },
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              if (controller.itemType == 'tour') ...[
                const Text(
                  "Pilih Tanggal",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          controller.selectedDate.value ??
                          DateTime.now().add(const Duration(days: 1)),
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
                      controller.selectedDate.value = picked;
                      controller.selectedDateFormatted.value = DateFormat(
                        'dd-MM-yyyy',
                      ).format(picked);
                      controller.dateC.text =
                          controller.selectedDateFormatted.value;
                    }
                  },
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Obx(
                        () => TextField(
                          key: ValueKey(controller.selectedDateFormatted.value),
                          controller: TextEditingController(
                            text: controller.selectedDateFormatted.value,
                          ),
                          decoration: InputDecoration(
                            hintText: "Tanggal",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (controller.itemType == 'event') ...[
                const SizedBox(height: 24),
                const Text(
                  "Tanggal Event",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    controller.detailItem.value?.eventDate != null
                        ? DateFormat(
                          'dd-MM-yyyy',
                        ).format((controller.detailItem.value!.eventDate))
                        : 'Tanggal belum ditentukan',
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    key: const Key('event_submit_button'), // Key opsional
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Primary.mainColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        controller.isOrdering.value
                            ? null
                            : controller.submitOrder,
                    child:
                        controller.isOrdering.value
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              controller.itemType == 'tour'
                                  ? "Kirim Pemesanan"
                                  : "Daftar Event",
                              style: const TextStyle(fontSize: 18),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomSheetTitle() {
    return Text(
      controller.itemType == 'tour'
          ? "Form Pemesanan"
          : "Form Pendaftaran Event",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Primary.darkColor,
      ),
    );
  }
}
