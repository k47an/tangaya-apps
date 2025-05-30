class MidtransModel {
  final String orderId;
  final String transactionStatus;
  final String statusCode; // status_code dari Midtrans (misal: "200", "201", "202", "407")

  MidtransModel({
    required this.orderId,
    required this.transactionStatus,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'PaymentResult(orderId: $orderId, transactionStatus: $transactionStatus, statusCode: $statusCode)';
  }

  // Opsional: Factory constructor dari Map (jika Anda menerimanya sebagai Map dari suatu tempat)
  // factory PaymentResult.fromMap(Map<String, dynamic> map) {
  //   return PaymentResult(
  //     orderId: map['order_id'] ?? 'N/A',
  //     transactionStatus: map['transaction_status'] ?? 'unknown',
  //     statusCode: map['status_code'] ?? 'N/A',
  //   );
  // }

  // Opsional: Method toJson (jika Anda perlu mengirimnya sebagai Map)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'order_id': orderId,
  //     'transaction_status': transactionStatus,
  //     'status_code': statusCode,
  //   };
  // }
}