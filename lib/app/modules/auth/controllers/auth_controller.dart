import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;

  var googleUser = Rxn<GoogleSignInAccount>();
  var currentUser = Rxn<User>();
  var userName = RxString('');
  var userEmail = RxString('');

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;

    if (currentUser.value != null) {
      userName.value = currentUser.value!.displayName ?? 'User';
      userEmail.value = currentUser.value!.email ?? 'No Email';
    }
  }

  // Login menggunakan akun Google
  Future<bool> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut(); // Logout dulu jika sudah login
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar('Login dibatalkan', 'Anda tidak memilih akun Google');
        return false;
      }

      this.googleUser.value = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        currentUser.value = userCredential.user;
        userName.value = userCredential.user!.displayName ?? 'Tidak ada nama';
        userEmail.value = userCredential.user!.email ?? 'Tidak ada email';

        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar('Error Login Google', e.toString());
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    googleUser.value = null;
    currentUser.value = null;
    userName.value = 'Tamu';
    userEmail.value = 'Tidak ada email';
    Get.offAllNamed(Routes.HOME);
  }
}
