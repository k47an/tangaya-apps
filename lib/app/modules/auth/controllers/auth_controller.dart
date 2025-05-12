import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive user and profile data
  final Rxn<User> currentUser = Rxn<User>();
  final RxString userRole = 'tamu'.obs;
  final RxBool isLoading = false.obs;

  // Additional user profile data
  final RxString firestoreUserName = ''.obs;
  final RxString userGender = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;

  // Constants
  static const String defaultRole = 'user';

  // Getters
  User? get user => currentUser.value;
  String get userName =>
      firestoreUserName.isNotEmpty
          ? firestoreUserName.value
          : user?.displayName ?? 'Tamu';
  String get userPhotoURL =>
      user?.photoURL?.isNotEmpty == true
          ? user!.photoURL!
          : 'assets/images/profile.png';
  String get uid => user?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    if (user != null) {
      _initializeUserData();
    }
  }

  /// Inisialisasi data pengguna saat login atau app dibuka
  Future<void> _initializeUserData() async {
    await Future.wait([fetchUserProfile(), fetchUserRole()]);
  }

  /// Login menggunakan akun Google
  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        Get.snackbar('Login dibatalkan', 'Akun Google tidak dipilih.');
        return false;
      }

      final gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      currentUser.value = userCredential.user;

      if (user != null) {
        await _createUserIfNotExists();
        await _initializeUserData();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Error', e.message ?? 'Terjadi kesalahan saat login.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Buat data user di Firestore jika belum ada
  Future<void> _createUserIfNotExists() async {
    final docRef = _firestore.collection('users').doc(user!.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'name': user!.displayName ?? 'No Name',
        'email': user!.email ?? 'No Email',
        'role': defaultRole,
        'gender': '',
        'phone': '',
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Ambil role dari Firestore
  Future<void> fetchUserRole() async {
    final uid = user?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    userRole.value = doc.data()?['role'] ?? defaultRole;
  }

  /// Ambil profil pengguna dari Firestore
  Future<void> fetchUserProfile() async {
    final uid = user?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      firestoreUserName.value = data['name'] ?? '';
      userGender.value = data['gender'] ?? '';
      userPhone.value = data['phone'] ?? '';
      userAddress.value = data['address'] ?? '';
    }
  }

  /// Perbarui profil pengguna
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String gender,
    required String phone,
    required String address,
  }) async {
    try {
      if (user == null) return;

      // Update email dan nama di FirebaseAuth jika berubah
      if (user!.email != email) {
        await user!.updateEmail(email);
      }

      if (user!.displayName != name) {
        await user!.updateDisplayName(name);
      }

      await user!.reload();
      currentUser.value = _auth.currentUser;

      // Update Firestore
      await _firestore.collection('users').doc(user!.uid).update({
        'name': name,
        'email': email,
        'gender': gender,
        'phone': phone,
        'address': address,
      });

      // Update lokal state
      firestoreUserName.value = name;
      userGender.value = gender;
      userPhone.value = phone;
      userAddress.value = address;

      Get.snackbar('Sukses', 'Profil berhasil diperbarui');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Gagal memperbarui', e.message ?? 'Terjadi kesalahan');
    }
  }

  /// Logout user dari Firebase dan Google
  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();

      // Reset state
      currentUser.value = null;
      userRole.value = 'tamu';
      firestoreUserName.value = '';
      userGender.value = '';
      userPhone.value = '';
      userAddress.value = '';
    } catch (e) {
      Get.snackbar('Logout Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
