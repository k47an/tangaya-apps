import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final String userId;
  final String itemType;
  final String itemId;
  final String? packageTitle;
  final String? eventTitle;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final int peopleCount;
  final List<String> peopleNames;
  final DateTime? bookingDate;
  final int totalPrice;
  final String status;
  final String? paymentMethodType;
  final String? snapToken;
  final DateTime orderTimestamp;
  final DateTime updatedAt;

  Order({
    required this.orderId,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.packageTitle,
    this.eventTitle,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.peopleCount,
    required this.peopleNames,
    this.bookingDate,
    required this.totalPrice,
    required this.status,
    this.paymentMethodType,
    this.snapToken,
    required this.orderTimestamp,
    required this.updatedAt,
  });

  String get itemTitle => packageTitle ?? eventTitle ?? 'Item Tidak Diketahui';

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      orderId: doc.id,
      userId: data['userId'] ?? '',
      itemType: data['itemType'] ?? '',
      itemId: data['itemId'] ?? '',
      packageTitle: data['packageTitle'],
      eventTitle: data['eventTitle'],
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      peopleCount: (data['peopleCount'] as num?)?.toInt() ?? 0,
      peopleNames: List<String>.from(data['peopleNames'] ?? []),
      bookingDate: (data['bookingDate'] as Timestamp?)?.toDate(),
      totalPrice: (data['totalPrice'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'unknown',
      paymentMethodType: data['paymentMethodType'],
      snapToken: data['snapToken'],
      orderTimestamp:
          (data['orderTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
