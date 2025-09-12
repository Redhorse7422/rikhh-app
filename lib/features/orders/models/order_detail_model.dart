import 'package:equatable/equatable.dart';
import 'order_model.dart';

class OrderDetailModel extends Equatable {
  final String id;
  final String orderNumber;
  final String userId;
  final String? guestId;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final String? paymentTransactionId;
  final String? paymentGatewayResponse;
  final Address shippingAddress;
  final Address? billingAddress;
  final String shippingMethod;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String? notes;
  final String? adminNotes;
  final String? couponCode;
  final bool emailSent;
  final String customerEmail;
  final String customerFirstName;
  final String customerLastName;
  final List<OrderDetailItem> items;
  final List<OrderStatusHistory> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    this.guestId,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.paymentTransactionId,
    this.paymentGatewayResponse,
    required this.shippingAddress,
    this.billingAddress,
    required this.shippingMethod,
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.notes,
    this.adminNotes,
    this.couponCode,
    required this.emailSent,
    required this.customerEmail,
    required this.customerFirstName,
    required this.customerLastName,
    required this.items,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      guestId: json['guestId']?.toString(),
      status: json['status']?.toString() ?? '',
      subtotal: json['subtotal'] is num
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      taxAmount: json['taxAmount'] is num
          ? (json['taxAmount'] as num).toDouble()
          : double.tryParse(json['taxAmount']?.toString() ?? '0') ?? 0.0,
      shippingAmount: json['shippingAmount'] is num
          ? (json['shippingAmount'] as num).toDouble()
          : double.tryParse(json['shippingAmount']?.toString() ?? '0') ?? 0.0,
      discountAmount: json['discountAmount'] is num
          ? (json['discountAmount'] as num).toDouble()
          : double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      totalAmount: json['totalAmount'] is num
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      paymentGatewayResponse: json['paymentGatewayResponse']?.toString(),
      shippingAddress: Address.fromJson(json['shippingAddress'] ?? {}),
      billingAddress: json['billingAddress'] != null 
          ? Address.fromJson(json['billingAddress'])
          : null,
      shippingMethod: json['shippingMethod']?.toString() ?? 'standard',
      trackingNumber: json['trackingNumber']?.toString(),
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.tryParse(json['estimatedDeliveryDate'].toString())
          : null,
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? DateTime.tryParse(json['actualDeliveryDate'].toString())
          : null,
      notes: json['notes']?.toString(),
      adminNotes: json['adminNotes']?.toString(),
      couponCode: json['couponCode']?.toString(),
      emailSent: json['emailSent'] == true,
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerFirstName: json['customerFirstName']?.toString() ?? '',
      customerLastName: json['customerLastName']?.toString() ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderDetailItem.fromJson(item))
              .toList() ??
          [],
      statusHistory: (json['statusHistory'] as List?)
              ?.map((status) => OrderStatusHistory.fromJson(status))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'guestId': guestId,
      'status': status,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'shippingAmount': shippingAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentTransactionId': paymentTransactionId,
      'paymentGatewayResponse': paymentGatewayResponse,
      'shippingAddress': shippingAddress.toJson(),
      'billingAddress': billingAddress?.toJson(),
      'shippingMethod': shippingMethod,
      'trackingNumber': trackingNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'notes': notes,
      'adminNotes': adminNotes,
      'couponCode': couponCode,
      'emailSent': emailSent,
      'customerEmail': customerEmail,
      'customerFirstName': customerFirstName,
      'customerLastName': customerLastName,
      'items': items.map((item) => item.toJson()).toList(),
      'statusHistory': statusHistory.map((status) => status.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        userId,
        guestId,
        status,
        subtotal,
        taxAmount,
        shippingAmount,
        discountAmount,
        totalAmount,
        paymentStatus,
        paymentMethod,
        paymentTransactionId,
        paymentGatewayResponse,
        shippingAddress,
        billingAddress,
        shippingMethod,
        trackingNumber,
        estimatedDeliveryDate,
        actualDeliveryDate,
        notes,
        adminNotes,
        couponCode,
        emailSent,
        customerEmail,
        customerFirstName,
        customerLastName,
        items,
        statusHistory,
        createdAt,
        updatedAt,
      ];
}

