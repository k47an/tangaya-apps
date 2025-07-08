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
        indicatorColor: Primary.mainColor,
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
                    controller.goToUpsertTourView();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Tambah Event'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.goToUpsertEventView();
                  },
                ),
              ],
            ),
          ),
    );
  }
}

class _TourPackageList extends GetView<ManageTourEventController> {
  const _TourPackageList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              onEdit:
                  () => controller.goToUpsertTourView(tourPackage: tourPackage),
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
              onEdit: () => controller.goToUpsertEventView(event: event),
              onDelete: () => controller.deleteEvent(event),
            );
          },
        ),
      );
    });
  }
}
