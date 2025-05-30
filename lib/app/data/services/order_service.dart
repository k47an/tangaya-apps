import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart'; // Sesuaikan path jika perlu
import 'package:tangaya_apps/app/data/models/tour_model.dart';  // Sesuaikan path jika perlu
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart'; // Sesuaikan path

class OrderService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Mengambil instance AuthController yang sudah di-register oleh GetX
  // Pastikan AuthController sudah di-put (misalnya di main.dart atau AppBinding)
  final AuthController _authController = Get.find<AuthController>();

  /// Menyimpan atau memperbarui data pesanan ke Firestore.
  ///
  /// Jika dokumen dengan [orderId] sudah ada, ia akan diperbarui.
  /// Jika belum ada, dokumen baru akan dibuat.
  Future<void> saveOrderToFirestore({
    required String orderId,
    required String paymentStatus, // Status pesanan, misal: "order_placed_pending_payment", "cod_pending_confirmation", "va_pending_admin_approval", "settlement", dll.
    String? snapToken,         // Nullable, karena tidak semua pesanan (misal COD atau VA awal) memiliki snapToken
    required int totalPrice,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String peopleCountText, // Jumlah orang dalam bentuk teks, akan di-parse ke int
    required dynamic detailItemValue, // Bisa TourPackage atau Event, atau null jika tidak relevan saat update
    required String itemType,         // 'tour' atau 'event'
    required String itemId,           // ID dari TourPackage atau Event
    required DateTime? selectedDateValue, // Tanggal booking untuk tour, atau tanggal event
    required List<String> peopleNamesValues,
    String? paymentMethodType,  // Nullable, misal: 'cod', 'virtual_account', 'webview_snap', atau null/not_selected
    bool isUpdate = false, // Flag untuk membedakan pembuatan baru atau update
  }) async {
    try {
      final int peopleCount = int.tryParse(peopleCountText.isEmpty ? "1" : peopleCountText) ?? 1;
      final TourPackage? tour =
          (itemType == 'tour' && detailItemValue is TourPackage)
              ? detailItemValue
              : null;
      final Event? event =
          (itemType == 'event' && detailItemValue is Event)
              ? detailItemValue
              : null;

      // Data yang akan selalu ada atau di-update
      Map<String, dynamic> orderData = {
        "orderId": orderId, // Sebaiknya konsisten, bisa sama dengan ID dokumen
        "userId": _authController.uid,
        "itemType": itemType,
        "itemId": itemId,
        "packageTitle": tour?.title, // Akan null jika bukan tour atau detailItemValue null
        "eventTitle": event?.title,   // Akan null jika bukan event atau detailItemValue null
        "customerName": customerName,
        "customerPhone": customerPhone,
        "customerAddress": customerAddress,
        "peopleCount": peopleCount,
        "peopleNames": peopleNamesValues,
        "bookingDate": // Tanggal booking atau tanggal event
            itemType == 'tour' && selectedDateValue != null
                ? Timestamp.fromDate(selectedDateValue)
                : (itemType == 'event' && event?.eventDate != null
                    ? Timestamp.fromDate(event!.eventDate)
                    : null), // Bisa null jika tidak relevan
        "totalPrice": totalPrice,
        "status": paymentStatus,
        "paymentMethodType": paymentMethodType, // Bisa null jika belum dipilih
        "updatedAt": FieldValue.serverTimestamp(), // Selalu update timestamp ini
      };

      // Hanya tambahkan field ini jika ini adalah pembuatan order baru
      if (!isUpdate) {
        orderData["orderTimestamp"] = FieldValue.serverTimestamp();
      }

      // Hanya tambahkan snapToken ke map jika tidak null
      // Ini penting agar tidak menimpa snapToken yang sudah ada dengan null saat update,
      // kecuali memang diinginkan. Atau, selalu sertakan (Firestore akan menyimpan null).
      // Untuk update, mungkin lebih baik tidak menyertakan field snapToken jika tidak berubah.
      // Namun, jika ini adalah metode save/update generik, menyertakannya (bahkan sbg null) lebih sederhana.
      orderData["snapToken"] = snapToken;


      // Menggunakan .set() dengan merge: true akan membuat dokumen baru jika tidak ada,
      // atau memperbarui field yang ada jika dokumen sudah ada, tanpa menghapus field lain.
      // Jika ingin overwrite total (misal saat save awal), merge: false (default .set()).
      // Untuk metode save/update generik, merge:true lebih aman untuk update.
      // Tapi karena kita juga menangani pembuatan awal, kita bisa bedakan.
      if (isUpdate) {
        await _firestore.collection("orders").doc(orderId).set(orderData, SetOptions(merge: true));
         print("✅ Order berhasil diperbarui di Firestore dengan ID: $orderId");
      } else {
        await _firestore.collection("orders").doc(orderId).set(orderData);
        print("✅ Order berhasil disimpan ke Firestore dengan ID: $orderId");
      }

    } catch (e) {
      print("❌ Gagal menyimpan/memperbarui order di Firestore (OrderService): $e");
      Get.snackbar("Error Database", "Gagal memproses data pesanan: $e");
      rethrow; // Lemparkan kembali error agar bisa ditangani di pemanggil jika perlu
    }
  }

  /// Contoh metode untuk memperbarui status pesanan secara spesifik
  Future<void> updateOrderStatus(String orderId, String newStatus, {String? paymentMethod, String? updatedSnapToken}) async {
    try {
      Map<String, dynamic> dataToUpdate = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (paymentMethod != null) {
        dataToUpdate['paymentMethodType'] = paymentMethod;
      }
      if (updatedSnapToken != null) { // Jika ada snapToken baru saat pembayaran VA
        dataToUpdate['snapToken'] = updatedSnapToken;
      }

      await _firestore.collection('orders').doc(orderId).update(dataToUpdate);
      print("✅ Status order $orderId berhasil diupdate menjadi $newStatus");
    } catch (e) {
      print("❌ Gagal mengupdate status order $orderId: $e");
      Get.snackbar("Error Update", "Gagal memperbarui status pesanan: $e");
      rethrow;
    }
  }

  // Anda bisa menambahkan metode lain di sini, misalnya:
  // Future<DocumentSnapshot?> getOrderById(String orderId) async { ... }
  // Stream<List<DocumentSnapshot>> getUserOrders(String userId) { ... } // Sudah ada di NotificationController
}