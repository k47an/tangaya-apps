// detail_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/data/services/order_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/mixin/tour_mixin.dart';

class DetailController extends GetxController with TourMixin {
  final isLoading = false.obs;
  final isOrdering = false.obs;

  final Rx<dynamic> detailItem = Rx<dynamic>(null);
  final String itemType = Get.arguments['type'];
  final String itemId = Get.arguments['id'];
  final unavailableDates = <DateTime>[].obs;

  final authController = Get.find<AuthController>();
  late final OrderService orderService;
  // Inisialisasi dengan string kosong sudah OK, akan diisi oleh initializeActiveHeroImage
  final RxString activeHeroImageUrl = "".obs;

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final peopleC = TextEditingController();
  final dateC = TextEditingController(); // Tidak terpakai di view, tapi ada di controller
  final selectedDate = Rx<DateTime?>(null);
  final selectedDateFormatted = ''.obs;

  final peopleCount = 0.obs;
  final peopleNames = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    orderService =
        Get.isRegistered<OrderService>()
            ? Get.find<OrderService>()
            : OrderService();

    print("DetailController onInit: Type: $itemType, ID: $itemId"); // Debugging
    fetchDetail();
    if (authController.user != null) {
      nameC.text = authController.userName;
      phoneC.text = authController.userPhone;
      addressC.text = authController.userAddress;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    peopleC.dispose();
    dateC.dispose();
    for (var c in peopleNames) {
      c.dispose();
    }
    super.onClose();
  }

  void initializeActiveHeroImage() {
    print("initializeActiveHeroImage: Called. detailItem is ${detailItem.value == null ? 'null' : 'NOT null'}"); // Debugging
    String newUrl = "https://via.placeholder.com/600x400?text=No+Image"; // Default placeholder

    if (detailItem.value != null) {
      final item = detailItem.value;
      if (item is TourPackage &&
          item.imageUrls != null &&
          item.imageUrls!.isNotEmpty) {
        newUrl = item.imageUrls!.first;
      } else if (item is Event && item.imageUrl.isNotEmpty) {
        newUrl = item.imageUrl;
      }
      // Jika item ada tapi tidak ada gambar spesifik, newUrl akan tetap "No+Image" dari default di atas.
    } else {
      // Jika detailItem null (misal gagal fetch), gunakan placeholder yang berbeda
      newUrl = "https://via.placeholder.com/600x400?text=Item+Not+Available";
    }
    activeHeroImageUrl.value = newUrl;
    print("initializeActiveHeroImage: Set activeHeroImageUrl to: ${activeHeroImageUrl.value}"); // Debugging
  }

  void changeHeroImage(String newUrl) {
    activeHeroImageUrl.value = newUrl;
    print("changeHeroImage: Set activeHeroImageUrl to: ${activeHeroImageUrl.value}"); // Debugging
  }

  void setPeopleCount(int count) {
    // ... (logika setPeopleCount Anda)
     final newCount = count < 0 ? 0 : count;
    peopleCount.value = newCount;
    while (peopleNames.length < newCount) {
      peopleNames.add(TextEditingController());
    }
    if (peopleNames.length > newCount) {
      final toRemove = peopleNames.sublist(newCount);
      for (var c in toRemove) {
        c.dispose();
      }
      peopleNames.removeRange(newCount, peopleNames.length);
    }
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    // Tidak perlu mereset activeHeroImageUrl di sini, biarkan nilai awal ""
    // atau nilai dari pemanggilan sebelumnya jika ada re-fetch.
    // initializeActiveHeroImage akan menimpanya.
    print("fetchDetail: Started. isLoading: ${isLoading.value}"); // Debugging
    try {
      dynamic fetchedData; // Temporary variable to hold fetched data
      if (itemType == 'tour') {
        fetchedData = await getPackageById(itemId);
        if (fetchedData == null) {
          Get.snackbar('Error', 'Paket wisata tidak ditemukan.');
        }
      } else if (itemType == 'event') {
        fetchedData = await getEventById(itemId);
        if (fetchedData == null) Get.snackbar('Error', 'Event tidak ditemukan.');
      } else {
        Get.snackbar('Error', 'Tipe item tidak valid.');
      }
      detailItem.value = fetchedData; // Update detailItem

      // PENTING: Panggil initializeActiveHeroImage SETELAH detailItem di-set.
      initializeActiveHeroImage();

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail: $e');
      detailItem.value = null; // Pastikan null jika error
      initializeActiveHeroImage(); // Inisialisasi hero image berdasarkan item yang null
    } finally {
      isLoading.value = false;
      print("fetchDetail: Finished. isLoading: ${isLoading.value}, activeHeroImageUrl: ${activeHeroImageUrl.value}"); // Debugging
    }
  }

  Future<Event?> getEventById(String id) async {
    // ... (implementasi getEventById Anda)
    try {
      final doc =
          await FirebaseFirestore.instance.collection('events').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Event.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching event by ID: $e");
      return null;
    }
  }

