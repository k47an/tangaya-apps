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
  final RxBool isLoadingOrders =
      false.obs; // State loading khusus untuk pesanan

  final Rxn<UserModel> userModel = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading(true);
      // getUserData dan fetchUsers bisa berjalan paralel
      // fetchApprovedOrders dipanggil terpisah karena mungkin butuh loading state sendiri
      await Future.wait([getUserData(), fetchUsers()]);
      await fetchProcessedOrders(); // Mengganti nama metode agar lebih sesuai
    } catch (e) {
      print('❌ Error loadInitialData: $e');
      Get.snackbar('Error', 'Gagal memuat data awal:\n$e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> getUserData() async {
    try {
      final uid = authController.currentUser.value?.uid;
      if (uid == null) {
        print('❌ Error getUserData: UID is null');
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userModel.value = UserModel.fromMap({'id': doc.id, ...doc.data()!});
        print('✅ Admin user loaded: ${userModel.value?.name}');
      } else {
        print('❌ Admin user document not found for UID: $uid');
      }
    } catch (e) {
      print('❌ Error getUserData: $e');
      Get.snackbar('Error', 'Gagal mengambil data admin:\n$e');
    }
  }

  Future<void> fetchUsers() async {
    // ... (kode fetchUsers tetap sama) ...
    try {
      final snapshot = await _firestore.collection('users').get();
      final userList =
          snapshot.docs
              .map((doc) => UserModel.fromMap({'id': doc.id, ...doc.data()!}))
              .toList();
      users.assignAll(userList);
    } catch (e) {
      print('❌ Error fetchUsers: $e');
      Get.snackbar('Error', 'Gagal mengambil data pengguna:\n$e');
    }
  }

  // Mengganti nama metode dan merevisi query
  Future<void> fetchProcessedOrders() async {
    try {
      isLoadingOrders(true); // State loading untuk daftar pesanan
      final snapshot =
          await _firestore
              .collection('orders')
              .where(
                'status',
                whereIn: [
                  'cod_selected', // COD yang sudah dipilih user & menunggu kirim
                  'paid', // Pembayaran online berhasil (status generik Anda)
                  'settlement', // Pembayaran online berhasil (status Midtrans)
                ],
              )
              .orderBy(
                'bookingDate',
                descending: true,
              ) // Menggunakan bookingDate
              .get();

      final grouped = <String, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Pastikan bookingDate ada dan bertipe Timestamp
        final timestamp = data['bookingDate'] as Timestamp?;
        if (timestamp == null) {
          print(
            "⚠️ Skipping order ${doc.id} due to missing or invalid bookingDate.",
          );
          continue;
        }
        final date = timestamp.toDate();
        final monthKey = DateFormat(
          'MMMM yyyy',
          'id_ID',
        ).format(date); // Format 'id_ID' untuk nama bulan

        grouped.putIfAbsent(monthKey, () => []).add({
          'orderId': doc.id, // Tambahkan orderId untuk referensi jika perlu
          'packageTitle':
              data['packageTitle'] ??
              data['eventTitle'] ??
              'Produk Tidak Diketahui',
          'customerName':
              data['customerName'] ?? 'Tanpa Nama', // Menggunakan customerName
          'bookingDate': date, // Kirim sebagai DateTime
          'peopleNames': List<String>.from(data['peopleNames'] ?? []),
          'totalPrice': data['totalPrice'] as int? ?? 0,
          'status': data['status'] as String? ?? 'unknown',
          'paymentMethodType': data['paymentMethodType'] as String? ?? 'N/A',
        });
      }
      ordersByMonth.assignAll(grouped);
      print(
        '✅ Processed orders fetched and grouped: ${ordersByMonth.length} months',
      );
    } catch (e) {
      print('❌ Error fetchProcessedOrders: $e');
      Get.snackbar(
        'Error Memuat Pesanan',
        'Gagal memuat data pesanan terproses:\n$e',
      );
    } finally {
      isLoadingOrders(false);
    }
  }
}
