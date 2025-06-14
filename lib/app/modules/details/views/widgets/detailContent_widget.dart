import 'package:flutter/material.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/constant/constant.dart';

class DetailContentWidget extends StatelessWidget {
  final dynamic item;

  const DetailContentWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title ?? 'Tanpa Judul',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Primary.darkColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  // Jika item event punya lokasi, tampilkan. Jika tidak, gunakan default.
                  (item is Event ? item.location : null) ?? "Desa Saniang Baka",
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Deskripsi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Primary.darkColor),
          ),
          const SizedBox(height: 8),
          Text(
            item.description ?? 'Tidak ada deskripsi.',
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}