  Future<void> fetchUnavailableDates() async {
    // ... (implementasi fetchUnavailableDates Anda)
    // (Sama seperti kode yang Anda berikan sebelumnya)
    if (itemType == 'tour') {
      isLoading.value = true; // Mungkin ingin loading state sendiri untuk ini
      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection("orders")
                .where("itemId", isEqualTo: itemId)
                .where("itemType", isEqualTo: "tour")
                .where(
                  "status",
                  whereIn: [
                    "settlement", "approved", "cod_confirmed_awaiting_delivery",
                    "approved_pending_payment",
                    "approved_awaiting_payment_choice",
                    "payment_initiated_post_approval",
                  ],
                )
                .get();
        unavailableDates.assignAll(
          snapshot.docs
              .map((d) {
                final data = d.data();
                if (data.containsKey('bookingDate') &&
                    data['bookingDate'] is Timestamp) {
                  return (data['bookingDate'] as Timestamp).toDate();
                }
                return null;
              })
              .whereType<DateTime>()
              .toList(),
        );
        print("Unavailable dates for tour $itemId: $unavailableDates");
      } catch (e) {
        print("Gagal mengambil tanggal tidak tersedia untuk tour: $e");
        Get.snackbar('Error', 'Gagal memuat tanggal tidak tersedia.');
      } finally {
        isLoading.value = false; // Sesuaikan jika ada loading state terpisah
      }
    } else if (itemType == 'event') {
      unavailableDates.clear();
    }
  }

  void resetForm() {
    // ... (implementasi resetForm Anda)
    peopleC.clear();
    // dateC.clear(); // dateC tidak terikat ke TextField di bottom sheet ini
    selectedDate.value = null;
    selectedDateFormatted.value = '';
    setPeopleCount(0);
  }

  Future<void> submitOrder() async {
    // ... (implementasi submitOrder Anda, sama seperti kode yang diberikan sebelumnya)
    if (nameC.text.isEmpty || phoneC.text.isEmpty || addressC.text.isEmpty) {
      Get.snackbar("Validasi Gagal", "Nama, telepon, dan alamat wajib diisi.");
      return;
    }
    final int currentPeopleCountInput =
        int.tryParse(peopleC.text.isEmpty ? "0" : peopleC.text) ?? 0;
    if (peopleC.text.isNotEmpty && currentPeopleCountInput <= 0) {
      Get.snackbar("Validasi Gagal", "Jumlah orang tidak valid.");
      return;
    }
    if (currentPeopleCountInput > 0 && peopleNames.any((c) => c.text.isEmpty)) {
      Get.snackbar("Validasi Gagal", "Harap isi nama semua peserta.");
      return;
    }
    if (itemType == 'tour' && selectedDate.value == null) {
      Get.snackbar("Validasi Gagal", "Harap pilih tanggal untuk paket wisata.");
      return;
    }

    isOrdering.value = true;
    final String newOrderId =
        FirebaseFirestore.instance.collection("orders").doc().id;
    final currentItem = detailItem.value;

    if (currentItem == null) {
      Get.snackbar("Error", "Detail item tidak tersedia. Coba lagi.");
      isOrdering.value = false;
      return;
    }

    final String? userEmailFromAuth = authController.userEmail;
    String customerEmail = '';
    if (userEmailFromAuth == null ||
        userEmailFromAuth.isEmpty ||
        userEmailFromAuth == '-') {
      customerEmail =
          "${phoneC.text.replaceAll(RegExp(r'[^0-9]'), '')}@placeholder.email";
    } else {
      customerEmail = userEmailFromAuth;
    }

    int totalPrice = 0;
    num itemUnitPrice = 0;

    if (itemType == 'tour' && currentItem is TourPackage) {
      itemUnitPrice = currentItem.price ?? 0;
      totalPrice = itemUnitPrice.toInt(); // Simplifikasi, asumsikan harga per paket, bukan per orang
    } else if (itemType == 'event' && currentItem is Event) {
      itemUnitPrice = currentItem.price ?? 0;
      totalPrice = itemUnitPrice.toInt();
    } else {
      Get.snackbar("Error Item", "Tipe item tidak dikenal untuk pemesanan.");
      isOrdering.value = false;
      return;
    }
     if (itemUnitPrice < 0) { // Validasi harga negatif
      Get.snackbar("Error Harga", "Harga item tidak valid.");
      isOrdering.value = false;
      return;
    }


    print("DEBUG: submitOrder - Calculated totalPrice = $totalPrice");

    try {
      List<String> namesList =
          currentPeopleCountInput > 0
              ? peopleNames.map((c) => c.text).toList()
              : [];

      await orderService.saveOrderToFirestore(
        orderId: newOrderId,
        paymentStatus: "pending_approval",
        snapToken: null,
        paymentMethodType: null,
        totalPrice: totalPrice,
        customerName: nameC.text,
        customerEmail: customerEmail,
        customerPhone: phoneC.text,
        customerAddress: addressC.text,
        peopleCountText: peopleC.text, // Ini adalah string dari TextField
        detailItemValue: currentItem,
        itemType: itemType,
        itemId: itemId,
        selectedDateValue: itemType == 'tour' ? selectedDate.value : null,
        peopleNamesValues: namesList,
        isUpdate: false,
      );
      Get.back();
      Get.snackbar(
        "Sukses",
        "Pemesanan berhasil dikirim dan menunggu persetujuan admin.",
      );
      resetForm();
    } catch (e, stackTrace) {
      Get.snackbar(
        "Error Pesanan",
        "Terjadi kesalahan saat memproses pesanan: $e",
      );
      print("ERROR submitOrder: $e");
      print("STACKTRACE submitOrder: $stackTrace");
    } finally {
      isOrdering.value = false;
    }
  }

  @override
  Future<TourPackage?> getPackageById(String id) async {
    return await super.getPackageById(id);
  }
}