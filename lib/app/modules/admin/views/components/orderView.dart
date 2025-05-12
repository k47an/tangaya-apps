import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/modules/admin/controllers/admin_controller.dart';

class OrderView extends GetView<AdminController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Disetujui')),
      body: Obx(() {
        if (controller.ordersByMonth.isEmpty) {
          return const Center(child: Text('Belum ada pesanan yang disetujui.'));
        }

        return ListView(
          children:
              controller.ordersByMonth.entries.map((entry) {
                final month = entry.key;
                final orders = entry.value;

                return ExpansionTile(
                  title: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children:
                      orders.map((order) {
                        final peopleNames = order['peopleNames'];
                        final peopleList =
                            (peopleNames is List)
                                ? peopleNames
                                    .map((e) => e.toString())
                                    .join(', ')
                                : 'Tidak tersedia';

                        final date = order['date'];
                        final dateStr =
                            (date is DateTime)
                                ? DateFormat('dd MMMM yyyy').format(date)
                                : 'Tanggal tidak tersedia';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              order['packageTitle'] ?? 'Paket tidak diketahui',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nama Pemesan: ${order['name'] ?? '-'}'),
                                Text('Tanggal: $dateStr'),
                                Text('Orang yang ikut: $peopleList'),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              }).toList(),
        );
      }),
    );
  }
}
