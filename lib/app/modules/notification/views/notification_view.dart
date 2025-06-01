import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart'; // Sesuaikan path jika perlu
import 'package:tangaya_apps/app/modules/payment/views/payment_view.dart'; // Sesuaikan path jika perlu
import 'package:tangaya_apps/app/modules/payment/bindings/payment_binding.dart'; // Sesuaikan path jika perlu
import 'package:tangaya_apps/constant/constant.dart';
import '../controllers/notification_controller.dart'; // Sesuaikan path jika perlu

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat(
        'dd MMMM yyyy, HH:mm', // Format dengan tahun
        'id_ID',
      ).format(timestamp.toDate());
    } else if (timestamp is DateTime) {
      return DateFormat(
        'dd MMMM yyyy, HH:mm', // Format dengan tahun
        'id_ID',
      ).format(timestamp);
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
      Color textColor = Colors.white;

      if (paymentResult.transactionStatus == 'settlement' ||
          paymentResult.transactionStatus == 'capture') {
        message = "Pembayaran untuk order ${paymentResult.orderId} BERHASIL!";
        bgColor = Colors.green.shade700;
      } else if (paymentResult.transactionStatus == 'pending') {
        message = "Pembayaran untuk order ${paymentResult.orderId} menunggu.";
        bgColor = Colors.amber.shade700;
      } else if (paymentResult.transactionStatus == 'expire' ||
          paymentResult.transactionStatus == 'cancel' ||
          paymentResult.transactionStatus == 'deny') {
        message =
            "Pembayaran untuk order ${paymentResult.orderId} GAGAL atau DIBATALKAN (${paymentResult.transactionStatus}).";
        bgColor = Colors.red.shade700;
      } else if (paymentResult.transactionStatus == 'cancelled_by_user') {
        message = "Pembayaran dibatalkan oleh pengguna.";
        bgColor = Colors.grey.shade600;
      } else if (paymentResult.transactionStatus == 'web_error') {
        message = "Terjadi masalah saat memuat halaman pembayaran.";
        bgColor = Colors.red.shade700;
      }
      Get.snackbar(
        "Hasil Pembayaran",
        message,
        backgroundColor: bgColor,
        colorText: textColor,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );

      controller.updateOrderStatusAfterPayment(paymentResult);
    } else {
      print(
        "PaymentView closed without a valid MidtransModel result or with null.",
      );
      Get.snackbar(
        "Info",
        "Proses pembayaran ditutup atau tidak ada hasil.",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    }
  }

  void _showPaymentChoiceDialog(
    BuildContext context,
    DocumentSnapshot orderDocument,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.only(top: 24, bottom: 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        title: Text(
          "Pilih Metode Pembayaran",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.isProcessingPayment.value ||
                  controller.isUserChoosingCod.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                ListTile(
                  leading: Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.orangeAccent.shade700,
                    size: 28,
                  ),
                  title: const Text("Bayar di Tempat (COD)"),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  onTap: () {
                    Get.back();
                    controller.userSelectsCodPayment(orderDocument.id);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.credit_card,
                    color: Colors.blueAccent.shade700,
                    size: 28,
                  ),
                  title: const Text("Pembayaran Online"),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  onTap: () async {
                    Get.back();
                    final snapToken = await controller.initiateOnlinePayment(
                      orderDocument,
                    );
                    if (snapToken != null && Get.context != null) {
                      final result = await Get.to(
                        () => const PaymentView(),
                        binding: PaymentBinding(),
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
        actionsPadding: const EdgeInsets.only(bottom: 16, top: 8),
        actions: [
          Obx(
            () => TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                          ? Colors.grey.shade400
                          : Colors.redAccent.shade700,
                  fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    // Mengambil warna dasar dari Card untuk konsistensi
    // Dengan asumsi Card memiliki warna dasar terang (misal, putih)
    // dan teks di dalamnya berwarna gelap.
    Color onCardColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors
                .white70 // Warna untuk tema gelap
            : Colors.black54; // Warna untuk tema terang

    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: onCardColor.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: onCardColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onCardColor.withOpacity(0.9),
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Primary.darkColor,
                Primary.mainColor,
                Primary.subtleColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
          child: Obx(() {
            if (controller.uid.value.isEmpty &&
                controller.role.value.isNotEmpty &&
                controller.role.value != 'tamu') {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (controller.role.value == 'tamu' && controller.orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Silakan login untuk melihat riwayat pesanan Anda.",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(
                        0.9,
                      ), // Teks kontras dengan gradient
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (controller.orders.isEmpty &&
                !(controller.uid.value.isEmpty &&
                    controller.role.value.isNotEmpty &&
                    controller.role.value != 'tamu')) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Tidak ada pemesanan saat ini.",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(
                        0.9,
                      ), // Teks kontras dengan gradient
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final isAdmin = controller.role.value == 'admin';

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final orderDocument = controller.orders[index];
                final Map<String, dynamic> orderData =
                    orderDocument.data() as Map<String, dynamic>;

                final String status =
                    orderData['status'] as String? ?? 'unknown';
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
                Color statusBgColor;
                List<Widget> actionButtonsForUser = [];

                final cardBackgroundColor = Colors.white.withOpacity(
                  0.95,
                ); // Warna card agak transparan
                final cardForegroundColor =
                    Colors.black87; // Warna teks utama di card

                switch (status) {
                  case 'pending_approval':
                    statusText = 'Menunggu Persetujuan';
                    statusColor = Colors.orange.shade900;
                    statusBgColor = Colors.orange.shade100;
                    break;
                  case 'awaiting_payment_choice':
                    statusText = 'Disetujui! Pilih Metode Bayar';
                    statusColor = Colors.blue.shade900;
                    statusBgColor = Colors.blue.shade100;
                    if (!isAdmin) {
                      actionButtonsForUser = [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Obx(
                            () =>
                                (controller.isProcessingPayment.value ||
                                        controller.isUserChoosingCod.value)
                                    ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.payments_outlined,
                                      size: 20,
                                    ),
                          ),
                          label: const Text(
                            "Pilih Bayar",
                            style: TextStyle(fontSize: 13),
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
                    statusText = 'Bayar di Tempat (COD)';
                    statusColor = Colors.brown.shade900;
                    statusBgColor = Colors.brown.shade100;
                    break;
                  case 'midtrans_pending_payment':
                  case 'midtrans_payment_pending':
                    statusText = 'Menunggu Pembayaran Online';
                    statusColor = Colors.purple.shade900;
                    statusBgColor = Colors.purple.shade100;
                    if (orderData['snapToken'] != null && !isAdmin) {
                      actionButtonsForUser = [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.open_in_new, size: 20),
                          label: const Text(
                            "Lanjutkan Bayar",
                            style: TextStyle(fontSize: 13),
                          ),
                          onPressed: () async {
                            final String? existingSnapToken =
                                orderData['snapToken'] as String?;
                            if (existingSnapToken != null) {
                              final result = await Get.to(
                                () => const PaymentView(),
                                binding: PaymentBinding(),
                                arguments: {
                                  'snapToken': existingSnapToken,
                                  'orderId': orderDocument.id,
                                },
                              );
                              _handlePaymentResult(result);
                            } else {
                              Get.snackbar(
                                "Error",
                                "Snap Token tidak ditemukan.",
                              );
                            }
                          },
                        ),
                      ];
                    }
                    break;
                  case 'paid':
                  case 'settlement':
                    statusText = 'Pembayaran Berhasil';
                    statusColor = Colors.green.shade900;
                    statusBgColor = Colors.green.shade100;
                    break;
                  case 'rejected_by_admin':
                    statusText = 'Pesanan Ditolak';
                    statusColor = Colors.red.shade900;
                    statusBgColor = Colors.red.shade100;
                    break;
                  case 'payment_failed_or_cancelled':
                  case 'expire':
                  case 'cancel':
                  case 'deny':
                    statusText = 'Pembayaran Gagal/Dibatalkan';
                    statusColor = Colors.red.shade800;
                    statusBgColor = Colors.red.shade100;
                    break;
                  default:
                    statusText =
                        status.isNotEmpty
                            ? status.replaceAll('_', ' ').capitalizeFirst ??
                                'Tidak Diketahui'
                            : 'Tidak Diketahui';
                    statusColor = Colors.grey.shade800;
                    statusBgColor = Colors.grey.shade300;
                }

                return Card(
                  color: cardBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(
                    0.4,
                  ), // Shadow lebih terlihat
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cardForegroundColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.vpn_key_outlined,
                          "Kode Pemesanan",
                          orderData['orderId'] ?? 'N/A',
                          context,
                        ),
                        // --- PERUBAHAN UTAMA ADA DI SINI ---
                        if (orderData.containsKey('bookingDate'))
                          _buildInfoRow(
                            Icons.calendar_today_outlined,
                            "Tgl. Booking",
                            orderData['bookingDate'] != null
                                ? DateFormat(
                                  'dd MMMM yyyy', // Hanya tanggal, tanpa jam
                                  'id_ID',
                                ).format(
                                  orderData['bookingDate'] is Timestamp
                                      ? orderData['bookingDate'].toDate()
                                      : orderData['bookingDate'] as DateTime,
                                )
                                : 'Tanggal tidak valid',
                            context,
                          ),
                        // --- AKHIR PERUBAHAN UTAMA ---
                        _buildInfoRow(
                          Icons.people_alt_outlined, // Icon untuk jumlah orang
                          "Jumlah Orang",
                          orderData['peopleCount']?.toString() ?? 'N/A',
                          context,
                        ),
                        _buildInfoRow(
                          Icons.update_outlined,
                          "Update Terakhir",
                          _formatDate(orderData['updatedAt']),
                          context,
                        ),
                        if (isAdmin && customerNameForAdmin.isNotEmpty)
                          _buildInfoRow(
                            Icons.person_outline,
                            "Pemesan",
                            customerNameForAdmin,
                            context,
                          ),

                        if (orderData.containsKey('totalPrice') &&
                            (orderData['totalPrice'] as num? ?? 0) > 0)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 4.0,
                            ),
                            child: Text(
                              "Total: Rp ${NumberFormat('#,###', 'id_ID').format(orderData['totalPrice'])}",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColorDark.withOpacity(0.9),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
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
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              // Pertimbangkan warna indikator jika default tidak kontras
                                              // color: theme.colorScheme.primary,
                                            ),
                                          )
                                          : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.check_circle_outline,
                                                  color: Colors.green.shade600,
                                                  size: 30,
                                                ),
                                                tooltip: 'Setujui',
                                                onPressed:
                                                    () => controller
                                                        .processAdminAction(
                                                          orderDocument,
                                                          'approve',
                                                        ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.highlight_off_outlined,
                                                  color: Colors.red.shade600,
                                                  size: 30,
                                                ),
                                                tooltip: 'Tolak',
                                                onPressed:
                                                    () => controller
                                                        .processAdminAction(
                                                          orderDocument,
                                                          'reject',
                                                        ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
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
        ),
      ),
    );
  }
}
