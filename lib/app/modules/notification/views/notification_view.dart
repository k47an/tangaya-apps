import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart';
import 'package:tangaya_apps/app/modules/payment/views/payment_view.dart';
// Impor Binding jika Anda menggunakan pendekatan BindingsBuilder atau GetPage
import 'package:tangaya_apps/app/modules/payment/bindings/payment_binding.dart';
import 'package:tangaya_apps/app/modules/payment/controllers/payment_controller.dart'; // Diperlukan untuk BindingsBuilder
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('dd MMMM HH:mm', 'id_ID').format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      return DateFormat('dd MMMM HH:mm', 'id_ID').format(timestamp);
    }
    return 'Tanggal tidak valid';
  }

  void _handlePaymentResult(dynamic paymentResult) {
    if (paymentResult != null && paymentResult is MidtransModel) {
      print(
        "PaymentView Result: ${paymentResult.transactionStatus}, OrderID: ${paymentResult.orderId}",
      );
      String message = "Status Pembayaran: ${paymentResult.transactionStatus}";
      Color bgColor = Colors.orange;
      bool isSuccess = false;

      if (paymentResult.transactionStatus == 'settlement' ||
          paymentResult.transactionStatus == 'capture') {
        message = "Pembayaran untuk order ${paymentResult.orderId} BERHASIL!";
        bgColor = Colors.green;
        isSuccess = true;
      } else if (paymentResult.transactionStatus == 'pending') {
        message = "Pembayaran untuk order ${paymentResult.orderId} menunggu.";
      } else if (paymentResult.transactionStatus == 'expire' ||
          paymentResult.transactionStatus == 'cancel' ||
          paymentResult.transactionStatus == 'deny') {
        message =
            "Pembayaran untuk order ${paymentResult.orderId} GAGAL atau DIBATALKAN (${paymentResult.transactionStatus}).";
        bgColor = Colors.red;
      } else if (paymentResult.transactionStatus == 'cancelled_by_user') {
        message = "Pembayaran dibatalkan oleh pengguna.";
        bgColor = Colors.grey;
      } else if (paymentResult.transactionStatus == 'web_error') {
        message = "Terjadi masalah saat memuat halaman pembayaran.";
        bgColor = Colors.red;
      }
      Get.snackbar(
        "Hasil Pembayaran",
        message,
        backgroundColor: bgColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Panggil metode di controller untuk update status di Firestore
      controller.updateOrderStatusAfterPayment(paymentResult);
    } else {
      print(
        "PaymentView closed without a valid MidtransModel result or with null.",
      );
      Get.snackbar("Info", "Proses pembayaran ditutup atau tidak ada hasil.");
    }
  }

  void _showPaymentChoiceDialog(
    BuildContext context,
    DocumentSnapshot orderDocument,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Pilih Metode Pembayaran",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.isProcessingPayment.value ||
                  controller
                      .isUserChoosingCod
                      .value) // Menggunakan isUserChoosingCod
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                ListTile(
                  leading: const Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.orangeAccent,
                  ),
                  title: const Text("Bayar di Tempat (COD)"),
                  onTap: () {
                    Get.back();
                    controller.userSelectsCodPayment(orderDocument.id);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.credit_card,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Pembayaran Online"),
                  onTap: () async {
                    Get.back();
                    final snapToken = await controller.initiateOnlinePayment(
                      orderDocument,
                    );
                    if (snapToken != null && Get.context != null) {
                      final result = await Get.to(
                        () => const PaymentView(),
                        // Jika Anda sudah mendaftarkan PaymentBinding di AppPages untuk rute PaymentView,
                        // Anda tidak perlu parameter `binding:` di sini saat menggunakan Get.toNamed.
                        // Namun, jika menggunakan Get.to(()=> ...) seperti ini, binding diperlukan.
                        binding:
                            PaymentBinding(), // atau BindingsBuilder(() { Get.lazyPut<PaymentController>(() => PaymentController()); }),
                        arguments: {
                          'snapToken': snapToken,
                          'orderId': orderDocument.id,
                        },
                      );
                      _handlePaymentResult(result);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  (controller.isProcessingPayment.value ||
                          controller.isUserChoosingCod.value)
                      ? null
                      : () => Get.back(),
              child: Text(
                "Batal",
                style: TextStyle(
                  color:
                      (controller.isProcessingPayment.value ||
                              controller.isUserChoosingCod.value)
                          ? Colors.grey
                          : Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible:
          !(controller.isProcessingPayment.value ||
              controller.isUserChoosingCod.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Pemesanan"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.uid.value.isEmpty &&
            controller.role.value.isNotEmpty &&
            controller.role.value != 'tamu') {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.role.value == 'tamu' && controller.orders.isEmpty) {
          return const Center(
            child: Text("Silakan login untuk melihat pesanan Anda."),
          );
        }
        if (controller.orders.isEmpty &&
            !(controller.uid.value.isEmpty &&
                controller.role.value.isNotEmpty &&
                controller.role.value != 'tamu')) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Tidak ada pemesanan saat ini.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final isAdmin = controller.role.value == 'admin';

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final orderDocument = controller.orders[index];
            final Map<String, dynamic> orderData =
                orderDocument.data() as Map<String, dynamic>;

            final String status = orderData['status'] as String? ?? 'unknown';
            final String itemTitle =
                (orderData['packageTitle'] ??
                        orderData['eventTitle'] ??
                        'Detail Pesanan Tidak Tersedia')
                    as String;
            final String customerNameForAdmin =
                isAdmin
                    ? (orderData['customerName'] as String? ?? 'Tanpa Nama')
                    : '';

            String statusText;
            Color statusColor;
            List<Widget> actionButtonsForUser = [];

            switch (status) {
              case 'pending_approval':
                statusText = 'Menunggu Persetujuan Admin';
                statusColor = Colors.orange.shade700;
                break;
              case 'awaiting_payment_choice':
                statusText = 'Disetujui! Pilih Metode Bayar';
                statusColor = Colors.blue.shade700;
                if (!isAdmin) {
                  actionButtonsForUser = [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      icon: Obx(
                        () =>
                            (controller.isProcessingPayment.value ||
                                    controller
                                        .isUserChoosingCod
                                        .value) // Menggunakan isUserChoosingCod
                                ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1.5,
                                  ),
                                )
                                : const Icon(Icons.payments_outlined, size: 18),
                      ),
                      label: const Text(
                        "Pilih Bayar",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed:
                          (controller.isProcessingPayment.value ||
                                  controller.isUserChoosingCod.value)
                              ? null
                              : () => _showPaymentChoiceDialog(
                                context,
                                orderDocument,
                              ),
                    ),
                  ];
                }
                break;
              case 'cod_selected':
                statusText = 'COD';
                statusColor = Colors.brown.shade600;
                break;
              case 'midtrans_pending_payment': // Sebelumnya 'payment_initiated_post_approval'
              case 'midtrans_payment_pending': // Atau status pending dari Midtrans
                statusText = 'Menunggu Pembayaran Online';
                statusColor = Colors.purple.shade600;
                if (orderData['snapToken'] != null && !isAdmin) {
                  actionButtonsForUser = [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        "Lanjutkan Bayar",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        final String? existingSnapToken =
                            orderData['snapToken'] as String?;
                        if (existingSnapToken != null) {
                          final result = await Get.to(
                            () => const PaymentView(),
                            binding:
                                PaymentBinding(), // Menggunakan PaymentBinding
                            arguments: {
                              'snapToken': existingSnapToken,
                              'orderId': orderDocument.id,
                            },
                          );
                          _handlePaymentResult(result);
                        } else {
                          Get.snackbar("Error", "Snap Token tidak ditemukan.");
                        }
                      },
                    ),
                  ];
                }
                break;
              case 'paid': // Status baru dari controller setelah settlement
              case 'settlement': // Status dari Midtrans
                statusText = 'Pembayaran Berhasil';
                statusColor = Colors.green.shade700;
                break;
              case 'rejected_by_admin':
                statusText = 'Pesanan Ditolak Admin';
                statusColor = Colors.red.shade700;
                break;
              case 'payment_failed_or_cancelled': // Status baru dari controller
              case 'expire':
              case 'cancel':
              case 'deny':
                statusText = 'Pembayaran Gagal/Dibatalkan';
                statusColor = Colors.red.shade400;
                break;
              default:
                statusText =
                    status.isNotEmpty
                        ? status.replaceAll('_', ' ').capitalizeFirst ??
                            'Tidak Diketahui'
                        : 'Tidak Diketahui';
                statusColor = Colors.grey.shade700;
            }

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isAdmin && customerNameForAdmin.isNotEmpty)
                      Text(
                        "Pemesan: $customerNameForAdmin",
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    Row(
                      children: [
                        const Icon(Icons.vpn_key, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Order ID: ${orderData['orderId'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.update, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Update: ${_formatDate(orderData['updatedAt'])}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (orderData.containsKey('totalPrice') &&
                        (orderData['totalPrice'] as int? ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "Total: Rp ${NumberFormat('#,###', 'id_ID').format(orderData['totalPrice'])}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (isAdmin) ...[
                          if (status == 'pending_approval' ||
                              status == 'cod_pending_confirmation')
                            Obx(
                              () =>
                                  controller.isAdminActionInProgress.value
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 28,
                                            ),
                                            tooltip: 'Setujui',
                                            onPressed:
                                                () => controller
                                                    .processAdminAction(
                                                      orderDocument,
                                                      'approve',
                                                    ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                              size: 28,
                                            ),
                                            tooltip: 'Tolak',
                                            onPressed:
                                                () => controller
                                                    .processAdminAction(
                                                      orderDocument,
                                                      'reject',
                                                    ),
                                          ),
                                        ],
                                      ),
                            ),
                        ] else if (actionButtonsForUser.isNotEmpty) ...[
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            alignment: WrapAlignment.end,
                            children: actionButtonsForUser,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
