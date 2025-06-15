import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/booking_model.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart';
import 'package:tangaya_apps/app/data/services/booking_service.dart';
import 'package:tangaya_apps/app/data/services/midtrans_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

class NotificationController extends GetxController {
  // --- DEPENDENSI ---
  final AuthController _authController = Get.find<AuthController>();
  final BookingService _bookingService = Get.find<BookingService>();
  final MidtransService _midtransService = Get.find<MidtransService>();

  // --- STATE UNTUK UI ---
  final RxList<Booking> orders = <Booking>[].obs;
  final RxBool isLoading = true.obs;
  final RxString userRole = ''.obs;

  // Flag tunggal untuk mencegah klik ganda pada aksi apapun
  final RxBool isActionInProgress = false.obs;

  // Variabel untuk menampung stream subscription agar bisa dibatalkan
  StreamSubscription<List<Booking>>? _ordersSubscription;

  @override
  void onInit() {
    super.onInit();
    // Dengarkan perubahan pada role user dari AuthController.
    // 'ever' akan berjalan setiap kali nilai userRole berubah.
    ever(_authController.userRole, (String role) {
      print(
        "NotificationController: Role pengguna berubah -> $role. Memuat ulang data...",
      );
      userRole.value = role;
      fetchOrders();
    });

    // Ambil data pertama kali saat controller diinisialisasi
    userRole.value = _authController.userRole.value;
    fetchOrders();
  }

  @override
  void onClose() {
    // Batalkan listener saat controller dihancurkan untuk mencegah memory leak
    _ordersSubscription?.cancel();
    super.onClose();
  }

  // --- LOGIKA UTAMA ---

  void fetchOrders() {
    final role = userRole.value;
    final uid = _authController.uid;

    // Hentikan jika user tidak punya role, tamu, atau bukan admin tapi tidak punya UID
    if (role.isEmpty || role == 'tamu' || (role != 'admin' && uid.isEmpty)) {
      orders.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _ordersSubscription
        ?.cancel(); // Selalu batalkan listener lama sebelum membuat yang baru

    // Tentukan stream mana yang akan digunakan berdasarkan role
    Stream<List<Booking>> ordersStream =
        (role == 'admin')
            ? _bookingService.getAdminOrdersStream()
            : _bookingService.getUserOrdersStream(uid);

    _ordersSubscription = ordersStream.listen(
      (newOrders) {
        orders.value = newOrders; // Update state dengan data baru
        isLoading.value = false;
      },
      onError: (error) {
        Get.snackbar("Error Data", "Gagal memuat pesanan: $error");
        isLoading.value = false;
      },
    );
  }

  // --- METHOD AKSI (dipanggil dari View) ---

  Future<void> processAdminAction(String orderId, String action) async {
    if (isActionInProgress.value) return;
    isActionInProgress.value = true;

    try {
      String newStatus =
          (action == 'approve')
              ? 'awaiting_payment_choice'
              : 'rejected_by_admin';
      // Panggil service untuk update status
      await _bookingService.updateOrderStatus(orderId, newStatus);
      Get.snackbar(
        "Sukses",
        "Pesanan telah di-${action == 'approve' ? 'setujui' : 'tolak'}.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memproses aksi: $e");
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<void> userSelectsCodPayment(String orderId) async {
    if (isActionInProgress.value) return;
    isActionInProgress.value = true;

    try {
      // Panggil service untuk update status menjadi COD
      await _bookingService.updateOrderStatus(
        orderId,
        'cod_selected',
        paymentMethod: 'cod',
      );
      Get.snackbar(
        "Sukses",
        "Metode pembayaran COD telah dipilih.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memilih metode COD: $e");
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<String?> initiateOnlinePayment(Booking booking) async {
    if (isActionInProgress.value) return null;
    isActionInProgress.value = true;

    try {
      // Panggil service Midtrans untuk membuat transaksi
      final snapToken = await _midtransService.createTransactionForOrder(
        booking,
      );

      if (snapToken != null) {
        // Jika berhasil, update status order dengan snap token
        await _bookingService.updateOrderStatus(
          booking.orderId,
          'midtrans_pending_payment',
          updatedSnapToken: snapToken,
          paymentMethod: 'midtrans_snap',
        );
        return snapToken;
      } else {
        Get.snackbar(
          "Gagal",
          "Gagal mendapatkan token pembayaran dari Midtrans.",
        );
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memulai proses pembayaran: $e");
      return null;
    } finally {
      isActionInProgress.value = false;
    }
  }

  // Method untuk update status berdasarkan hasil dari Midtrans (dipanggil dari view lain)
  Future<void> updateOrderStatusAfterPayment(
    MidtransModel paymentResult,
  ) async {
    try {
      String? finalAppStatus;

      // ================== PERUBAHAN DI SINI ==================
      if (paymentResult.transactionStatus == 'settlement' ||
          paymentResult.transactionStatus == 'capture') {
        finalAppStatus = 'paid';
      } else if (paymentResult.transactionStatus == 'pending') {
        finalAppStatus = 'midtrans_payment_pending';
      } else if (paymentResult.transactionStatus == 'expire' ||
          paymentResult.transactionStatus == 'cancel' ||
          paymentResult.transactionStatus == 'deny') {
        finalAppStatus = 'payment_failed_or_cancelled';
      }
      // Jika user membatalkan atau terjadi error web, kembalikan statusnya
      // agar user bisa memilih metode pembayaran lain.
      else if (paymentResult.transactionStatus == 'cancelled_by_user' ||
          paymentResult.transactionStatus == 'web_error') {
        finalAppStatus = 'awaiting_payment_choice';
      }
      // ========================================================

      if (finalAppStatus != null) {
        await _bookingService.updateOrderStatus(
          paymentResult.orderId,
          finalAppStatus,
          paymentTransactionStatus: paymentResult.transactionStatus,
          paymentStatusCode: paymentResult.statusCode,
        );
        print(
          "Status pesanan ${paymentResult.orderId} diperbarui setelah pembayaran.",
        );
      }
    } catch (e) {
      print("Gagal update status setelah pembayaran: $e");
    }
  }
}
