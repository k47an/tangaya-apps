import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/profile/controllers/profile_controller.dart';
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/utils/global_components/snackbar.dart';

class EditProfileWidget extends GetView<ProfileController> {
  const EditProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.userModel;
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      backgroundColor: Neutral.white4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Center(
        child: Text(
          "Edit Informasi Profil",
          style: bold.copyWith(fontSize: 18, color: Neutral.dark1),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller.nameController,
                decoration: _inputDecoration(
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
                decoration: _inputDecoration(
                  "Email",
                  Icons.email_outlined,
                  hint: "Email (tidak dapat diubah)",
                ),
                style: regular.copyWith(fontSize: 15, color: Neutral.dark4),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.phoneController,
                decoration: _inputDecoration(
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
                decoration: _inputDecoration(
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
              Obx(
                () => DropdownButtonFormField<String>(
                  value:
                      controller.selectedGender.value?.isNotEmpty == true
                          ? controller.selectedGender.value
                          : null,
                  decoration: _inputDecoration(
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
                            (val) =>
                                DropdownMenuItem(value: val, child: Text(val)),
                          )
                          .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis kelamin harus diisi';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(foregroundColor: Neutral.dark3),
          child: Text("Batal", style: semiBold.copyWith(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: () async {
            // Validasi form sebelum submit
            if (formKey.currentState?.validate() ?? false) {
              // Menampilkan loading dialog
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
              Get.back();

              if (success) {
                Get.back();
                CustomSnackBar.show(
                  context: context,
                  message: "Profil berhasil diperbarui.",
                  type: SnackBarType.success,
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Primary.mainColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: semiBold.copyWith(fontSize: 14),
          ),
          child: const Text("Simpan"),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
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
        borderSide: const BorderSide(color: Primary.mainColor, width: 1.5),
      ),
      filled: true,
      fillColor: Neutral.white3,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }
}
