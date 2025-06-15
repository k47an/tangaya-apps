import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/booking_model.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart';
import 'package:tangaya_apps/app/modules/notification/views/widgets/emptyNotication_widget.dart';
import 'package:tangaya_apps/app/modules/notification/views/widgets/notificationCard_widget.dart';
import 'package:tangaya_apps/app/modules/payment/bindings/payment_binding.dart';
import 'package:tangaya_apps/app/modules/payment/views/paymentArgumen.dart';
import 'package:tangaya_apps/app/modules/payment/views/payment_view.dart';
import 'package:tangaya_apps/constant/constant.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Primary.darkColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Informasi Pemesanan",
          style: semiBold.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Primary.darkColor, Primary.mainColor, Primary.subtleColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (controller.orders.isEmpty) {
            final message = controller.userRole.value == 'tamu'
                ? "Silakan login untuk melihat riwayat pesanan Anda."
                : "Tidak ada pemesanan saat ini.";
            return EmptyNotificationWidget(message: message);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return NotificationCardWidget(
                order: order,
                isAdmin: controller.userRole.value == 'admin',
                onAdminApprove: () =>
                    controller.processAdminAction(order.orderId, 'approve'),
                onAdminReject: () =>
                    controller.processAdminAction(order.orderId, 'reject'),
                onUserSelectPayment: () =>
                    _showPaymentChoiceDialog(context, order),
                onUserContinuePayment: () => _openPaymentPage(order),
                onUserChangePayment: () =>
                    _showPaymentChoiceDialog(context, order),
              );
            },
          );
        }),
      ),
    );
  }

  void _showPaymentChoiceDialog(BuildContext context, Booking order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Pilih Metode Pembayaran", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text("Bayar di Tempat (COD)"),
              onTap: () {
                Get.back();
                controller.userSelectsCodPayment(order.orderId);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Pembayaran Online"),
              onTap: () {
                Get.back();
                _openPaymentPage(order);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openPaymentPage(Booking order) async {
    // Jika token belum ada, buat dulu. Jika sudah ada, langsung pakai.
    final snapToken =
        order.snapToken ?? await controller.initiateOnlinePayment(order);

    if (snapToken != null) {
      // Navigasi ke PaymentView dan tunggu hasilnya
      final result = await Get.to(
        () => const PaymentView(),
        binding: PaymentBinding(),
        arguments: PaymentPageArguments(
          snapToken: snapToken,
          orderId: order.orderId,
        ),
      );

      // Setelah PaymentView ditutup, tangani hasilnya
      if (result != null && result is MidtransModel) {
        _handlePaymentResult(result);
      } else {
        // Ini terjadi jika user menekan tombol close di AppBar PaymentView
        _handlePaymentResult(MidtransModel(
          orderId: order.orderId,
          transactionStatus: 'cancelled_by_user',
          statusCode: '201', // atau status code lain yang sesuai
        ));
      }
    }
  }

  void _handlePaymentResult(MidtransModel paymentResult) {
    // Update status di database terlebih dahulu
    controller.updateOrderStatusAfterPayment(paymentResult);

    // Siapkan pesan untuk ditampilkan di Snackbar
    String message = "Status Pembayaran: ${paymentResult.transactionStatus}";
    Color bgColor = Colors.orange;

    if (paymentResult.transactionStatus == 'web_error') {
      message =
          "Pembayaran bermasalah, silakan coba metode pembayaran lain seperti COD.";
      bgColor = Colors.red.shade700;
    } else if (paymentResult.transactionStatus == 'settlement' ||
        paymentResult.transactionStatus == 'capture') {
      message = "Pembayaran untuk order ${paymentResult.orderId} BERHASIL!";
      bgColor = Colors.green;
    } else if (paymentResult.transactionStatus == 'cancelled_by_user') {
      message = "Anda membatalkan proses pembayaran.";
      bgColor = Colors.grey.shade600;
    }

    Get.snackbar(
      "Info Pembayaran",
      message,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }
}