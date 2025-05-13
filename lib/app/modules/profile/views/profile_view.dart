import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';
import 'package:tangaya_apps/app/modules/profile/controllers/profile_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Neutral.white4,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Get.back(),
            ),
            iconTheme: const IconThemeData(color: Neutral.white1),
            centerTitle: true,
            backgroundColor: Primary.mainColor,
            title: Text(
              "Profile",
              style: semiBold.copyWith(
                fontSize: ScaleHelper.scaleTextForDevice(20),
                color: Neutral.white1,
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return Obx(() {
            if (!controller.dataLoaded.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(14)),
              child: Container(
                decoration: BoxDecoration(
                  color: Neutral.white3,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                padding: EdgeInsets.all(ScaleHelper.scaleWidthForDevice(16)),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: ScaleHelper.scaleWidthForDevice(60),
                          height: ScaleHelper.scaleWidthForDevice(60),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(auth.userPhotoURL),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: ScaleHelper.scaleWidthForDevice(16)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.userName,
                              style: bold.copyWith(
                                fontSize: ScaleHelper.scaleTextForDevice(20),
                                color: Neutral.dark1,
                              ),
                            ),
                            Text(
                              "Pengunjung",
                              style: semiBold.copyWith(
                                fontSize: ScaleHelper.scaleTextForDevice(14),
                                color: Neutral.dark4,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            controller.isEditing.value = true;
                            _showEditDialog(context, controller, auth);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Primary.mainColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Edit",
                                style: semiBold.copyWith(
                                  fontSize: 14,
                                  color: Primary.mainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScaleHelper.scaleHeightForDevice(24)),
                    Row(
                      children: [
                        Text(
                          "Data Pribadi",
                          style: bold.copyWith(
                            fontSize: 16,
                            color: Neutral.dark1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Primary.mainColor),
                    const SizedBox(height: 8),
                    _dataPribadiTextField("Email", auth.user?.email ?? ""),
                    const SizedBox(height: 15),
                    _dataPribadiTextField(
                      "Jenis Kelamin",
                      controller.selectedGender.value ??
                          "Masukkan Jenis Kelamin",
                    ),
                    const SizedBox(height: 15),
                    _dataPribadiTextField(
                      "Nomor HP",
                      controller.phoneController.text == ""
                          ? "Masukkan Nomor HP"
                          : controller.phoneController.text,
                    ),
                    const SizedBox(height: 15),
                    _alamatTextField(
                      "Alamat",
                      controller.addressController.text == ""
                          ? "Masukkan Alamat"
                          : controller.addressController.text,
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    ProfileController controller,
    AuthController auth,
  ) {
    final TextEditingController emailController = TextEditingController(
      text: auth.user?.email,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller.nameController,

                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  enabled: false,
                ),
                TextField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP',
                    hintText: '08..',
                  ),
                ),
                TextField(
                  controller: controller.addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    hintText: 'desa, kecamatan, kabupaten, provinsi',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Jenis Kelamin'),
                    const Spacer(),
                    Obx(() {
                      return DropdownButton<String?>(
                        value: controller.selectedGender.value,
                        hint: const Text('pilih'), // Show hint when null
                        onChanged: (String? newValue) {
                          controller.updateGender(newValue);
                        },
                        items:
                            <String>['Laki-laki', 'Perempuan']
                                .map(
                                  (value) => DropdownMenuItem<String?>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
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
                if (controller.nameController.text.isEmpty ||
                    controller.phoneController.text.isEmpty ||
                    controller.addressController.text.isEmpty ||
                    controller.selectedGender.value == null) {
                  Get.snackbar(
                    "Error",
                    "Harap lengkapi semua data.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => const Center(child: CircularProgressIndicator()),
                );

                final success = await controller.saveUserData();
                Navigator.of(context).pop(); // close loading

                if (success) {
                  await controller.loadUserData();
                  Navigator.of(dialogContext).pop(); // close dialog
                } else {
                  Get.snackbar(
                    "Gagal",
                    "Gagal menyimpan data.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Widget _dataPribadiTextField(String title, String data) {
    return Row(
      children: [
        Text(title, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
        const Spacer(),
        Text(data, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
      ],
    );
  }

  Widget _alamatTextField(String title, String data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: bold.copyWith(fontSize: 12, color: Neutral.dark1)),
        const Spacer(),
        Expanded(
          child: Text(
            data,
            style: bold.copyWith(fontSize: 12, color: Neutral.dark1),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
