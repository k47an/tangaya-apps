import 'package:flutter/material.dart';
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
  final RxBool isLoadingOrders = false.obs;

  final Rxn<UserModel> userModel = Rxn<UserModel>();

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': newStatus},
      );

      Get.back();

      Get.snackbar(
        "Berhasil",
        "Status pesanan berhasil diubah menjadi Lunas.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      fetchProcessedOrders();
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan saat memperbarui status: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading(true);
      await Future.wait([getUserData(), fetchUsers()]);
      await fetchProcessedOrders();
    } catch (e) {
      debugPrint('Gagal memuat data awal admin: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> getUserData() async {
    try {
      final uid = authController.currentUser.value?.uid;
      if (uid == null) {
        debugPrint('Error getUserData: UID is null');
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userModel.value = UserModel.fromMap({'id': doc.id, ...doc.data()!});
      } else {}
    } catch (e) {
      debugPrint('Error getUserData: $e');
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
      debugPrint('Error fetchUsers: $e');
    }
  }

  Future<void> fetchProcessedOrders() async {
    try {
      isLoadingOrders(true);
      final snapshot =
          await _firestore
              .collection('orders')
              .where('status', whereIn: ['cod_selected', 'paid', 'settlement'])
              .orderBy('bookingDate', descending: true)
              .get();

      final grouped = <String, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['bookingDate'] as Timestamp?;
        if (timestamp == null) {
          continue;
        }
        final date = timestamp.toDate();
        final monthKey = DateFormat('MMMM yyyy', 'id_ID').format(date);

        grouped.putIfAbsent(monthKey, () => []).add({
          'orderId': doc.id,
          'packageTitle':
              data['packageTitle'] ??
              data['eventTitle'] ??
              'Produk Tidak Diketahui',
          'customerName': data['customerName'] ?? 'Tanpa Nama',
          'bookingDate': date,
          'peopleNames': List<String>.from(data['peopleNames'] ?? []),
          'totalPrice': data['totalPrice'] as int? ?? 0,
          'status': data['status'] as String? ?? 'unknown',
          'paymentMethodType': data['paymentMethodType'] as String? ?? 'N/A',
        });
      }
      ordersByMonth.assignAll(grouped);
    } catch (e) {
      debugPrint('Error fetching processed orders: $e');
    } finally {
      isLoadingOrders(false);
    }
  }
}
