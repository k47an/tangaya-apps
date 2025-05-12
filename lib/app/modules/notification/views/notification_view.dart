import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Status Pemesanan")),
      body: Obx(() {
        if (controller.role.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final isAdmin = controller.role.value == 'admin';

        if (controller.orders.isEmpty) {
          return const Center(child: Text("Tidak ada pemesanan."));
        }

        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final status = order['status'] ?? 'pending';

            String statusText = 'Menunggu persetujuan';
            Color statusColor = Colors.grey;

            if (status == 'approved') {
              statusText = 'Disetujui';
              statusColor = Colors.green;
            } else if (status == 'rejected') {
              statusText = 'Ditolak';
              statusColor = Colors.red;
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(order['packageTitle'] ?? 'Nama tidak tersedia'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "nama pemesanan: ${order['name'] ?? 'Tidak ada nama'}",
                    ),
                    Text(
                      "Tanggal: ${DateFormat('yyyy-MM-dd').format(order['date'].toDate())}",
                    ),
                    Text(
                      "Status: $statusText",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing:
                    isAdmin
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                controller.updateOrderStatus(
                                  order.id,
                                  'approved',
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                controller.updateOrderStatus(
                                  order.id,
                                  'rejected',
                                );
                              },
                            ),
                          ],
                        )
                        : const Icon(Icons.info_outline, color: Colors.grey),
              ),
            );
          },
        );
      }),
    );
  }
}
