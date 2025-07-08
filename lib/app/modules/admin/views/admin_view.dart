import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/home/controllers/home_controller.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/app/modules/admin/controllers/admin_controller.dart';
import 'package:tangaya_apps/app/data/models/user_model.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  String _displayValue(String? value) =>
      (value == null || value.trim().isEmpty) ? '-' : value;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final homeC = Get.find<HomeController>();
        homeC.refreshData();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Neutral.white4,
          appBar: AppBar(
            backgroundColor: Primary.darkColor,
            centerTitle: true,
            elevation: 0,
            title: Text(
              "Profil Admin",
              style: semiBold.copyWith(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                final homeC = Get.find<HomeController>();
                homeC.refreshData();
                Get.back();
              },
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: Obx(() {
            final isLoading = controller.isLoading.value;
            final user = controller.userModel.value;

            if (isLoading || user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildInfoSection(user),
                  const SizedBox(height: 24),
                  _buildNavigationSection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.white3,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage:
                user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : const AssetImage("assets/images/default_profile.png")
                        as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: bold.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(user.role, style: medium.copyWith(color: Neutral.dark4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.white3,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Data Pribadi", style: bold.copyWith(fontSize: 16)),
          const Divider(color: Primary.mainColor, thickness: 1),
          const SizedBox(height: 8),
          _infoRow("Email", user.email),
          _infoRow("Jenis Kelamin", _displayValue(user.gender)),
          _infoRow("Nomor HP", _displayValue(user.phone)),
          _infoRow("Alamat", _displayValue(user.address), multiLine: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: semiBold.copyWith(fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: regular.copyWith(fontSize: 14),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.white3,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Navigasi", style: bold.copyWith(fontSize: 16)),
          const Divider(color: Primary.mainColor, thickness: 1),
          const SizedBox(height: 8),
          _navigableRow(
            "Manajemen Paket Wisata dan Event",
            Routes.MANAGE_EVENT_TOUR,
          ),
          _navigableRow("Riwayat Pemesanan", Routes.ORDERVIEW),
        ],
      ),
    );
  }

  Widget _navigableRow(String label, String routeName) {
    return InkWell(
      onTap: () => Get.toNamed(routeName),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              label,
              style: regular.copyWith(fontSize: 14, color: Neutral.dark3),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Primary.mainColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () => Get.find<AuthController>().signOut(),
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text("Logout", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
