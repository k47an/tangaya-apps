class MidtransModel {
  final String orderId;
  final String transactionStatus;
  final String statusCode; 

  MidtransModel({
    required this.orderId,
    required this.transactionStatus,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'PaymentResult(orderId: $orderId, transactionStatus: $transactionStatus, statusCode: $statusCode)';
  }
}