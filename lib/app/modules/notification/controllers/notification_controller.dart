import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<DocumentSnapshot> orders = <DocumentSnapshot>[].obs;

  RxString role = ''.obs;
  RxString uid = ''.obs;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration.zero, () {
      final auth = Get.find<AuthController>();
      role.value = auth.userRole.value;
      uid.value = auth.uid;

      fetchOrders(role.value, uid.value);
    });
  }

  void fetchOrders(String role, String userId) {
    if (role == 'admin') {
      _firestore
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
            orders.value = snapshot.docs;
          });
    } else {
      _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
            orders.value = snapshot.docs;
          });
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Sukses",
        "Pemesanan telah ${newStatus == 'approved' ? 'disetujui' : 'ditolak'}.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memperbarui status: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
