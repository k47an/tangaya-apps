import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/event_model.dart';
import 'package:tangaya_apps/app/data/models/tour_model.dart';
import 'package:tangaya_apps/app/modules/auth/controllers/auth_controller.dart';

class OrderService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

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
    bool isUpdate = false,
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
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (!isUpdate) {
        orderData["orderTimestamp"] = FieldValue.serverTimestamp();
      }

      orderData["snapToken"] = snapToken;

      if (isUpdate) {
        await _firestore
            .collection("orders")
            .doc(orderId)
            .set(orderData, SetOptions(merge: true));
        print("✅ Order berhasil diperbarui di Firestore dengan ID: $orderId");
      } else {
        await _firestore.collection("orders").doc(orderId).set(orderData);
        print("✅ Order berhasil disimpan ke Firestore dengan ID: $orderId");
      }
    } catch (e) {
      print(
        "❌ Gagal menyimpan/memperbarui order di Firestore (OrderService): $e",
      );
      Get.snackbar("Error Database", "Gagal memproses data pesanan: $e");
      rethrow;
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? paymentMethod,
    String? updatedSnapToken,
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

      await _firestore.collection('orders').doc(orderId).update(dataToUpdate);
      print("✅ Status order $orderId berhasil diupdate menjadi $newStatus");
    } catch (e) {
      print("❌ Gagal mengupdate status order $orderId: $e");
      Get.snackbar("Error Update", "Gagal memperbarui status pesanan: $e");
      rethrow;
    }
  }
}
