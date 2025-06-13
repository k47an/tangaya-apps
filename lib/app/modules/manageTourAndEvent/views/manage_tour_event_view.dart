// lib/app/modules/manageTourAndEvent/views/manage_tour_event_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/components/eventCard.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/components/tourPackageCard.dart';
import 'package:tangaya_apps/app/modules/manageTourAndEvent/controllers/manage_tour_event_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ManageTourEventView extends GetView<ManageTourEventController> {
  const ManageTourEventView({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController akan mengelola state tab secara otomatis
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(children: [_TourPackageList(), _EventList()]),
              ),
            ],
          ),
          // Menggunakan Builder agar context yang digunakan untuk showModalBottomSheet
          // adalah context yang berada di bawah Scaffold.
          floatingActionButton: Builder(
            builder:
                (context) => FloatingActionButton(
                  onPressed: () => _showAddBottomSheet(context),
                  backgroundColor: Primary.darkColor,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
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
        "Manajemen Data",
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

  Container _buildTabBar() {
    return Container(
      color: Primary.darkColor,
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor:
            Primary.mainColor, // Memberi warna pada indicator agar lebih jelas
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.tour), text: 'Paket Wisata'),
          Tab(icon: Icon(Icons.event), text: 'Event'),
        ],
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.tour),
                  title: const Text('Tambah Paket Wisata'),
                  onTap: () {
                    Navigator.pop(context);
                    // PERBAIKAN: Panggil method controller, bukan Get.to langsung
                    controller.goToUpsertTourView();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Tambah Event'),
                  onTap: () {
                    Navigator.pop(context);
                    // PERBAIKAN: Panggil method controller, bukan Get.to langsung
                    controller.goToUpsertEventView();
                  },
                ),
              ],
            ),
          ),
    );
  }
}

// ============== WIDGETS UNTUK LIST ==============

class _TourPackageList extends GetView<ManageTourEventController> {
  const _TourPackageList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Menampilkan loading indicator khusus untuk list ini jika diperlukan
      if (controller.isTourLoading.value && controller.tourPackages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.tourPackages.isEmpty) {
        return const Center(child: Text('Belum ada paket wisata.'));
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchTourPackages(),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.tourPackages.length,
          itemBuilder: (context, index) {
            final tourPackage = controller.tourPackages[index];
            return TourPackageCard(
              tourPackage: tourPackage,
              // PERBAIKAN: Sambungkan callback onEdit ke method controller
              onEdit:
                  () => controller.goToUpsertTourView(tourPackage: tourPackage),
              // PERBAIKAN: Sambungkan callback onDelete ke method controller
              onDelete:
                  () => controller.deleteTourPackage(package: tourPackage),
            );
          },
        ),
      );
    });
  }
}

class _EventList extends GetView<ManageTourEventController> {
  const _EventList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isEventLoading.value && controller.events.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.events.isEmpty) {
        return const Center(child: Text('Belum ada event.'));
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchEvents(),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            return EventCard(
              event: event,
              // PERBAIKAN: Sambungkan callback onEdit ke method controller
              onEdit: () => controller.goToUpsertEventView(event: event),
              // PERBAIKAN: Sambungkan callback onDelete ke method controller
              onDelete: () => controller.deleteEvent(event),
            );
          },
        ),
      );
    });
  }
}
