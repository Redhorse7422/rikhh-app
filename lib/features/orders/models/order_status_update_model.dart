class OrderStatusUpdateRequest {
  final String? reason;
  final String? notes;

  OrderStatusUpdateRequest({this.reason, this.notes});

  Map<String, dynamic> toJson() {
    return {
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
    };
  }

  factory OrderStatusUpdateRequest.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdateRequest(
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class OrderStatusUpdateResponse {
  final int code;
  final String message;
  final String requestId;
  final OrderStatusUpdateData data;

  OrderStatusUpdateResponse({
    required this.code,
    required this.message,
    required this.requestId,
    required this.data,
  });

  factory OrderStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdateResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      requestId: json['requestId'] as String,
      data: OrderStatusUpdateData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class OrderStatusUpdateData {
  final OrderStatusData order;

  OrderStatusUpdateData({required this.order});

  factory OrderStatusUpdateData.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdateData(
      order: OrderStatusData.fromJson(json['order'] as Map<String, dynamic>),
    );
  }
}

class OrderStatusData {
  final String id;
  final String orderNumber;
  final String status;
  final String? cancelledAt;
  final String? reason;

  OrderStatusData({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.cancelledAt,
    this.reason,
  });

  factory OrderStatusData.fromJson(Map<String, dynamic> json) {
    return OrderStatusData(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      cancelledAt: json['cancelledAt'] as String?,
      reason: json['reason'] as String?,
    );
  }
}
