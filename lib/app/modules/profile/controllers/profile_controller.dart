import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/user_model.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final selectedGender = RxnString();
  final genderOptions = ['Laki-laki', 'Perempuan'];
  final isEditing = false.obs;
  final dataLoaded = false.obs;

  UserModel? userModel;

  final authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void prepareForm() {
    nameController.text = userModel?.name ?? '';
    phoneController.text = userModel?.phone ?? '';
    addressController.text = userModel?.address ?? '';
    selectedGender.value = userModel?.gender;
    if (selectedGender.value != 'Laki-laki' &&
        selectedGender.value != 'Perempuan') {
      selectedGender.value = null; // Atau nilai default lain yang valid
    }
  }

  Future<void> loadUserData() async {
    try {
      dataLoaded.value = false; // Set loading state
      final user = authController.userModel.value;
      if (user != null) {
        userModel = user;
        _fillFormFields();
        dataLoaded.value = true;
      } else {
        dataLoaded.value = true; // Set loaded meskipun user null
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      dataLoaded.value = false; // Set loading state ke false saat error
      Get.snackbar("Gagal", "Gagal memuat data profil: $e",
          snackPosition: SnackPosition.BOTTOM); // Show error
    }
  }

  void _fillFormFields() {
    if (userModel != null) {
      nameController.text = userModel!.name;
      phoneController.text = userModel!.phone;
      addressController.text = userModel!.address;
      selectedGender.value = userModel!.gender;
    }
  }

  void updateGender(String? value) {
    selectedGender.value = value;
  }

  Future<bool> saveUserData() async {
    try {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final address = addressController.text.trim();
      final gender = selectedGender.value ?? '';

      final success = await authController.updateUserProfile( // Tangkap nilai kembalian
        name: name,
        email: userModel?.email ?? '',
        gender: gender,
        phone: phone,
        address: address,
      );

      if (success) { // Periksa keberhasilan
        await loadUserData(); // Muat ulang data
        return true;
      } else {
        return false; // Kembalikan false jika update gagal
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      Get.snackbar("Gagal", "Gagal menyimpan data profil: $e",
          snackPosition: SnackPosition.BOTTOM); // Show error
      return false;
    }
  }

  void logout() {
    Get.find<AuthController>().signOut();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}