import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/payment/controllers/payment_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () => Stack(
            children: [
              WebViewWidget(controller: controller.webViewController),
              if (controller.isLoading.value)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
