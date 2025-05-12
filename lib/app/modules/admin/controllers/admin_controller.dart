import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable list untuk menyimpan data pengguna
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  // Observable untuk loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers(); // ambil data saat controller diinisialisasi
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore.collection('users').get();

      final userList =
          snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();

      users.assignAll(userList);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
