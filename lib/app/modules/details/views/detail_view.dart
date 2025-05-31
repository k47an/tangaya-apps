// detail_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
        if (controller.detailItem.value == null &&
            !controller.isLoading.value) {
          return const Center(
            child: Text("Detail item tidak ditemukan atau gagal dimuat."),
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
      return const Center(child: Text("Data item tidak tersedia."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemImage(item),
          const SizedBox(height: 16),
          Text(
            item.title ?? 'Tanpa Judul',
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
            (item is TourPackage
                    ? item.description
                    : (item is Event ? item.description : '')) ??
                'Tidak ada deskripsi.',
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
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildItemPriceLocation(dynamic item) {
    if (item is TourPackage) {
      return Text(
        "Rp ${NumberFormat('#,###', 'id_ID').format(item.price ?? 0)} / orang",
        style: TextStyle(
          fontSize: 20,
          color: Primary.mainColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (item is Event) {
      String eventDisplay = "";
      num price = item.price ?? 0;
      if (price > 0) {
        eventDisplay = "Rp ${NumberFormat('#,###', 'id_ID').format(price)}";
        if (item.location.isNotEmpty) eventDisplay += " - ${item.location}";
      } else if (item.location.isNotEmpty) {
        eventDisplay = item.location;
      } else {
        eventDisplay = "Detail event";
      }
      return Text(
        eventDisplay,
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
        onPressed: () {
          if (controller.itemType == 'tour') {
            controller.fetchUnavailableDates();
          }
          showOrderBottomSheet(context);
        },
        child: Text(
          controller.itemType == 'tour' ? "Pesan Paket Ini" : "Ikuti Event Ini",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController tc,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: tc,
        decoration: InputDecoration(
          hintText: label,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  void showOrderBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetTitle(),
              const SizedBox(height: 16),
              _buildTextField(controller.nameC, "Nama Lengkap"),
              _buildTextField(
                controller.phoneC,
                "Nomor Telepon",
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(controller.addressC, "Alamat"),
              const SizedBox(height: 16),
              const Text(
                "Jumlah Orang",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller.peopleC,
                "Masukkan jumlah orang",
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final count = int.tryParse(value) ?? 0;
                  controller.setPeopleCount(count);
                },
              ),
              const SizedBox(height: 10),
              Obx(
                () =>
                    controller.peopleCount.value > 0
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nama Peserta:",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(controller.peopleCount.value, (i) {
                              if (i < controller.peopleNames.length) {
                                return _buildTextField(
                                  controller.peopleNames[i],
                                  "Nama Orang ke-${i + 1}",
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              if (controller.itemType == 'tour') ...[
                const Text(
                  "Pilih Tanggal Booking",
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
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      selectableDayPredicate:
                          (date) =>
                              !controller.unavailableDates.any(
                                (d) => DateUtils.isSameDay(d, date),
                              ),
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
                      () => _buildTextField(
                        TextEditingController(
                          text: controller.selectedDateFormatted.value,
                        ),
                        "Tanggal Booking",
                        readOnly: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (controller.itemType == 'event') ...[
                const Text(
                  "Tanggal Event",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    controller.detailItem.value?.eventDate != null
                        ? DateFormat('dd MMMM yyyy', 'id_ID').format(
                          (controller.detailItem.value!.eventDate as Timestamp)
                              .toDate(),
                        )
                        : 'Tanggal belum ditentukan',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // BAGIAN PEMILIHAN METODE PEMBAYARAN DIHAPUS DARI SINI
              // const Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.w500)),
              // Obx(() => Column(children: [ ... RadioListTiles ... ])),
              const SizedBox(height: 24), // Sesuaikan spacing jika perlu

              SizedBox(
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
                    ),
                    onPressed:
                        controller.isOrdering.value
                            ? null
                            : controller.submitOrder,
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
