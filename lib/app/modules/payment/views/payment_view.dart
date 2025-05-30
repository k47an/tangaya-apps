import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tangaya_apps/app/modules/payment/controllers/payment_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';



// Sekarang menjadi GetView
class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller akan di-inject oleh GetX, pastikan Anda punya Binding
    // atau Get.put() di tempat yang sesuai sebelum navigasi ke halaman ini.
    // Untuk contoh ini, kita akan buat binding nanti.
    // Atau, jika controller sudah diinisialisasi oleh Get.to, ia akan tersedia.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proses Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => controller.handleCloseButton(),
        ),
      ),
      body: Obx( // Gunakan Obx untuk merebuild saat isLoading berubah
        () => Stack(
          children: [
            WebViewWidget(controller: controller.webViewController),
            if (controller.isLoading.value)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }}