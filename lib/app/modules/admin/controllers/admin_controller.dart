import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> ordersByMonth =
      <String, List<Map<String, dynamic>>>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchApprovedOrders();
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
      Get.snackbar('Error', 'Gagal mengambil data pengguna: $e');
    } finally {
      isLoading.value = false;
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

      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final timestamp = data['date'];
        DateTime? date;
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        } else if (timestamp is String) {
          date = DateTime.tryParse(timestamp);
        }

        if (date == null) continue;

        final monthKey = DateFormat('MMMM yyyy').format(date);

        final entry = {
          'packageTitle': data['packageTitle'] ?? 'Paket tidak diketahui',
          'name': data['name'] ?? 'Tanpa nama',
          'date': date,
          'peopleNames':
              (data['peopleNames'] is List) ? data['peopleNames'] : [],
        };

        grouped.putIfAbsent(monthKey, () => []).add(entry);
      }

      ordersByMonth.value = grouped;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data pesanan: $e');
    }
  }
}
