import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tangaya_apps/app/data/api/api.dart';
import 'package:tangaya_apps/app/data/models/booking_model.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart';

class MidtransService extends GetxService {
  static const String finishRedirectUrlHost = "tangaya-apps.web.app";
  static const String finishRedirectUrlPath = "/payment-callback";
  static final String _serverKey = Api.midtransServerKey;
  static const String _baseUrl =
      'https://app.sandbox.midtrans.com/snap/v1/transactions';
  static const String _finishRedirectUrl =
      "https://tangaya-apps.web.app/payment-callback";

  static Map<String, String> get _headers {
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$_serverKey:'))}';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': basicAuth,
    };
  }

  Future<String?> createTransaction({
    required String orderId,
    required int grossAmount,
    List<Map<String, dynamic>>? itemDetails,
    Map<String, dynamic>? customerDetails,
  }) async {
    final url = Uri.parse(_baseUrl);
    final Map<String, dynamic> requestBody = {
      "transaction_details": {"order_id": orderId, "gross_amount": grossAmount},
      "callbacks": {"finish": _finishRedirectUrl},
      if (itemDetails != null) "item_details": itemDetails,
      if (customerDetails != null) "customer_details": customerDetails,
      "credit_card": {"secure": true},
    };

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final snapToken = jsonResponse['token'] as String?;
        print('✅ Snap Token berhasil dibuat (MidtransService): $snapToken');
        return snapToken;
      } else {
        print('❌ Gagal membuat transaksi Midtrans (MidtransService).');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Terjadi error saat menghubungi Midtrans (MidtransService): $e');
      return null;
    }
  }

  Future<String?> createTransactionForOrder(Booking booking) async {
    if (booking.totalPrice <= 0) {
      print("❌ Error: Total harga untuk order ${booking.orderId} tidak valid.");
      return null;
    }

    final itemDetails = [
      {
        "id": booking.itemId,
        "price": booking.totalPrice,
        "quantity": 1,
        "name": booking.itemTitle,
      },
    ];

    final customerNameParts = booking.customerName.split(" ");
    final firstName = customerNameParts.first;
    final lastName =
        customerNameParts.length > 1
            ? customerNameParts.sublist(1).join(" ")
            : '';

    final customerDetails = {
      "first_name": firstName,
      "last_name": lastName,
      "email": booking.customerEmail,
      "phone": booking.customerPhone,
    };

    return await createTransaction(
      orderId: booking.orderId,
      grossAmount: booking.totalPrice,
      itemDetails: itemDetails,
      customerDetails: customerDetails,
    );
  }

  MidtransModel? parseRedirectUrl(Uri url) {
    if (url.host == finishRedirectUrlHost &&
        url.path == finishRedirectUrlPath) {
      final String? orderId = url.queryParameters['order_id'];
      final String? transactionStatus =
          url.queryParameters['transaction_status'];
      final String? statusCode = url.queryParameters['status_code'];

      if (orderId != null && transactionStatus != null && statusCode != null) {
        print(
          'MidtransService: Payment callback intercepted for orderId: $orderId',
        );
        return MidtransModel(
          orderId: orderId,
          transactionStatus: transactionStatus,
          statusCode: statusCode,
        );
      }
    }
    return null;
  }
}
