import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/user_model.dart';
import 'package:tangaya_apps/app/data/services/auth_services.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rxn<User> currentUser = Rxn<User>();
  final Rxn<UserModel> userModel = Rxn<UserModel>();
  final RxString userRole = 'tamu'.obs;
  final RxBool isLoading = false.obs;

  static const String defaultRole = 'user';

  User? get user => currentUser.value;
  String get uid => user?.uid ?? '';
  String get userName => userModel.value?.name ?? user?.displayName ?? 'Tamu';
  String get userGender => userModel.value?.gender ?? '-';
  String get userPhone => userModel.value?.phone ?? '-';
  String get userAddress => userModel.value?.address ?? '-';
  String get userEmail => userModel.value?.email ?? user?.email ?? '-';

  String get userPhotoURL =>
      userModel.value?.photoUrl.isNotEmpty == true
          ? userModel.value!.photoUrl
          : user?.photoURL ?? 'assets/images/profile.png';

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authService.currentUser;
    if (user != null) {
      _initializeUserData();
    }
  }

  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final signedInUser = await _authService.signInWithGoogle();
      if (signedInUser == null) {
        Get.snackbar('Login dibatalkan', 'Akun Google tidak dipilih.');
        return false;
      }

      currentUser.value = signedInUser;
      await _authService.createUserIfNotExists(signedInUser);
      await _initializeUserData();

      return true;
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initializeUserData() async {
    if (user == null) return;

    final profile = await _authService.fetchUserProfile(user!.uid);
    userModel.value = profile;

    final role = await _authService.fetchUserRole(user!.uid);
    userRole.value = role;
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String gender,
    required String phone,
    required String address,
  }) async {
    if (user == null) return;

    try {
      if (user!.email != email) await user!.updateEmail(email);
      if (user!.displayName != name) await user!.updateDisplayName(name);
      await user!.reload();
      currentUser.value = FirebaseAuth.instance.currentUser;

      final updated = UserModel(
        uid: user!.uid,
        name: name,
        email: email,
        role: userModel.value?.role ?? defaultRole,
        gender: gender,
        phone: phone,
        address: address,
        photoUrl: userModel.value?.photoUrl ?? '',
      );

      await _authService.updateUserProfile(updated);
      userModel.value = updated;

      Get.snackbar('Sukses', 'Profil berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Update Gagal', e.toString());
    }
  }

  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _authService.signOut();
      currentUser.value = null;
      userModel.value = null;
      userRole.value = 'tamu';
      Get.offAllNamed(Routes.SIGNIN);
    } catch (e) {
      Get.snackbar('Logout Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
