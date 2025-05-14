import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/profile/controllers/profile_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.white4,
      appBar: AppBar(
        backgroundColor: Primary.mainColor,
        centerTitle: true,
        elevation: 0,
        title: Text("Profil", style: semiBold.copyWith(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Obx(() {
        if (!controller.dataLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildInfoSection(),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    final user = controller.userModel;

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
            backgroundImage: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                ? NetworkImage(user.photoUrl)
                : const AssetImage("assets/images/default_profile.png")
                    as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? '-', style: bold.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(user?.role ?? '-', style: medium.copyWith(color: Neutral.dark4)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Primary.mainColor),
            onPressed: () {
              controller.prepareForm();
              _showEditDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final user = controller.userModel;

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
          _infoRow("Email", user?.email ?? "-"),
          _infoRow("Jenis Kelamin", controller.selectedGender.value ?? "-"),
          _infoRow("Nomor HP", controller.phoneController.text.isEmpty ? "-" : controller.phoneController.text),
          _infoRow("Alamat", controller.addressController.text.isEmpty ? "-" : controller.addressController.text, multiLine: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: Text(label, style: semiBold.copyWith(fontSize: 14))),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: regular.copyWith(fontSize: 14),
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: controller.logout,
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text("Logout", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEditDialog() {
    final user = controller.userModel;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Profil"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: user?.email ?? ''),
                enabled: false,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.phoneController,
                decoration: const InputDecoration(labelText: 'Nomor HP'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Jenis Kelamin"),
                  const SizedBox(height: 8),
                  Obx(() {
                    return DropdownButtonFormField<String>(
                      value: controller.selectedGender.value,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('Pilih Jenis Kelamin'),
                      onChanged: controller.updateGender,
                      items: ['Laki-laki', 'Perempuan']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.nameController.text.trim().isEmpty ||
                  controller.phoneController.text.trim().isEmpty ||
                  controller.addressController.text.trim().isEmpty ||
                  controller.selectedGender.value == null) {
                Get.snackbar("Validasi Gagal", "Semua field harus diisi.");
                return;
              }

              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

              final success = await controller.saveUserData();
              Get.back(); // close loading

              if (success) {
                await controller.loadUserData();
                Get.back(); // close dialog
              } else {
                Get.snackbar("Gagal", "Gagal menyimpan data", snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text("Simpan"),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ],
      ),
    );
  }
}
