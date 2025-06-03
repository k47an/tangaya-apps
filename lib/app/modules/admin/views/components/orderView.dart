import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/modules/admin/controllers/admin_controller.dart';
import 'package:tangaya_apps/constant/constant.dart'; // Asumsi Anda punya Primary.mainColor di sini

class OrderView extends GetView<AdminController> {
  const OrderView({super.key});

  // Helper widget untuk baris info
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
    Color valueColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color:
                Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7) ??
                Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color:
                    Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.9) ??
                    Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.start,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk status chip
  Widget _buildStatusChip(String status, String paymentMethod) {
    String displayStatusText = status;
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info_outline;

    if (status == 'paid' || status == 'settlement') {
      displayStatusText =
          paymentMethod == 'cod' ? 'COD (Lunas)' : 'Lunas (Online)';
      statusColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'cod_selected_awaiting_delivery') {
      displayStatusText = 'COD (Menunggu Pengiriman)';
      statusColor = Colors.orange.shade800;
      statusIcon = Icons.local_shipping_outlined;
    } else if (status == 'cod_completed') {
      displayStatusText = 'COD (Selesai)';
      statusColor = Colors.blue.shade700;
      statusIcon = Icons.done_all_outlined;
    }
    // Anda bisa menambahkan mapping status lain di sini

    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 16),
      label: Text(
        displayStatusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: statusColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.only(
        left: 2,
        right: 6,
      ), // Sesuaikan padding label
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Primary.darkColor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Riwayat Pemesanan ",
            style: semiBold.copyWith(color: Colors.white, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Obx(() {
          if (controller.isLoadingOrders.value) {
            // Menggunakan isLoadingOrders
            return const Center(
              child: CircularProgressIndicator(color: Primary.mainColor),
            );
          }
          if (controller.ordersByMonth.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada pesanan yang diproses.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.ordersByMonth.keys.length,
            itemBuilder: (context, monthIndex) {
              final month = controller.ordersByMonth.keys.elementAt(monthIndex);
              final ordersInMonth = controller.ordersByMonth[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 16.0,
                      bottom: 8.0,
                      right: 12.0,
                    ),
                    child: Text(
                      month,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Primary.mainColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ordersInMonth.length,
                    itemBuilder: (context, orderIndex) {
                      final orderDataMap = ordersInMonth[orderIndex];
                      final String packageTitle = orderDataMap['packageTitle'];
                      final String customerName = orderDataMap['customerName'];
                      final DateTime bookingDate = orderDataMap['bookingDate'];
                      final List<String> peopleNames =
                          orderDataMap['peopleNames'];
                      final String peopleList =
                          peopleNames.isNotEmpty ? peopleNames.join(', ') : '-';
                      final int totalPrice = orderDataMap['totalPrice'];
                      final String status = orderDataMap['status'];
                      final String paymentMethod =
                          orderDataMap['paymentMethodType'];

                      return Card(
                        elevation: 2.5,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                packageTitle,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Divider(height: 16),
                              _buildInfoRow(
                                context,
                                Icons.person_outline_rounded,
                                "Pemesan:",
                                customerName,
                              ),
                              _buildInfoRow(
                                context,
                                Icons.calendar_today_rounded,
                                "Tanggal:",
                                DateFormat(
                                  'EEEE, dd MMM yyyy',
                                  'id_ID',
                                ).format(bookingDate),
                              ),
                              if (peopleNames.isNotEmpty)
                                _buildInfoRow(
                                  context,
                                  Icons.groups_outlined,
                                  "Peserta:",
                                  peopleList,
                                  maxLines: 3,
                                ),
                              _buildInfoRow(
                                context,
                                Icons.account_balance_wallet_outlined,
                                "Metode:",
                                paymentMethod.toUpperCase(),
                              ),
                              _buildInfoRow(
                                context,
                                Icons.monetization_on_outlined,
                                "Total:",
                                "Rp ${NumberFormat('#,###', 'id_ID').format(totalPrice)}",
                                valueColor: Colors.green.shade700,
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildStatusChip(status, paymentMethod),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
