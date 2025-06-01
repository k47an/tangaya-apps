import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/components/eventCard.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/components/tourPackageCard.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/addEvent_widget.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/widgets/addTourPackage_widget.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ManageTourEventView extends GetView<ManageTourEventController> {
  const ManageTourEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: ScaleHelper.scaleHeightForDevice(10),
                    ),
                    decoration: BoxDecoration(
                      color: Primary.darkColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          ScaleHelper.scaleWidthForDevice(20),
                        ),
                        bottomRight: Radius.circular(
                          ScaleHelper.scaleWidthForDevice(20),
                        ),
                      ),
                    ),
                    child: TabBar(
                      dividerColor: Neutral.transparent,
                      labelColor: Colors.white,
                      indicatorColor: Neutral.transparent,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: semiBold.copyWith(
                        fontSize: ScaleHelper.scaleTextForDevice(16),
                      ),
                      unselectedLabelStyle: regular.copyWith(
                        fontSize: ScaleHelper.scaleTextForDevice(14),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(icon: const Icon(Icons.tour), text: 'Paket Wisata'),
                        Tab(icon: const Icon(Icons.event), text: 'Event'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.isTourLoading.value ||
                          controller.isEventLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const TabBarView(
                        children: [_TourPackageList(), _EventList()],
                      );
                    }),
                  ),
                ],
              ),
              Positioned(
                bottom: ScaleHelper.scaleHeightForDevice(20),
                left: ScaleHelper.scaleWidthForDevice(20),
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 5,
                  onPressed: () => _showAddBottomSheet(context),
                  backgroundColor: Primary.darkColor,
                  foregroundColor: Neutral.white1,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Primary.darkColor,
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Manajemen Paket Wisata & Event",
        style: semiBold.copyWith(
          color: Colors.white,
          fontSize: ScaleHelper.scaleTextForDevice(18),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.tour),
                  title: const Text('Tambah Paket Wisata'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const AddTourPackageView());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Tambah Event'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const AddEventView());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================== WIDGETS ===================

class _TourPackageList extends GetView<ManageTourEventController> {
  const _TourPackageList();

  @override
  Widget build(BuildContext context) {
    if (controller.tourPackages.isEmpty) {
      return const Center(child: Text('Tidak ada paket wisata.'));
    }

    return Obx(
      () => ListView.builder(
        // Tambahkan Obx di sini juga untuk memantau perubahan state loading
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(12)),
        itemCount: controller.tourPackages.length,
        itemBuilder: (context, index) {
          final tourPackage = controller.tourPackages[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: ScaleHelper.scaleHeightForDevice(12),
            ),
            child: TourPackageCard(
              tourPackage: tourPackage,
              onDelete: () async {
                // 1. Tutup dialog konfirmasi terlebih dahulu secara manual
                if (Get.isDialogOpen ?? false) {
                  Get.back(); // Menutup dialog Get.defaultDialog
                }

                // 2. Lanjutkan dengan proses penghapusan paket wisata
                // Pastikan controller Anda memiliki metode deleteTourPackage
                await controller.deleteTourPackage(
                  // Ganti dengan metode yang sesuai di controller Anda
                  docId: tourPackage.id ?? '', // Handle jika id bisa null
                  imageUrls:
                      tourPackage.imageUrls ??
                      [], // Atau cara Anda menghapus gambar tour
                );
                // Controller akan menangani snackbar dan pembaruan list
              },
            ),
          );
        },
      ),
    );
  }
}

class _EventList extends GetView<ManageTourEventController> {
  const _EventList();

  @override
  Widget build(BuildContext context) {
    if (controller.events.isEmpty) {
      return const Center(child: Text('Tidak ada event.'));
    }

    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(12)),
        itemCount: controller.events.length,
        itemBuilder: (context, index) {
          final event = controller.events[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: ScaleHelper.scaleHeightForDevice(12),
            ),
            child: EventCard(
              event: event,
              onDelete: () async {
                // 1. Tutup dialog konfirmasi terlebih dahulu secara manual
                if (Get.isDialogOpen ?? false) {
                  Get.back(); // Menutup dialog Get.defaultDialog
                }

                // 2. Lanjutkan dengan proses penghapusan event
                // Loading indicator akan dihandle oleh controller.deleteEvent
                await controller.deleteEvent(
                  docId: event.id,
                  imageUrl: event.imageUrl,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
