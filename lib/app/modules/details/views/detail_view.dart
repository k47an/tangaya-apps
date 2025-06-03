import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:carousel_slider/carousel_slider.dart'; // Keep if you still want a carousel for thumbnails, otherwise ListView is fine
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/details/controllers/detail_controller.dart';
import 'package:tangaya_apps/constant/constant.dart'; // Assuming Primary.mainColor and Primary.darkColor are here

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          // The main content will be a CustomScrollView to allow the image to be part of the scroll
          // or a Column with a fixed bottom bar. For simplicity with the image, let's use Column + SingleChildScrollView
          // and a fixed bottomNavigationBar for the booking section.
          return _buildBodyWithFixedBottomBar(context);
        }),
        bottomNavigationBar: Obx(() {
          // Show booking bar only if item is loaded
          if (controller.detailItem.value != null &&
              !controller.isLoading.value) {
            return _buildBookingBar(context, controller.detailItem.value);
          }
          return const SizedBox.shrink(); // Return empty if no item
        }),
      ),
    );
  }

  Widget _buildBodyWithFixedBottomBar(BuildContext context) {
    final item = controller.detailItem.value;
    if (item == null) {
      return const Center(child: Text("Data item tidak tersedia."));
    }

    List<String> imageUrls = [];
    // Hapus deklarasi heroImageUrl lokal di sini, karena kita akan pakai dari controller

    if (item is TourPackage &&
        item.imageUrls != null &&
        item.imageUrls!.isNotEmpty) {
      imageUrls = item.imageUrls!;
    } else if (item is Event && item.imageUrl.isNotEmpty) {
      imageUrls = [item.imageUrl];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bungkus pemanggilan _buildHeroImageWithOverlays dengan Obx
          // dan gunakan controller.activeHeroImageUrl.value
          Obx(
            () => _buildHeroImageWithOverlays(
              context,
              controller.activeHeroImageUrl.value.isNotEmpty
                  ? controller.activeHeroImageUrl.value
                  : "https://via.placeholder.com/600x400?text=Loading...", // Fallback sementara
              item,
            ),
          ),
          _buildImageThumbnails(context, imageUrls, item),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndRating(item),
                const SizedBox(height: 8),
                _buildLocationInfo(item),
                const SizedBox(height: 24),
                _buildDescription(item),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // _buildHeroImageWithOverlays tidak perlu diubah, karena sudah menerima URL
  // dan memiliki ValueKey yang akan membantu Flutter mengenali perubahan.
  Widget _buildHeroImageWithOverlays(
    BuildContext context,
    String imageUrlFromController, // Nama argumen sudah pas
    dynamic item,
  ) {
    // ... (isi _buildHeroImageWithOverlays tetap sama)
    // Pastikan imageUrlFromController yang diterima adalah yang terbaru dari Obx
    print(
      "Building Hero Image with URL: $imageUrlFromController",
    ); // For debugging
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: Image.network(
            // Pastikan ada fallback jika string kosong, meskipun Obx di atas sudah mencoba memberi nilai
            imageUrlFromController.isNotEmpty
                ? imageUrlFromController
                : "https://via.placeholder.com/600x400?text=No+Image+Provided",
            key: ValueKey(
              imageUrlFromController,
            ), // Penting untuk update gambar
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) return child;
              return Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                    color: Primary.mainColor,
                  ),
                ),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
          ),
        ),
        // ... (Overlay buttons tetap sama)
        Positioned(
          top: ScaleHelper.scaleHeightForDevice(10),
          left: ScaleHelper.scaleWidthForDevice(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.70),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ],
    );
  }

  // ... (sisa kode _buildImageThumbnails, _buildTitleAndRating, dll. tetap sama)
  // Pastikan _buildImageThumbnails juga menggunakan Obx untuk merespons controller.activeHeroImageUrl
  // untuk styling thumbnail aktif, yang sepertinya sudah Anda lakukan.
  Widget _buildImageThumbnails(
    BuildContext context,
    List<String> allImageUrls,
    dynamic item,
  ) {
    // Show thumbnails only if there is more than one image
    bool shouldShowThumbnails = allImageUrls.length > 1;
    if (!shouldShowThumbnails) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allImageUrls.length,
        itemBuilder: (context, index) {
          final String thumbnailUrl = allImageUrls[index];
          // Widget thumbnail individual, dibungkus Obx untuk highlight saat aktif
          return Obx(() {
            // <--- Ini sudah benar untuk styling thumbnail
            bool isActive = controller.activeHeroImageUrl.value == thumbnailUrl;
            return InkWell(
              onTap: () {
                controller.changeHeroImage(thumbnailUrl);
              },
              // ... (sisa kode thumbnail tetap sama)
              child: Container(
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isActive
                          ? Border.all(color: Primary.mainColor, width: 2.5)
                          : Border.all(color: Colors.grey.shade300, width: 1.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isActive ? 9.5 : 11.0),
                  child: Image.network(
                    thumbnailUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildTitleAndRating(dynamic item) {
    return Text(
      item.title ?? 'Tanpa Judul',
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Primary.darkColor, // Using your constant
      ),
    );
  }

  Widget _buildLocationInfo(dynamic item) {
    String location = "Desa Saniang Baka";

    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: Colors.grey.shade600, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            location,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Deskripsi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Primary.darkColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (item is TourPackage
                  ? item.description
                  : (item is Event ? item.description : '')) ??
              'Tidak ada deskripsi.',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingBar(BuildContext context, dynamic item) {
    num price = 0;
    String priceSuffix = "";
    if (item is TourPackage) {
      price = item.price ?? 0;
      priceSuffix = ""; // Tidak perlu "/ orang"
    } else if (item is Event) {
      price = item.price ?? 0;
      priceSuffix = ""; // Tidak perlu "/ tiket"
    }

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        bottom: ScaleHelper.scaleHeightForDevice(10),
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.itemType == 'tour' ? "Harga Wisata" : "Harga Event",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                price > 0
                    ? "Rp ${NumberFormat('#,###', 'id_ID').format(price)}$priceSuffix"
                    : "Gratis",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Primary.mainColor,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Primary.mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              if (controller.itemType == 'tour') {
                controller.fetchUnavailableDates();
              }
              showOrderBottomSheet(context);
            },
            child: Text(
              controller.itemType == 'tour' ? "Pesan Wisata" : "Pesan Event",
            ),
          ),
        ],
      ),
    );
  }

  // Your existing _buildTextField and showOrderBottomSheet methods remain largely the same.
  // Make sure their styling is consistent if needed.

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
          // labelText: label, // Consider using hintText only or styled labelText
          floatingLabelBehavior:
              FloatingLabelBehavior
                  .always, // If you want label to always be above
          label: Text(
            label,
            style: TextStyle(color: Primary.mainColor.withOpacity(0.8)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Primary.mainColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  void showOrderBottomSheet(BuildContext context) {
    // Ensure your controller fields are reset or initialized if needed
    // controller.resetFormFields(); // You might need a method like this in your controller

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: ScaleHelper.scaleHeightForDevice(20),
          ),
          decoration: const BoxDecoration(
            color:
                Colors.white, // Or a slightly off-white like Color(0xFFF9F9F9)
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            // Important for keyboard
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
                Obx(
                  () =>
                      controller.peopleCount.value > 20
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                "Maksimal 20 orang diperbolehkan.",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                          : controller.peopleCount.value > 0
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.peopleCount.value > 1) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Nama Peserta:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...List.generate(controller.peopleCount.value, (
                                  i,
                                ) {
                                  while (i >= controller.peopleNames.length) {
                                    controller.peopleNames.add(
                                      TextEditingController(),
                                    );
                                  }
                                  return _buildTextField(
                                    controller.peopleNames[i],
                                    "Nama Orang ke-${i + 1}",
                                  );
                                }),
                              ],
                            ],
                          )
                          : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),
                if (controller.itemType == 'tour') ...[
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
                          // Optional: Theme the date picker
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary:
                                    Primary
                                        .mainColor, // header background color
                                onPrimary: Colors.white, // header text color
                                onSurface: Primary.darkColor, // body text color
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Primary.mainColor, // button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        controller.selectedDate.value = picked;
                        controller.selectedDateFormatted.value = DateFormat(
                          'dd MMMM yyyy', // Changed format
                          'id_ID',
                        ).format(picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: Obx(
                        () => _buildTextField(
                          TextEditingController(
                            text:
                                controller
                                        .selectedDateFormatted
                                        .value
                                        .isNotEmpty
                                    ? controller.selectedDateFormatted.value
                                    : "Pilih tanggal", // Placeholder
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Primary.darkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Container(
                      // Added container for better visual grouping
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        controller.detailItem.value?.eventDate != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID').format(
                              controller
                                  .detailItem
                                  .value!
                                  .eventDate, // Langsung gunakan jika sudah DateTime
                            )
                            : 'Tanggal belum ditentukan',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Primary.darkColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 10), // Adjusted spacing
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
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed:
                          controller.isOrdering.value
                              ? null
                              : controller
                                  .submitOrder, // Make sure this method exists and is correct
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
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true, // Very important for keyboard handling
      shape: const RoundedRectangleBorder(
        // Consistent rounded corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  Widget _buildBottomSheetTitle() {
    return Text(
      controller.itemType == 'tour'
          ? "Form Pemesanan Paket Wisata" // More descriptive
          : "Form Pendaftaran Event",
      style: const TextStyle(
        fontSize: 22, // Slightly larger
        fontWeight: FontWeight.bold,
        color: Primary.darkColor,
      ),
    );
  }
}
