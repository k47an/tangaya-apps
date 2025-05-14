import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tangaya_apps/app/data/models/user_model.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.find<AuthController>();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> ordersByMonth =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxBool isLoading = false.obs;

  final Rxn<UserModel> userModel = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading(true);
      await Future.wait([getUserData(), fetchUsers(), fetchApprovedOrders()]);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data awal:\n$e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> getUserData() async {
    try {
      final uid = authController.currentUser.value?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userModel.value = UserModel.fromMap({'id': doc.id, ...doc.data()!});
        print('✅ Admin user loaded: ${userModel.value?.toMap()}');
      }
    } catch (e) {
      print('❌ Error getUserData: $e');
      Get.snackbar('Error', 'Gagal mengambil data admin:\n$e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final userList =
          snapshot.docs
              .map((doc) => UserModel.fromMap({'id': doc.id, ...doc.data()}))
              .toList();
      users.assignAll(userList);
    } catch (e) {
      print('❌ Error fetchUsers: $e');
      Get.snackbar('Error', 'Gagal mengambil data pengguna:\n$e');
    }
  }

  Future<void> fetchApprovedOrders() async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('status', isEqualTo: 'approved')
              .orderBy('date', descending: true)
              .get();

      final grouped = <String, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final date =
            (data['date'] is Timestamp)
                ? (data['date'] as Timestamp).toDate()
                : DateTime.tryParse(data['date'].toString());

        if (date == null) continue;

        final monthKey = DateFormat('MMMM yyyy').format(date);

        grouped.putIfAbsent(monthKey, () => []).add({
          'packageTitle': data['packageTitle'] ?? 'Paket tidak diketahui',
          'name': data['name'] ?? 'Tanpa nama',
          'date': date,
          'peopleNames': List<String>.from(data['peopleNames'] ?? []),
        });
      }

      ordersByMonth.assignAll(grouped);
    } catch (e) {
      print('❌ Error fetchApprovedOrders: $e');
      Get.snackbar('Error', 'Gagal memuat data pesanan:\n$e');
    }
  }
}
