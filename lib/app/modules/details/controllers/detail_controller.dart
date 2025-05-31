// detail_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/data/services/order_service.dart';
// Path ke service Anda, pastikan sudah benar
// MidtransService tidak lagi digunakan secara langsung di sini untuk membuat token awal
// import 'package:tangaya_apps/app/services/midtrans_service.dart';
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
  // late final MidtransService midtransService; // Tidak diinisiasi/digunakan di sini lagi

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final peopleC = TextEditingController();
  final dateC = TextEditingController();
  final selectedDate = Rx<DateTime?>(null);
  final selectedDateFormatted = ''.obs;

  final peopleCount = 0.obs;
  final peopleNames = <TextEditingController>[].obs;
  // final RxString selectedPaymentMethod = 'cod'.obs; // DIHAPUS: Tidak ada pemilihan metode di sini lagi

  @override
  void onInit() {
    super.onInit();
    orderService =
        Get.isRegistered<OrderService>()
            ? Get.find<OrderService>()
            : OrderService();
    // midtransService = Get.isRegistered<MidtransService>() ? Get.find<MidtransService>() : MidtransService(); // Tidak perlu

    print("Detail Type: $itemType, ID: $itemId");
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

  void setPeopleCount(int count) {
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
    try {
      if (itemType == 'tour') {
        final TourPackage? result = await getPackageById(itemId);
        detailItem.value = result;
        if (result == null)
          Get.snackbar('Error', 'Paket wisata tidak ditemukan.');
      } else if (itemType == 'event') {
        final Event? result = await getEventById(itemId);
        detailItem.value = result;
        if (result == null) Get.snackbar('Error', 'Event tidak ditemukan.');
      } else {
        Get.snackbar('Error', 'Tipe item tidak valid.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Event?> getEventById(String id) async {
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
    if (itemType == 'tour') {
      isLoading.value = true;
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
                    "approved_awaiting_payment_choice", // Tambahkan status relevan
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
        isLoading.value = false;
      }
    } else if (itemType == 'event') {
      unavailableDates.clear();
    }
  }

  void resetForm() {
    peopleC.clear();
    dateC.clear();
    selectedDate.value = null;
    selectedDateFormatted.value = '';
    setPeopleCount(0);
    // selectedPaymentMethod.value = 'cod'; // Tidak ada lagi
  }

  Future<void> submitOrder() async {
    // Validasi Input Dasar
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
    // Tidak ada lagi validasi selectedPaymentMethod.value.isEmpty

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
    // Email tetap penting untuk komunikasi dan mungkin dibutuhkan saat pembayaran nanti
    if (userEmailFromAuth == null ||
        userEmailFromAuth.isEmpty ||
        userEmailFromAuth == '-') {
      // Jika email benar-benar dibutuhkan untuk semua jenis pesanan (bahkan sebelum pembayaran)
      // Anda bisa menampilkan error di sini. Untuk sekarang, kita buat placeholder.
      // Get.snackbar("Info Pengguna", "Email pengguna tidak ditemukan atau tidak valid.");
      // isOrdering.value = false;
      // return;
      customerEmail =
          "${phoneC.text.replaceAll(RegExp(r'[^0-9]'), '')}@placeholder.email";
    } else {
      customerEmail = userEmailFromAuth;
    }

    // Perhitungan Harga
    int totalPrice = 0;
    final int numPeopleForPrice =
        currentPeopleCountInput > 0 ? currentPeopleCountInput : 1;
    num itemUnitPrice = 0;

    if (itemType == 'tour' && currentItem is TourPackage) {
      itemUnitPrice = currentItem.price ?? 0;
      if (itemUnitPrice < 0) {
        Get.snackbar("Error Harga", "Harga paket wisata tidak valid.");
        isOrdering.value = false;
        return;
      }
      totalPrice = (itemUnitPrice * numPeopleForPrice).toInt();
    } else if (itemType == 'event' && currentItem is Event) {
      itemUnitPrice = currentItem.price ?? 0;
      if (itemUnitPrice < 0) {
        Get.snackbar("Error Harga", "Harga event tidak valid.");
        isOrdering.value = false;
        return;
      }
      totalPrice = itemUnitPrice.toInt();
    } else {
      Get.snackbar("Error Item", "Tipe item tidak dikenal untuk pemesanan.");
      isOrdering.value = false;
      return;
    }

    print("DEBUG: submitOrder - Calculated totalPrice = $totalPrice");

    // Proses Pesanan
    try {
      List<String> namesList =
          currentPeopleCountInput > 0
              ? peopleNames.map((c) => c.text).toList()
              : [];

      await orderService.saveOrderToFirestore(
        orderId: newOrderId,
        paymentStatus: "pending_approval", // Status awal, menunggu review admin
        snapToken: null, // Belum ada snapToken
        paymentMethodType: null, // Metode pembayaran belum dipilih
        totalPrice: totalPrice,
        customerName: nameC.text,
        customerEmail: customerEmail,
        customerPhone: phoneC.text,
        customerAddress: addressC.text,
        peopleCountText: peopleC.text,
        detailItemValue: currentItem,
        itemType: itemType,
        itemId: itemId,
        selectedDateValue: itemType == 'tour' ? selectedDate.value : null,
        peopleNamesValues: namesList,
        isUpdate: false,
      );
      Get.back(); // Tutup bottom sheet
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
