import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/booking_model.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

class BookingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Menggunakan lazy-find untuk memastikan AuthController sudah siap saat dipanggil
  final AuthController _authController = Get.find<AuthController>();

  // METHOD BARU: Mengambil stream pesanan untuk Admin (hanya yang butuh persetujuan)
  Stream<List<Booking>> getAdminOrdersStream() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'pending_approval')
        .orderBy('orderTimestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  // METHOD BARU: Mengambil stream pesanan untuk User tertentu
  Stream<List<Booking>> getUserOrdersStream(String userId) {
    if (userId.isEmpty) {
      // Mengembalikan stream kosong jika tidak ada user ID
      return Stream.value([]);
    }
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  // Method untuk menyimpan pesanan baru
  Future<void> saveOrderToFirestore({
    required String orderId,
    required String paymentStatus,
    String? snapToken,
    required int totalPrice,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    required String peopleCountText,
    required dynamic detailItemValue,
    required String itemType,
    required String itemId,
    required DateTime? selectedDateValue,
    required List<String> peopleNamesValues,
    String? paymentMethodType,
  }) async {
    try {
      final int peopleCount =
          int.tryParse(peopleCountText.isEmpty ? "1" : peopleCountText) ?? 1;
      final TourPackage? tour =
          (itemType == 'tour' && detailItemValue is TourPackage)
              ? detailItemValue
              : null;
      final Event? event =
          (itemType == 'event' && detailItemValue is Event)
              ? detailItemValue
              : null;

      Map<String, dynamic> orderData = {
        "orderId": orderId,
        "userId": _authController.uid,
        "itemType": itemType,
        "itemId": itemId,
        "packageTitle": tour?.title,
        "eventTitle": event?.title,
        "customerName": customerName,
        "customerEmail": customerEmail,
        "customerPhone": customerPhone,
        "customerAddress": customerAddress,
        "peopleCount": peopleCount,
        "peopleNames": peopleNamesValues,
        "bookingDate":
            itemType == 'tour' && selectedDateValue != null
                ? Timestamp.fromDate(selectedDateValue)
                : (itemType == 'event' && event?.eventDate != null
                    ? Timestamp.fromDate(event!.eventDate)
                    : null),
        "totalPrice": totalPrice,
        "status": paymentStatus,
        "paymentMethodType": paymentMethodType,
        "orderTimestamp": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "snapToken": snapToken,
      };

      await _firestore.collection("orders").doc(orderId).set(orderData);
      print("✅ Order berhasil disimpan ke Firestore dengan ID: $orderId");
    } catch (e) {
      print("❌ Gagal menyimpan order di Firestore (BookingService): $e");
      Get.snackbar("Error Database", "Gagal memproses data pesanan: $e");
      rethrow;
    }
  }
  
  // Method untuk memperbarui status pesanan. Cukup fleksibel untuk berbagai kebutuhan.
  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? paymentMethod,
    String? updatedSnapToken,
    String? paymentTransactionStatus,
    String? paymentStatusCode,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (paymentMethod != null) {
        dataToUpdate['paymentMethodType'] = paymentMethod;
      }
      if (updatedSnapToken != null) {
        dataToUpdate['snapToken'] = updatedSnapToken;
      }
       if (paymentTransactionStatus != null) {
        dataToUpdate['paymentTransactionStatus'] = paymentTransactionStatus;
      }
       if (paymentStatusCode != null) {
        dataToUpdate['paymentStatusCode'] = paymentStatusCode;
      }

      await _firestore.collection('orders').doc(orderId).update(dataToUpdate);
      print("✅ Status order $orderId berhasil diupdate menjadi $newStatus");
    } catch (e) {
      print("❌ Gagal mengupdate status order $orderId: $e");
      Get.snackbar("Error Update", "Gagal memperbarui status pesanan: $e");
      rethrow;
    }
  }

  // Method untuk menghapus pesanan
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      print("✅ Order $orderId berhasil dihapus.");
    } catch (e) {
      print("❌ Gagal menghapus order $orderId: $e");
      Get.snackbar("Error", "Gagal menghapus pesanan.");
      rethrow;
    }
  }
}