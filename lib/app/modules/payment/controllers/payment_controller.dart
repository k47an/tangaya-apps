import 'package:get/get.dart';
import 'package:tangaya_apps/app/data/models/midtrans_model.dart';
import 'package:tangaya_apps/app/data/services/midtrans_service.dart';
import 'package:tangaya_apps/app/modules/payment/views/paymentArgumen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentController extends GetxController {
  late final WebViewController webViewController;
  final RxBool isLoading = true.obs;
  final PaymentPageArguments args = Get.arguments;

  final MidtransService _midtransService = Get.find<MidtransService>();

  @override
  void onInit() {
    super.onInit();

    final String paymentUrl =
        'https://app.sandbox.midtrans.com/snap/v2/vtweb/${args.snapToken}';

    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) => isLoading.value = true,
              onPageFinished: (String url) => isLoading.value = false,
              onWebResourceError: (WebResourceError error) {
                isLoading.value = false;
                if (error.isForMainFrame == true) {
                  final result = MidtransModel(
                    orderId: args.orderId,
                    transactionStatus: "web_error",
                    statusCode: error.errorCode.toString(),
                  );
                  Get.back(result: result);
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                final uri = Uri.parse(request.url);
                final result = _midtransService.parseRedirectUrl(uri);

                if (result != null) {
                  Get.back(result: result);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(paymentUrl));
  }

  void handleCloseButton() {
    final result = MidtransModel(
      orderId: args.orderId,
      transactionStatus: "cancelled_by_user",
      statusCode: "N/A",
    );
    Get.back(result: result);
  }
}
