import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String id;
  final String userId;
  final String orderNumber;
  final String? guestId;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.orderNumber,
    this.guestId,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.items,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      guestId: json['guestId']?.toString(),
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      totalAmount: json['totalAmount'] is num
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      statusHistory:
          (json['statusHistory'] as List?)
              ?.map((status) => OrderStatusHistory.fromJson(status))
              .toList() ??
          [],
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'guestId': guestId,
      'orderNumber': orderNumber,
      'status': status,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'statusHistory': statusHistory.map((status) => status.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    guestId,
    orderNumber,
    status,
    paymentStatus,
    totalAmount,
    items,
    statusHistory,
    createdAt,
    updatedAt,
  ];
}

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  final Map<String, dynamic>? variants;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.variants,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] is num
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      variants: json['variants'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'variants': variants,
    };
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    name,
    imageUrl,
    price,
    quantity,
    variants,
  ];
}

class OrderStatusHistory extends Equatable {
  final String status;
  final DateTime timestamp;
  final String? note;

  const OrderStatusHistory({
    required this.status,
    required this.timestamp,
    this.note,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: json['status']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  @override
  List<Object?> get props => [status, timestamp, note];
}

class OrdersResponse extends Equatable {
  final bool success;
  final List<OrderModel> data;

  const OrdersResponse({required this.success, required this.data});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      success: json['success'] == true,
      data:
          (json['data'] as List?)
              ?.map((order) => OrderModel.fromJson(order))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((order) => order.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [success, data];
}
