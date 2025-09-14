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
    final id = json['id']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';
    final guestId = json['guestId']?.toString();
    final orderNumber = json['orderNumber']?.toString() ?? '';
    final status = json['status']?.toString() ?? '';
    final paymentStatus = json['paymentStatus']?.toString() ?? '';
    final totalAmount = json['totalAmount'] is num
        ? (json['totalAmount'] as num).toDouble()
        : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;

    final items =
        (json['items'] as List?)?.map((item) {
          return OrderItem.fromJson(item);
        }).toList() ??
        [];

    final statusHistory =
        (json['statusHistory'] as List?)?.map((status) {
          return OrderStatusHistory.fromJson(status);
        }).toList() ??
        [];

    final createdAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final updatedAt =
        DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.now();

    return OrderModel(
      id: id,
      userId: userId,
      guestId: guestId,
      orderNumber: orderNumber,
      status: status,
      paymentStatus: paymentStatus,
      totalAmount: totalAmount,
      items: items,
      statusHistory: statusHistory,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
  final int total;
  final int page;
  final int limit;

  const OrdersResponse({
    required this.success,
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final dataObject = json['data'] as Map<String, dynamic>?;

    final dataList = dataObject?['data'] as List?;

    return OrdersResponse(
      success: json['success'] == true,
      data:
          dataList?.map((order) {
            return OrderModel.fromJson(order);
          }).toList() ??
          [],
      total: dataObject?['total'] is num
          ? (dataObject!['total'] as num).toInt()
          : 0,
      page: dataObject?['page'] is num
          ? (dataObject!['page'] as num).toInt()
          : 1,
      limit: dataObject?['limit'] is num
          ? (dataObject!['limit'] as num).toInt()
          : 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'data': data.map((order) => order.toJson()).toList(),
        'total': total,
        'page': page,
        'limit': limit,
      },
    };
  }

  @override
  List<Object?> get props => [success, data, total, page, limit];
}
