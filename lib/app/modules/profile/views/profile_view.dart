import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/profile/controllers/profile_controller.dart';
import 'package:tangaya_apps/constant/constant.dart'; // Pastikan path ini benar

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            AppBar(
              backgroundColor: Primary.darkColor,
              centerTitle: true,
              elevation: 0,
              title: Text(
                // Judul AppBar tetap di tengah
                "Profil Saya",
                style: semiBold.copyWith(color: Colors.white, fontSize: 18),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              actions: [
                // Tombol Edit Profil dipindahkan ke sini
                TextButton.icon(
                  onPressed: () {
                    controller.prepareForm();
                    _showEditDialog(context);
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 18,
                  ),
                  label: Text(
                    "Edit",
                    style: regular.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            // Header yang diperpanjang dengan tata letak modern (foto kiri)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Primary.darkColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                24,
              ), // Padding atas dikurangi sedikit
              child: Obx(() {
                final user = controller.userModel;
                if (!controller.dataLoaded.value && user == null) {
                  return const SizedBox(
                    height: 100, // Tinggi placeholder disesuaikan
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    ),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 38, // Radius foto disesuaikan
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage:
                          user?.photoUrl != null && user!.photoUrl.isNotEmpty
                              ? NetworkImage(user.photoUrl)
                              : const AssetImage(
                                    "assets/images/default_profile.png",
                                  )
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.name ?? 'Nama Pengguna',
                            style: bold.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            ), // Ukuran font nama
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (user?.role != null && user!.role.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                user.role == 'user'
                                    ? 'Pengunjung'
                                    : (user.role.capitalizeFirst ?? user.role),
                                style: medium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          // Tombol Edit Profil sudah dipindah ke AppBar
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Container(
                color: Neutral.white1,
                child: Obx(() {
                  if (!controller.dataLoaded.value &&
                      controller.userModel == null) {
                    return const SizedBox.shrink();
                  }
                  if (!controller.dataLoaded.value &&
                      controller.userModel != null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Primary.mainColor,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.loadUserData(),
                    color: Primary.mainColor,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoSection(context),
                          const SizedBox(
                            height: 24,
                          ), // Jarak sebelum tombol logout
                          _buildLogoutButton(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final user = controller.userModel;

    String displayPhone =
        controller.phoneController.text.trim().isEmpty &&
                (user?.phone.isEmpty ?? true)
            ? "-"
            : controller.phoneController.text.trim().isNotEmpty
            ? controller.phoneController.text
            : user?.phone ?? "-";

    String displayAddress =
        controller.addressController.text.trim().isEmpty &&
                (user?.address.isEmpty ?? true)
            ? "-"
            : controller.addressController.text.trim().isNotEmpty
            ? controller.addressController.text
            : user?.address ?? "-";

    String displayGender =
        controller.selectedGender.value?.isEmpty ?? true
            ? (user?.gender.isEmpty ?? true ? "-" : user!.gender)
            : controller.selectedGender.value!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Neutral.white4,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 10.0, top: 4.0),
            child: Text(
              "Informasi Pribadi",
              style: bold.copyWith(fontSize: 18, color: Neutral.dark1),
            ),
          ),
          const Divider(
            thickness: 0.5,
            height: 16,
            indent: 16,
            endIndent: 16,
            color: Neutral.dark4,
          ),
          _infoListTile(
            context,
            icon: Icons.email_outlined,
            label: "Email",
            value: user?.email ?? "-",
          ),
          _infoListTile(
            context,
            icon: Icons.person_outline_rounded,
            label: "Jenis Kelamin",
            value: displayGender,
          ),
          _infoListTile(
            context,
            icon: Icons.phone_iphone_rounded,
            label: "Nomor HP",
            value: displayPhone,
          ),
          _infoListTile(
            context,
            icon: Icons.location_on_outlined,
            label: "Alamat",
            value: displayAddress,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _infoListTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isMultiLine ? 8 : 4,
      ),
      leading: Icon(icon, color: Primary.mainColor, size: 24),
      title: Text(
        label,
        style: medium.copyWith(fontSize: 13, color: Neutral.dark3),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: Text(
          value.isEmpty ? "-" : value,
          style: regular.copyWith(
            fontSize: 15,
            color: Neutral.dark1,
            height: isMultiLine ? 1.4 : 1.2,
          ),
          textAlign: TextAlign.start,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
      dense: !isMultiLine,
    );
  }

  // Perubahan pada tombol Logout
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      // Bungkus dengan SizedBox untuk mengatur lebar jika perlu
      width:
          double
              .infinity, // Atau lebar tertentu, misal MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
        label: Text(
          "Logout", // Teks diubah
          style: semiBold.copyWith(color: Colors.white, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 12), // Padding vertikal
          minimumSize: const Size(0, 46), // Tinggi tombol dikurangi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final user = controller.userModel;

    InputDecoration inputDecoration(
      String label,
      IconData prefixIcon, {
      String? hint,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: regular.copyWith(fontSize: 15, color: Neutral.dark3),
        hintText: hint ?? "Masukkan $label",
        hintStyle: regular.copyWith(fontSize: 14, color: Neutral.dark5),
        prefixIcon: Icon(
          prefixIcon,
          color: Primary.mainColor.withOpacity(0.8),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Neutral.dark4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Neutral.dark4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Primary.mainColor, width: 1.5),
        ),
        filled: true,
        fillColor: Neutral.white3,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      );
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Neutral.white4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        title: Center(
          child: Text(
            "Edit Informasi Profil",
            style: bold.copyWith(fontSize: 18, color: Neutral.dark1),
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller.nameController,
                  decoration: inputDecoration(
                    "Nama Lengkap",
                    Icons.person_outline_rounded,
                  ),
                  style: regular.copyWith(fontSize: 15, color: Neutral.dark1),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Nama tidak boleh kosong'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: TextEditingController(text: user?.email ?? ''),
                  enabled: false,
                  decoration: inputDecoration(
                    "Email",
                    Icons.email_outlined,
                    hint: "Email (tidak dapat diubah)",
                  ),
                  style: regular.copyWith(fontSize: 15, color: Neutral.dark4),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.phoneController,
                  decoration: inputDecoration(
                    "Nomor HP",
                    Icons.phone_iphone_rounded,
                  ),
                  keyboardType: TextInputType.phone,
                  style: regular.copyWith(fontSize: 15, color: Neutral.dark1),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Nomor HP tidak boleh kosong'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.addressController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: inputDecoration(
                    "Alamat",
                    Icons.location_on_outlined,
                  ),
                  style: regular.copyWith(fontSize: 15, color: Neutral.dark1),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Alamat tidak boleh kosong'
                              : null,
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value:
                        controller.selectedGender.value?.isNotEmpty == true
                            ? controller.selectedGender.value
                            : null,
                    decoration: inputDecoration(
                      "Jenis Kelamin",
                      Icons.wc_rounded,
                      hint: "Pilih Jenis Kelamin",
                    ),
                    hint: Text(
                      'Pilih Jenis Kelamin',
                      style: regular.copyWith(color: Neutral.dark5),
                    ),
                    style: regular.copyWith(fontSize: 15, color: Neutral.dark1),
                    onChanged: controller.updateGender,
                    items:
                        ['Laki-laki', 'Perempuan']
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              ),
                            )
                            .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis kelamin harus diisi';
                      }
                      return null;
                    },
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Neutral.dark3,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Batal", style: semiBold.copyWith(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              if (controller.nameController.text.trim().isEmpty ||
                  controller.phoneController.text.trim().isEmpty ||
                  controller.addressController.text.trim().isEmpty ||
                  (controller.selectedGender.value == null ||
                      controller.selectedGender.value!.isEmpty)) {
                Get.snackbar(
                  "Validasi Gagal",
                  "Semua field wajib diisi.",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red.withOpacity(0.9),
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 8,
                  icon: const Icon(Icons.error_outline, color: Colors.white),
                );
                return;
              }

              Get.dialog(
                const AlertDialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Center(
                    child: CircularProgressIndicator(color: Primary.mainColor),
                  ),
                ),
                barrierDismissible: false,
              );

              final success = await controller.saveUserData();
              Get.back(); // close loading

              if (success) {
                await controller.loadUserData();
                Get.back(); // close edit dialog
                // Get.snackbar(
                //   "Berhasil",
                //   "Data profil berhasil diperbarui.",
                //   snackPosition: SnackPosition.TOP,
                //   backgroundColor: .withOpacity(0.9),
                //   colorText: Colors.white,
                //   margin: const EdgeInsets.all(12),
                //   borderRadius: 8,
                //   icon: const Icon(
                //     Icons.check_circle_outline,
                //     color: Colors.white,
                //   ),
                // );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Primary.mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              textStyle: semiBold.copyWith(fontSize: 14),
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
