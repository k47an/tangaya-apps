import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  // Reactive state
  final isEditing = false.obs;
  final selectedGender = Rx<String?>(null); // Make it nullable
  final dataLoaded = false.obs;

  // Text editing controllers
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  // Dependency
  late final AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();

    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    loadUserData();
  }

  /// Ambil data profil dari AuthController & tampilkan di TextField
  Future<void> loadUserData() async {
    try {
      await _authController.fetchUserProfile();

      nameController.text =
          _authController.firestoreUserName.value.isNotEmpty
              ? _authController.firestoreUserName.value
              : '';
      selectedGender.value =
          _authController.userGender.value.isNotEmpty
              ? _authController.userGender.value
              : null; // Use null if no gender
      phoneController.text =
          (_authController.userPhone.value.isNotEmpty
              ? _authController.userPhone.value
              : null)!;
      addressController.text =
          (_authController.userAddress.value.isNotEmpty
              ? _authController.userAddress.value
              : null)!;

      dataLoaded.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data pengguna: $e');
      dataLoaded.value = true;
    }
  }

  /// Simpan data yang diedit ke Firestore & Firebase Auth
  Future<bool> saveUserData() async {
    final email = _authController.user?.email ?? '';

    if (!_validateInputs()) return false;

    try {
      await _authController.updateUserProfile(
        name: nameController.text.trim(),
        email: email,
        gender: selectedGender.value ?? '', // Use empty string if null
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
      );

      isEditing.value = false;
      Get.snackbar('Sukses', 'Profil berhasil diperbarui');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan profil: $e');
      return false;
    }
  }

  /// Validasi semua input sebelum menyimpan
  bool _validateInputs() {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        selectedGender.value == null) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return false;
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(phoneController.text.trim())) {
      Get.snackbar('Error', 'Nomor HP tidak valid');
      return false;
    }

    return true;
  }

  void updateGender(String? gender) {
    selectedGender.value = gender;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
