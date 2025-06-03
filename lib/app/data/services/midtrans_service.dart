// lib/app/services/midtrans_service.dart
import 'dart:convert';
import 'package:http/http.dart'
    as http; // Pastikan package http sudah ada di pubspec.yaml

class MidtransService {
  // Bisa juga extends GetxService jika ingin di-manage oleh GetX
  // Kredensial Midtrans Anda (Sandbox)
  // static const String _merchantId = 'G504648997'; // Ganti jika perlu
  // static const String _clientKey =
      'SB-Mid-client-PiR75Nck1zn_QgZp'; // Ganti jika perlu
  static const String _serverKey =
      'SB-Mid-server-G26K49GHhN6aFnx5E9GCPMgj'; // Ganti jika perlu

  static const String _baseUrl =
      'https://app.sandbox.midtrans.com/snap/v1/transactions';
  // URL callback untuk WebView, pastikan sama dengan yang dipantau di PaymentWebViewController
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
        // Berhasil dibuat
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
}
