import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart'; 
import 'package:tangaya_apps/app/data/services/midtrans_service.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final MidtransService _midtransService;

  RxList<DocumentSnapshot> orders = <DocumentSnapshot>[].obs;
  RxString role = ''.obs;
  RxString uid = ''.obs;

  final RxBool isProcessingPayment =
      false.obs;
  final RxBool isAdminActionInProgress = false.obs; // Untuk aksi admin
  final RxBool isUserChoosingCod = false.obs; // Untuk user memilih metode COD

  @override
  void onInit() {
    super.onInit();
    _midtransService =
        Get.isRegistered<MidtransService>()
            ? Get.find<MidtransService>()
            : MidtransService();
    final authC = Get.find<AuthController>();

    void setupController(String currentUid, String currentRole) {
      uid.value = currentUid;
      role.value = currentRole;
      // Jangan fetch orders jika role tamu atau uid kosong
      if (uid.value.isNotEmpty &&
          role.value.isNotEmpty &&
          currentRole != 'tamu') {
        fetchOrders(role.value, uid.value);
      } else {
        orders.clear(); // Kosongkan daftar pesanan jika tidak memenuhi syarat
      }
    }

    // Ambil nilai awal saat controller diinisialisasi
    String initialUid = authC.uid;
    // Pastikan userRole.value di AuthController adalah RxString dan sudah diinisialisasi
    String initialRole =
        authC.userRole.value.isNotEmpty ? authC.userRole.value : 'tamu';

    setupController(initialUid, initialRole);

    // Dengarkan perubahan pada currentUser dari AuthController
    ever(authC.currentUser, (fb_auth.User? firebaseUserCallback) {
      print(
        "NotificationController: Auth currentUser changed: ${firebaseUserCallback?.uid}",
      );
      String newRole = 'tamu'; // Default jika logout
      String newUid = '';

      if (firebaseUserCallback != null) {
        newUid = firebaseUserCallback.uid;
        // Asumsi AuthController sudah mengupdate userRole.value saat user login/berubah
        // atau Anda memiliki mekanisme untuk mendapatkan role terbaru di sini
        newRole =
            authC.userRole.value.isNotEmpty ? authC.userRole.value : 'tamu';
      }
      setupController(newUid, newRole);
    });

    // Log jika user belum login saat inisialisasi awal
    if (authC.currentUser.value == null && initialUid.isEmpty) {
      print(
        "NotificationController: Initial state - User not logged in. Waiting for auth changes.",
      );
    }
  }

  void fetchOrders(String userRole, String userId) {
    if ((userRole != 'admin' && userId.isEmpty) || userRole == 'tamu') {
      print(
        "NotificationController: User ID kosong atau role tamu, tidak dapat fetch orders.",
      );
      orders.clear();
      return;
    }

    Query query;
    if (userRole == 'admin') {
      print(
        "DEBUG: NotificationController - Fetching orders for ADMIN (status: pending_approval)",
      );
      query = _firestore
          .collection('orders')
          .where('status', isEqualTo: 'pending_approval')
          .orderBy('orderTimestamp', descending: true);
    } else {
      print(
        "DEBUG: NotificationController - Fetching orders for USER: $userId",
      );
      query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true);
    }

    query.snapshots().listen(
      (snapshot) {
        print(
          "DEBUG: NotificationController - Orders stream update. Fetched: ${snapshot.docs.length} orders for role: $userRole",
        );
        orders.value = snapshot.docs;
      },
      onError: (error) {
        print("Error fetching orders (NotificationController): $error");
        Get.snackbar(
          "Error Data",
          "Gagal memuat pesanan: $error. Pastikan Indeks Firestore sudah dibuat.",
        );
      },
    );
  }

  Future<void> processAdminAction(DocumentSnapshot order, String action) async {
    if (isAdminActionInProgress.value) return;
    isAdminActionInProgress.value = true;

    String orderId = order.id;
    if (!order.exists) {
      Get.snackbar("Error", "Data pesanan tidak lagi ditemukan.");
      isAdminActionInProgress.value = false;
      return;
    }
    Map<String, dynamic> orderData = order.data() as Map<String, dynamic>;
    String currentStatus = orderData['status'] as String? ?? '';
    String newStatus = '';

    if (action == 'approve') {
      if (currentStatus == 'pending_approval') {
        newStatus = 'awaiting_payment_choice';
      } else {
        Get.snackbar(
          "Info",
          "Pesanan ini tidak dalam status 'pending_approval'.",
        );
        isAdminActionInProgress.value = false;
        return;
      }
    } else if (action == 'reject') {
      newStatus = 'rejected_by_admin';
    } else {
      Get.snackbar("Error Aksi", "Tindakan tidak dikenal: $action");
      isAdminActionInProgress.value = false;
      return;
    }

    print(
      "DEBUG: processAdminAction - OrderID: $orderId, Action: $action, NewStatus: $newStatus",
    );

    if (newStatus.isNotEmpty) {
      try {
        await _firestore.collection('orders').doc(orderId).update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        String successMessage = "Pesanan telah ";
        if (newStatus == 'rejected_by_admin') {
          successMessage += 'ditolak.';
        } else if (newStatus == 'awaiting_payment_choice') {
          successMessage +=
              'disetujui. Menunggu pilihan pembayaran dari pengguna.';
        } else {
          successMessage += 'diproses (status: $newStatus).';
        }
        Get.snackbar(
          "Sukses",
          successMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor:
              (newStatus != 'rejected_by_admin') ? Colors.green : Colors.red,
          colorText: Colors.white,
        );
      } catch (e) {
        print(
          "DEBUG: processAdminAction - Firestore update FAILED for OrderID: $orderId. Error: $e",
        );
        Get.snackbar("Error Update", "Gagal memperbarui status pesanan: $e");
      } finally {
        isAdminActionInProgress.value = false;
      }
    } else {
      isAdminActionInProgress.value = false;
    }
  }

  Future<void> userSelectsCodPayment(String orderId) async {
    if (isUserChoosingCod.value) return;
    isUserChoosingCod.value = true; // Menggunakan flag yang benar
    print("DEBUG: userSelectsCodPayment - OrderID: $orderId");

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cod_selected',
        'paymentMethodType': 'cod',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        "Sukses",
        "Metode COD dipilih.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print(
        "DEBUG: userSelectsCodPayment - FAILED for OrderID: $orderId. Error: $e",
      );
      Get.snackbar("Error", "Gagal memilih metode COD: $e");
    } finally {
      isUserChoosingCod.value = false; // Menggunakan flag yang benar
    }
  }

  Future<String?> initiateOnlinePayment(DocumentSnapshot orderSnapshot) async {
    if (isProcessingPayment.value) return null;
    isProcessingPayment.value = true;

    String orderId = orderSnapshot.id;
    if (!orderSnapshot.exists) {
      Get.snackbar("Error", "Data pesanan tidak lagi ditemukan.");
      isProcessingPayment.value = false;
      return null;
    }
    Map<String, dynamic> orderData =
        orderSnapshot.data() as Map<String, dynamic>;

    int? grossAmount = orderData['totalPrice'] as int?;
    String? customerName = orderData['customerName'] as String?;
    String? customerEmail = orderData['customerEmail'] as String?;
    String? customerPhone = orderData['customerPhone'] as String?;
    String? itemTitle =
        (orderData['packageTitle'] ?? orderData['eventTitle']) as String?;
    String? itemId = orderData['itemId'] as String?;

    if (grossAmount == null || grossAmount <= 0) {
      Get.snackbar("Error Pembayaran", "Total harga tidak valid.");
      isProcessingPayment.value = false;
      return null;
    }
    if (customerName == null ||
        customerEmail == null ||
        customerPhone == null) {
      Get.snackbar("Error Data Pelanggan", "Data pelanggan tidak lengkap.");
      isProcessingPayment.value = false;
      return null;
    }

    List<Map<String, dynamic>> midtransItemDetails = [
      {
        "id": itemId ?? orderId,
        "price": grossAmount,
        "quantity": 1,
        "name": itemTitle ?? "Produk/Layanan",
      },
    ];

    try {
      final snapToken = await _midtransService.createTransaction(
        orderId: orderId,
        grossAmount: grossAmount,
        customerDetails: {
          "first_name": customerName.split(" ").first,
          "last_name":
              customerName.split(" ").length > 1
                  ? customerName.substring(customerName.indexOf(" ") + 1).trim()
                  : customerName.split(" ").first,
          "email": customerEmail,
          "phone": customerPhone,
        },
        itemDetails: midtransItemDetails,
      );

      if (snapToken != null) {
        await _firestore.collection('orders').doc(orderId).update({
          'snapToken': snapToken,
          'status': 'midtrans_pending_payment',
          'paymentMethodType': 'midtrans_snap',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return snapToken;
      } else {
        Get.snackbar("Gagal Pembayaran", "Gagal mendapatkan token Midtrans.");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error Proses Pembayaran", "Terjadi kesalahan: $e");
      return null;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Metode baru untuk update status berdasarkan hasil dari Midtrans (via redirect/PaymentView)
  Future<void> updateOrderStatusAfterPayment(
    MidtransModel paymentResult,
  ) async {
    print(
      "DEBUG: updateOrderStatusAfterPayment called with status: ${paymentResult.transactionStatus} for order: ${paymentResult.orderId}",
    );

    String? finalAppStatus;

    // Mapping status Midtrans ke status aplikasi Anda
    if (paymentResult.transactionStatus == 'settlement' ||
        paymentResult.transactionStatus == 'capture') {
      finalAppStatus = 'paid'; // Atau 'settlement' sesuai preferensi Anda
    } else if (paymentResult.transactionStatus == 'pending') {
      finalAppStatus = 'midtrans_payment_pending';
    } else if (paymentResult.transactionStatus == 'expire' ||
        paymentResult.transactionStatus == 'cancel' ||
        paymentResult.transactionStatus == 'deny') {
      finalAppStatus = 'payment_failed_or_cancelled';
    } else if (paymentResult.transactionStatus == 'cancelled_by_user' ||
        paymentResult.transactionStatus == 'web_error') {
      // Untuk kasus ini, mungkin Anda tidak ingin mengubah status dari 'midtrans_pending_payment'
      // kecuali jika Anda memiliki status spesifik seperti 'payment_aborted_by_user'
      // Jika dibatalkan pengguna, mungkin statusnya kembali ke 'awaiting_payment_choice' jika ingin user bisa coba lagi
      // atau biarkan 'midtrans_pending_payment' dan tunggu webhook jika ada.
      // Untuk contoh ini, kita tidak update ke status baru jika dibatalkan atau web_error,
      // karena status sebelumnya ('midtrans_pending_payment') sudah mencerminkan upaya pembayaran.
      // Webhook dari Midtrans akan menjadi sumber kebenaran utama.
      print(
        "ℹ️ Order status for ${paymentResult.orderId} not changed via client for status: ${paymentResult.transactionStatus}. Waiting for webhook.",
      );
      // Jika Anda ingin mengubahnya, misalnya:
      // if (paymentResult.transactionStatus == 'cancelled_by_user') finalAppStatus = 'awaiting_payment_choice';
    }

    if (finalAppStatus != null) {
      try {
        await _firestore.collection('orders').doc(paymentResult.orderId).update(
          {
            'status': finalAppStatus,
            'paymentTransactionStatus':
                paymentResult.transactionStatus, // Simpan status asli Midtrans
            'paymentStatusCode':
                paymentResult.statusCode, // Simpan status code Midtrans
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
        print(
          "✅ Order status updated to '$finalAppStatus' for order ${paymentResult.orderId} based on payment result from client redirect.",
        );
      } catch (e) {
        print(
          "❌ Failed to update order status for ${paymentResult.orderId} after payment: $e",
        );
      }
    }
  }
}
