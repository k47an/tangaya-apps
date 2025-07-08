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
import 'package:tangaya_apps/utils/global_components/snackbar.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              colors: [
                Primary.darkColor,
                Primary.mainColor,
                Primary.subtleColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.5, 0.9],
            ),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (controller.orders.isEmpty) {
              final message =
                  controller.userRole.value == 'tamu'
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
                  onAdminApprove:
                      () => controller.processAdminAction(
                        order.orderId,
                        'approve',
                      ),
                  onAdminReject:
                      () => controller.processAdminAction(
                        order.orderId,
                        'reject',
                      ),
                  onUserSelectPayment:
                      () => _showPaymentChoiceDialog(context, order),
                  onUserContinuePayment: () => _openPaymentPage(order),
                  onUserChangePayment:
                      () => _showPaymentChoiceDialog(context, order),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showPaymentChoiceDialog(BuildContext context, Booking order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Pilih Metode Pembayaran",
          textAlign: TextAlign.center,
        ),
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
    final snapToken =
        order.snapToken ?? await controller.initiateOnlinePayment(order);

    if (snapToken != null) {
      final result = await Get.to(
        () => const PaymentView(),
        binding: PaymentBinding(),
        arguments: PaymentPageArguments(
          snapToken: snapToken,
          orderId: order.orderId,
        ),
      );

      if (result != null && result is MidtransModel) {
        _handlePaymentResult(result);
      } else {
        _handlePaymentResult(
          MidtransModel(
            orderId: order.orderId,
            transactionStatus: 'cancelled_by_user',
            statusCode: '201',
          ),
        );
      }
    }
  }

  void _handlePaymentResult(MidtransModel paymentResult) {
    controller.updateOrderStatusAfterPayment(paymentResult);
    String message = "Terjadi kesalahan pada status pembayaran.";
    SnackBarType type = SnackBarType.error;

    switch (paymentResult.transactionStatus) {
      case 'web_error':
        message =
            "Pembayaran bermasalah, silakan coba metode pembayaran lain seperti COD.";
        type = SnackBarType.error;
        break;
      case 'settlement':
      case 'capture':
        message = "Pembayaran Berhasil!";
        type = SnackBarType.success;
        break;
      case 'cancelled_by_user':
        message = "Anda membatalkan proses pembayaran.";
        type = SnackBarType.warning;
        break;
    }

    CustomSnackBar.show(context: Get.context!, message: message, type: type);
  }
}
