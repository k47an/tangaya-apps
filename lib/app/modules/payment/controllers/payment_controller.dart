import 'package:flutter/material.dart'; // Untuk BuildContext di Navigator.pop
import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentController extends GetxController {
  late final WebViewController webViewController;
  final RxBool isLoading = true.obs;

  final String snapToken =
      Get.arguments['snapToken']; // Ambil snapToken dari arguments

  // Definisikan URL callback yang akan dipantau
  // Pastikan ini sama dengan yang Anda set di MidtransService atau default Midtrans
  static const String finishRedirectUrlHost = "tangaya-apps.web.app";
  static const String finishRedirectUrlPath = "/payment-callback";

  @override
  void onInit() {
    super.onInit();

    final String paymentUrl =
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';

    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                isLoading.value = true;
                print('WebView: Page started loading: $url');
              },
              onPageFinished: (String url) {
                isLoading.value = false;
                print('WebView: Page finished loading: $url');
              },
              onWebResourceError: (WebResourceError error) {
                isLoading.value = false;
                print('''
            WebView: Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');
                // Mengembalikan hasil error jika halaman utama gagal dimuat
                if (error.isForMainFrame == true) {
                  final result = MidtransModel(
                    orderId:
                        Get.arguments['orderIdForError'] ??
                        "N/A_ON_WEB_ERROR", // Kirim orderId juga sebagai argumen
                    transactionStatus: "web_error",
                    statusCode: error.errorCode.toString(),
                  );
                  Get.back(result: result);
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                print('WebView: Navigating to: ${request.url}');
                final uri = Uri.parse(request.url);

                if (uri.host == finishRedirectUrlHost &&
                    uri.path == finishRedirectUrlPath) {
                  final String? orderId = uri.queryParameters['order_id'];
                  final String? transactionStatus =
                      uri.queryParameters['transaction_status'];
                  final String? statusCode = uri.queryParameters['status_code'];

                  if (orderId != null &&
                      transactionStatus != null &&
                      statusCode != null) {
                    print(
                      'WebView: Payment callback intercepted: orderId=$orderId, status=$transactionStatus, statusCode=$statusCode',
                    );
                    final result = MidtransModel(
                      orderId: orderId,
                      transactionStatus: transactionStatus,
                      statusCode: statusCode,
                    );
                    Get.back(result: result); // Kembalikan hasil
                    return NavigationDecision.prevent;
                  }
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(paymentUrl));
  }

  void handleCloseButton() {
    final result = MidtransModel(
      orderId: Get.arguments['orderIdForError'] ?? "N/A_ON_CLOSE",
      transactionStatus: "cancelled_by_user",
      statusCode: "N/A",
    );
    Get.back(result: result);
  }
}
