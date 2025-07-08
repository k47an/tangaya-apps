import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/booking_model.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart';
import 'package:tangaya_apps/app/data/services/booking_service.dart';
import 'package:tangaya_apps/app/data/services/midtrans_service.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/utils/global_components/snackbar.dart';

class NotificationController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final BookingService _bookingService = Get.find<BookingService>();
  final MidtransService _midtransService = Get.find<MidtransService>();

  final RxList<Booking> orders = <Booking>[].obs;
  final RxBool isLoading = true.obs;
  final RxString userRole = ''.obs;
  final RxBool isActionInProgress = false.obs;
  StreamSubscription<List<Booking>>? _ordersSubscription;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.userRole, (String role) {
      debugPrint(
        "NotificationController: Role pengguna berubah -> $role. Memuat ulang data...",
      );
      userRole.value = role;
      fetchOrders();
    });

    userRole.value = _authController.userRole.value;
    fetchOrders();
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

  void fetchOrders() {
    final role = userRole.value;
    final uid = _authController.uid;

    if (role.isEmpty || role == 'tamu' || (role != 'admin' && uid.isEmpty)) {
      orders.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _ordersSubscription?.cancel();

    Stream<List<Booking>> ordersStream =
        (role == 'admin')
            ? _bookingService.getAdminOrdersStream()
            : _bookingService.getUserOrdersStream(uid);

    _ordersSubscription = ordersStream.listen((newOrders) {
      orders.value = newOrders;
      isLoading.value = false;
    });
  }

  Future<void> processAdminAction(String orderId, String action) async {
    if (isActionInProgress.value) return;
    isActionInProgress.value = true;

    try {
      String newStatus =
          (action == 'approve')
              ? 'awaiting_payment_choice'
              : 'rejected_by_admin';
      await _bookingService.updateOrderStatus(orderId, newStatus);
      if (action == 'approve') {
        CustomSnackBar.show(
          context: Get.context!,
          message: "Pesanan telah disetujui.",
          type: SnackBarType.success,
        );
      } else if (action == 'reject') {
        CustomSnackBar.show(
          context: Get.context!,
          message: "Pesanan telah ditolak.",
          type: SnackBarType.error,
        );
      }
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<void> userSelectsCodPayment(String orderId) async {
    if (isActionInProgress.value) return;
    isActionInProgress.value = true;

    try {
      await _bookingService.updateOrderStatus(
        orderId,
        'cod_selected',
        paymentMethod: 'cod',
      );
      CustomSnackBar.show(
        context: Get.context!,
        message: "Metode pembayaran COD telah dipilih.",
        type: SnackBarType.success,
      );
    } catch (e) {
      debugPrint("Gagal memilih metode COD");
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<String?> initiateOnlinePayment(Booking booking) async {
    if (isActionInProgress.value) return null;
    isActionInProgress.value = true;

    try {
      final snapToken = await _midtransService.createTransactionForOrder(
        booking,
      );

      if (snapToken != null) {
        await _bookingService.updateOrderStatus(
          booking.orderId,
          'midtrans_pending_payment',
          updatedSnapToken: snapToken,
          paymentMethod: 'midtrans_snap',
        );
        return snapToken;
      } else {
        debugPrint("Gagal mendapatkan token pembayaran dari Midtrans.");
        return null;
      }
    } catch (e) {
      debugPrint("Gagal memulai proses pembayaran: $e");
      return null;
    } finally {
      isActionInProgress.value = false;
    }
  }

  Future<void> updateOrderStatusAfterPayment(
    MidtransModel paymentResult,
  ) async {
    try {
      String? finalAppStatus;

      if (paymentResult.transactionStatus == 'settlement' ||
          paymentResult.transactionStatus == 'capture') {
        finalAppStatus = 'paid';
      } else if (paymentResult.transactionStatus == 'pending') {
        finalAppStatus = 'midtrans_payment_pending';
      } else if (paymentResult.transactionStatus == 'expire' ||
          paymentResult.transactionStatus == 'cancel' ||
          paymentResult.transactionStatus == 'deny') {
        finalAppStatus = 'payment_failed_or_cancelled';
      } else if (paymentResult.transactionStatus == 'cancelled_by_user' ||
          paymentResult.transactionStatus == 'web_error') {
        finalAppStatus = 'awaiting_payment_choice';
      }

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
