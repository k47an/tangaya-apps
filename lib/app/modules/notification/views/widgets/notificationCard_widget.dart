import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/booking_model.dart';
import 'package:tangaya_apps/app/modules/notification/controllers/notification_controller.dart';

class NotificationCardWidget extends GetView<NotificationController> {
  final Booking order;
  final bool isAdmin;
  final VoidCallback onAdminApprove;
  final VoidCallback onAdminReject;
  final VoidCallback onUserSelectPayment;
  final VoidCallback onUserContinuePayment;
  final VoidCallback onUserChangePayment;

  const NotificationCardWidget({
    super.key,
    required this.order,
    required this.isAdmin,
    required this.onAdminApprove,
    required this.onAdminReject,
    required this.onUserSelectPayment,
    required this.onUserContinuePayment,
    required this.onUserChangePayment,
  });

  @override
  Widget build(BuildContext context) {
    // Mendapatkan informasi status (teks dan warna) dari helper method
    final statusInfo = _getStatusInfo(order.status);
    // Mendapatkan tombol aksi yang sesuai dengan status dan role
    final actionButtons = _buildActionButtons();

    return Card(
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.itemTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            if (order.bookingDate != null)
              _buildInfoRow(
                Icons.calendar_today_outlined,
                "Tgl. Booking",
                DateFormat('dd MMMM yyyy', 'id_ID').format(order.bookingDate!),
              ),
            _buildInfoRow(
              Icons.people_alt_outlined,
              "Jumlah Orang",
              order.peopleCount.toString(),
            ),
            _buildInfoRow(
              Icons.update_outlined,
              "Update Terakhir",
              DateFormat(
                'dd MMMM yyyy, HH:mm',
                'id_ID',
              ).format(order.updatedAt),
            ),
            if (isAdmin)
              _buildInfoRow(
                Icons.person_outline,
                "Pemesan",
                order.customerName,
              ),
            if (order.totalPrice > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                child: Text(
                  "Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(order.totalPrice)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.9),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo['bgColor'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusInfo['text']!,
                      style: TextStyle(
                        color: statusInfo['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (actionButtons.isNotEmpty)
                  Obx(
                    () =>
                        controller.isActionInProgress.value
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: actionButtons,
                            ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk menentukan teks dan warna berdasarkan status
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending_approval':
        return {
          'text': 'Menunggu Persetujuan',
          'color': Colors.orange.shade900,
          'bgColor': Colors.orange.shade100,
        };
      case 'awaiting_payment_choice':
        return {
          'text': 'Pilih Metode Bayar',
          'color': Colors.blue.shade900,
          'bgColor': Colors.blue.shade100,
        };
      case 'cod_selected':
        return {
          'text': 'Bayar di Tempat (COD)',
          'color': Colors.brown.shade900,
          'bgColor': Colors.brown.shade100,
        };
      case 'midtrans_pending_payment':
      case 'midtrans_payment_pending':
        return {
          'text': 'Menunggu Pembayaran',
          'color': Colors.purple.shade900,
          'bgColor': Colors.purple.shade100,
        };
      case 'paid':
      case 'settlement':
        return {
          'text': 'Pembayaran Berhasil',
          'color': Colors.green.shade900,
          'bgColor': Colors.green.shade100,
        };
      case 'rejected_by_admin':
        return {
          'text': 'Pesanan Ditolak',
          'color': Colors.red.shade900,
          'bgColor': Colors.red.shade100,
        };
      case 'payment_failed_or_cancelled':
      case 'expire':
      case 'cancel':
      case 'deny':
        return {
          'text': 'Pembayaran Gagal',
          'color': Colors.red.shade800,
          'bgColor': Colors.red.shade100,
        };
      default:
        return {
          'text': status.capitalizeFirst ?? 'Unknown',
          'color': Colors.grey.shade800,
          'bgColor': Colors.grey.shade300,
        };
    }
  }

  // Helper method untuk membangun tombol aksi berdasarkan status dan role
  List<Widget> _buildActionButtons() {
    if (isAdmin) {
      if (order.status == 'pending_approval') {
        return [
          IconButton(
            icon: Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade600,
              size: 30,
            ),
            onPressed: onAdminApprove,
            tooltip: 'Setujui',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              Icons.highlight_off_outlined,
              color: Colors.red.shade600,
              size: 30,
            ),
            onPressed: onAdminReject,
            tooltip: 'Tolak',
          ),
        ];
      }
    } else {
      // Tombol untuk User
      switch (order.status) {
        case 'awaiting_payment_choice':
          return [
            ElevatedButton(
              onPressed: onUserSelectPayment,
              child: const Text("Pilih Bayar"),
            ),
          ];
        case 'midtrans_pending_payment':
          return [
            ElevatedButton(
              onPressed: onUserContinuePayment,
              child: const Text("Lanjutkan Bayar"),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onUserChangePayment,
              child: const Text("Ubah Metode"),
            ),
          ];
        case 'cod_selected':
        case 'payment_failed_or_cancelled':
          return [
            OutlinedButton(
              onPressed: onUserChangePayment,
              child: const Text("Ubah Metode Bayar"),
            ),
          ];
      }
    }
    return []; // Return list kosong jika tidak ada aksi
  }

  // Helper method untuk membuat baris info (icon, label, value)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
