import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/editEvent_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onDelete;

  const EventCard({super.key, required this.event, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: ScaleHelper.scaleHeightForDevice(8),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: ScaleHelper.scaleWidthForDevice(60),
            height: ScaleHelper.scaleHeightForDevice(60),
            child: Image.network(
              event.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 48),
            ),
          ),
        ),
        title: Text(
          event.title,
          style: semiBold.copyWith(
            fontSize: ScaleHelper.scaleTextForDevice(16),
          ),
        ),
        subtitle: Text(
          '${event.location} • ${DateFormat('dd MMM yyyy').format(event.eventDate)}',
          style: regular.copyWith(color: Neutral.dark1),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Get.to(() => EditEventView(event: event));
            }
            if (value == 'delete' && onDelete != null) {
              onDelete!();
            }
          },
          itemBuilder:
              (context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(
                    'Edit',
                    style: regular.copyWith(color: Neutral.dark1),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(
                    'Hapus',
                    style: regular.copyWith(color: Colors.red),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