class Address extends Equatable {
  final String firstName;
  final String lastName;
  final String? company;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;

  const Address({
    required this.firstName,
    required this.lastName,
    this.company,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      company: json['company']?.toString(),
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
    };
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null) addressLine2!,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        company,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        phone,
      ];
}

class OrderDetailItem extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String productSlug;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final ProductSnapshot productSnapshot;
  final List<SelectedVariant> selectedVariants;
  final String? sku;
  final double taxAmount;
  final double discountAmount;
  final String? thumbnailImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderDetailItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productSnapshot,
    required this.selectedVariants,
    this.sku,
    required this.taxAmount,
    required this.discountAmount,
    this.thumbnailImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productSlug: json['productSlug']?.toString() ?? '',
      quantity: json['quantity'] is num
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: json['unitPrice'] is num
          ? (json['unitPrice'] as num).toDouble()
          : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      totalPrice: json['totalPrice'] is num
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      productSnapshot: ProductSnapshot.fromJson(json['productSnapshot'] ?? {}),
      selectedVariants: (json['selectedVariants'] as List?)
              ?.map((variant) => SelectedVariant.fromJson(variant))
              .toList() ??
          [],
      sku: json['sku']?.toString(),
      taxAmount: json['taxAmount'] is num
          ? (json['taxAmount'] as num).toDouble()
          : double.tryParse(json['taxAmount']?.toString() ?? '0') ?? 0.0,
      discountAmount: json['discountAmount'] is num
          ? (json['discountAmount'] as num).toDouble()
          : double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      thumbnailImage: json['thumbnailImage']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'productSlug': productSlug,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'productSnapshot': productSnapshot.toJson(),
      'selectedVariants': selectedVariants.map((variant) => variant.toJson()).toList(),
      'sku': sku,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'thumbnailImage': thumbnailImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        productSlug,
        quantity,
        unitPrice,
        totalPrice,
        productSnapshot,
        selectedVariants,
        sku,
        taxAmount,
        discountAmount,
        thumbnailImage,
        createdAt,
        updatedAt,
      ];
}

class ProductSnapshot extends Equatable {
  final String name;
  final String description;
  final double price;

  const ProductSnapshot({
    required this.name,
    required this.description,
    required this.price,
  });

  factory ProductSnapshot.fromJson(Map<String, dynamic> json) {
    return ProductSnapshot(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [name, description, price];
}

class SelectedVariant extends Equatable {
  final String attributeId;
  final String attributeName;
  final String variantValue;
  final double attributePrice;

  const SelectedVariant({
    required this.attributeId,
    required this.attributeName,
    required this.variantValue,
    required this.attributePrice,
  });

  factory SelectedVariant.fromJson(Map<String, dynamic> json) {
    return SelectedVariant(
      attributeId: json['attributeId']?.toString() ?? '',
      attributeName: json['attributeName']?.toString() ?? '',
      variantValue: json['variantValue']?.toString() ?? '',
      attributePrice: json['attributePrice'] is num
          ? (json['attributePrice'] as num).toDouble()
          : double.tryParse(json['attributePrice']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attributeId': attributeId,
      'attributeName': attributeName,
      'variantValue': variantValue,
      'attributePrice': attributePrice,
    };
  }

  @override
  List<Object?> get props => [attributeId, attributeName, variantValue, attributePrice];
}

class OrderDetailResponse extends Equatable {
  final bool success;
  final OrderDetailModel data;

  const OrderDetailResponse({
    required this.success,
    required this.data,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      success: json['success'] == true,
      data: OrderDetailModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, data];
}
