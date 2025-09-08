import 'package:equatable/equatable.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/app_config.dart';

class Address extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  final String email;
  final bool isDefault;
  final String type; // 'shipping' or 'billing'
  final String? company;
  final String? notes;
  final String? status;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    required this.email,
    required this.isDefault,
    required this.type,
    this.company,
    this.notes,
    this.status,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    try {
      // Optimize by avoiding repeated toString() calls and null checks
      final id = json['id']?.toString() ?? '';
      final firstName = json['firstName']?.toString() ?? '';
      final lastName = json['lastName']?.toString() ?? '';
      final addressLine1 = json['addressLine1']?.toString() ?? '';
      final addressLine2 = json['addressLine2']?.toString();
      final city = json['city']?.toString() ?? '';
      final state = json['state']?.toString() ?? '';
      final postalCode = json['postalCode']?.toString() ?? '';
      final country = json['country']?.toString() ?? '';
      final phone = json['phone']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final isDefault = json['isDefault'] == true;
      final type = json['type']?.toString() ?? 'shipping';
      final company = json['company']?.toString();
      final notes = json['notes']?.toString();
      final status = json['status']?.toString();
      final userId = json['userId']?.toString();

      // Optimize DateTime parsing by checking string first
      final createdAtStr = json['createdAt'];
      final updatedAtStr = json['updatedAt'];
      final createdAt = createdAtStr is String
          ? DateTime.tryParse(createdAtStr)
          : null;
      final updatedAt = updatedAtStr is String
          ? DateTime.tryParse(updatedAtStr)
          : null;

      final address = Address(
        id: id,
        firstName: firstName,
        lastName: lastName,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        phone: phone,
        email: email,
        isDefault: isDefault,
        type: type,
        company: company,
        notes: notes,
        status: status,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      AppLogger.checkout('Successfully created address: ${address.toString()}');
      return address;
    } catch (e, stackTrace) {
      AppLogger.checkout('Error parsing address: $e');
      AppLogger.checkout('Stack trace: $stackTrace');
      AppLogger.checkout('Raw JSON data: $json');

      // Return a default address with error information
      return Address(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        firstName: 'Error',
        lastName: 'Parsing',
        addressLine1: 'Failed to parse address data',
        city: 'Unknown',
        state: 'Unknown',
        postalCode: '00000',
        country: 'Unknown',
        phone: '000-000-0000',
        email: 'error@example.com',
        isDefault: false,
        type: 'shipping',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'isDefault': isDefault,
      'type': type,
    };
  }

  Address copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    bool? isDefault,
    String? type,
    String? company,
    String? notes,
    String? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    country,
    phone,
    email,
    isDefault,
    type,
    company,
    notes,
    status,
    userId,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Address(id: $id, firstName: $firstName, lastName: $lastName, addressLine1: $addressLine1, city: $city, state: $state, postalCode: $postalCode, country: $country)';
  }
}

class DefaultAddresses extends Equatable {
  final Address? shippingAddress;
  final Address? billingAddress;

  const DefaultAddresses({this.shippingAddress, this.billingAddress});

  factory DefaultAddresses.fromJson(Map<String, dynamic> json) {
    try {
      AppLogger.checkout(
        '🏠 DefaultAddresses.fromJson: Parsing default addresses data: $json',
      );

      Address? shippingAddress;
      Address? billingAddress;

      if (json['shippingAddress'] != null) {
        AppLogger.checkout(
          '🏠 DefaultAddresses.fromJson: Parsing shipping address...',
        );
        shippingAddress = Address.fromJson(json['shippingAddress']);
        AppLogger.checkout(
          '🏠 DefaultAddresses.fromJson: Shipping address parsed successfully',
        );
      } else {
        AppLogger.checkout(
          '🏠 DefaultAddresses.fromJson: No shipping address found',
        );
      }

      if (json['billingAddress'] != null) {
        AppLogger.checkout(
          '🏠 DefaultAddresses.fromJson: Parsing billing address...',
        );
        billingAddress = Address.fromJson(json['billingAddress']);
        AppLogger.checkout(
          '🏠 DefaultAddresses.fromJson: Billing address parsed successfully',
        );
      } else {
        AppLogger.checkout(
          '🏠 DefaultAddresses.fromJson: No billing address found',
        );
      }

      final defaultAddresses = DefaultAddresses(
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
      );

      AppLogger.checkout(
        '🏠 DefaultAddresses.fromJson: Successfully created default addresses',
      );
      AppLogger.checkout(
        '  - Shipping address: ${shippingAddress?.toString() ?? 'null'}',
      );
      AppLogger.checkout(
        '  - Billing address: ${billingAddress?.toString() ?? 'null'}',
      );

      return defaultAddresses;
    } catch (e, stackTrace) {
      AppLogger.checkout(
        '❌ DefaultAddresses.fromJson: Error parsing default addresses: $e',
      );
      AppLogger.checkout(
        '❌ DefaultAddresses.fromJson: Stack trace: $stackTrace',
      );
      AppLogger.checkout('❌ DefaultAddresses.fromJson: Raw JSON data: $json');

      return const DefaultAddresses();
    }
  }

  @override
  List<Object?> get props => [shippingAddress, billingAddress];
}

class CheckoutItem extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? imageUrl;

  const CheckoutItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.imageUrl,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    AppLogger.checkout('🛒 CheckoutItem.fromJson: Parsing item data: $json');

    // Extract product data from nested product object
    final productData = json['product'] as Map<String, dynamic>? ?? {};
    final productName =
        productData['name']?.toString() ??
        json['productName']?.toString() ??
        '';
    final regularPrice =
        double.tryParse(productData['regularPrice']?.toString() ?? '') ?? 0.0;
    final salePrice =
        double.tryParse(productData['salePrice']?.toString() ?? '') ?? 0.0;

    AppLogger.checkout('Price ==> $salePrice');
    AppLogger.checkout('Price ==> $regularPrice');
    // Use sale price if available, otherwise regular price
    final unitPrice = salePrice > 0 ? salePrice : regularPrice;
    final quantity = json['quantity'] is int
        ? json['quantity'] as int
        : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0;

    final totalPrice = unitPrice * quantity;

    // Extract image URL from product data
    String? imageUrl;
    try {
      // Try to get thumbnail image first
      final thumbnailData = productData['thumbnailImg'];

      if (thumbnailData != null && thumbnailData is Map<String, dynamic>) {
        imageUrl = thumbnailData['url']?.toString();
      }

      // If no thumbnail, try to get first photo
      if (imageUrl == null || imageUrl.isEmpty) {
        final photos = productData['photos'] as List?;

        if (photos != null && photos.isNotEmpty) {
          final firstPhoto = photos.first;

          if (firstPhoto is Map<String, dynamic>) {
            imageUrl = firstPhoto['url']?.toString();
          }
        }
      }

      // If still no image, try direct image fields
      if (imageUrl == null || imageUrl.isEmpty) {
        imageUrl =
            productData['image']?.toString() ??
            productData['imageUrl']?.toString() ??
            productData['thumbnail']?.toString();
      }

      // Try alternative field names that might be used in checkout API
      if (imageUrl == null || imageUrl.isEmpty) {
        imageUrl =
            productData['productImage']?.toString() ??
            productData['product_image']?.toString() ??
            productData['mainImage']?.toString() ??
            productData['main_image']?.toString();
      }

      // Try to construct image URL from thumbnailImgId
      if (imageUrl == null || imageUrl.isEmpty) {
        final thumbnailImgId = productData['thumbnailImgId']?.toString();
        if (thumbnailImgId != null && thumbnailImgId.isNotEmpty) {
          // Construct image URL from ID using the API base URL
          // Extract base URL from AppConfig and construct image URL
          final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
          imageUrl = '$baseUrl/uploads/$thumbnailImgId';
        }
      }

      // If still no image, use a default placeholder
      if (imageUrl == null || imageUrl.isEmpty) {
        imageUrl =
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop';
      }
    } catch (e) {
      AppLogger.checkout(
        '🛒 CheckoutItem.fromJson: Error extracting image URL: $e',
      );
    }

    AppLogger.checkout('🛒 CheckoutItem.fromJson: Parsed values:');
    AppLogger.checkout('  - productId: ${json['productId']?.toString() ?? ''}');
    AppLogger.checkout('  - name: $productName');
    AppLogger.checkout('  - quantity: $quantity');
    AppLogger.checkout('  - unitPrice: $unitPrice');
    AppLogger.checkout('  - totalPrice: $totalPrice');
    AppLogger.checkout('  - imageUrl: $imageUrl');

    return CheckoutItem(
      productId: json['productId']?.toString() ?? '',
      name: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    name,
    quantity,
    unitPrice,
    totalPrice,
    imageUrl,
  ];

}

class CheckoutSummary extends Equatable {
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;

  const CheckoutSummary({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    AppLogger.checkout(
      '💰 CheckoutSummary.fromJson: Parsing summary data: $json',
    );

    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Try multiple possible field names for each value
    final subtotal = toDouble(json['subtotal']) != 0.0
        ? toDouble(json['subtotal'])
        : toDouble(json['subTotal']) != 0.0
        ? toDouble(json['subTotal'])
        : toDouble(json['items_total']) != 0.0
        ? toDouble(json['items_total'])
        : toDouble(json['itemsTotal']) != 0.0
        ? toDouble(json['itemsTotal'])
        : toDouble(json['subtotal']);

    final shipping = toDouble(json['shippingAmount']) != 0.0
        ? toDouble(json['shippingAmount'])
        : toDouble(json['shipping_amount']) != 0.0
        ? toDouble(json['shipping_amount'])
        : toDouble(json['shipping']) != 0.0
        ? toDouble(json['shipping'])
        : toDouble(json['shippingAmount']);

    final tax = toDouble(json['taxAmount']) != 0.0
        ? toDouble(json['taxAmount'])
        : toDouble(json['tax_amount']) != 0.0
        ? toDouble(json['tax_amount'])
        : toDouble(json['tax']) != 0.0
        ? toDouble(json['tax'])
        : toDouble(json['taxAmount']);

    final discount = toDouble(json['discountAmount']) != 0.0
        ? toDouble(json['discountAmount'])
        : toDouble(json['discount_amount']) != 0.0
        ? toDouble(json['discount_amount'])
        : toDouble(json['discount']) != 0.0
        ? toDouble(json['discount'])
        : toDouble(json['discountAmount']);

    final total = toDouble(json['totalAmount']) != 0.0
        ? toDouble(json['totalAmount'])
        : toDouble(json['total_amount']) != 0.0
        ? toDouble(json['total_amount'])
        : toDouble(json['total']) != 0.0
        ? toDouble(json['total'])
        : toDouble(json['totalAmount']);

    AppLogger.checkout('💰 CheckoutSummary.fromJson: Parsed values:');
    AppLogger.checkout('  - subtotal: $subtotal');
    AppLogger.checkout('  - shipping: $shipping');
    AppLogger.checkout('  - tax: $tax');
    AppLogger.checkout('  - discount: $discount');
    AppLogger.checkout('  - total: $total');

    return CheckoutSummary(
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
    );
  }

  /// Create a CheckoutSummary by calculating from items
  factory CheckoutSummary.fromItems(
    List<CheckoutItem> items, {
    double shipping = 0.0,
    double tax = 0.0,
    double discount = 0.0,
  }) {
    AppLogger.checkout(
      '💰 CheckoutSummary.fromItems: Calculating from ${items.length} items',
    );

    final subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    final total = subtotal + shipping + tax - discount;

    AppLogger.checkout('💰 CheckoutSummary.fromItems: Calculated values:');
    AppLogger.checkout('  - subtotal: $subtotal');
    AppLogger.checkout('  - shipping: $shipping');
    AppLogger.checkout('  - tax: $tax');
    AppLogger.checkout('  - discount: $discount');
    AppLogger.checkout('  - total: $total');

    return CheckoutSummary(
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
    );
  }

  @override
  List<Object?> get props => [subtotal, shipping, tax, discount, total];
}

class ShippingMethod extends Equatable {
  final String id;
  final String name;
  final double cost;
  final String estimatedDays;

  const ShippingMethod({
    required this.id,
    required this.name,
    required this.cost,
    required this.estimatedDays,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cost: json['cost'] is num
          ? (json['cost'] as num).toDouble()
          : double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
      estimatedDays: json['estimatedDays']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, cost, estimatedDays];
}

class CheckoutSession extends Equatable {
  final String checkoutId;
  final List<CheckoutItem> items;
  final CheckoutSummary summary;
  final Address? shippingAddress;
  final Address? billingAddress;
  final List<ShippingMethod> availableShippingMethods;
  final List<String> availablePaymentMethods;
  final ShippingMethod? selectedShippingMethod;
  final String? couponCode;
  final double? couponDiscount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CheckoutSession({
    required this.checkoutId,
    required this.items,
    required this.summary,
    this.shippingAddress,
    this.billingAddress,
    required this.availableShippingMethods,
    required this.availablePaymentMethods,
    this.selectedShippingMethod,
    this.couponCode,
    this.couponDiscount,
    this.createdAt,
    this.updatedAt,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    AppLogger.checkout(
      '🛒 CheckoutSession.fromJson: Parsing checkout session data: $json',
    );
    AppLogger.checkout(
      '🛒 CheckoutSession.fromJson: Available keys: ${json.keys.toList()}',
    );
    AppLogger.checkout(
      '🛒 CheckoutSession.fromJson: checkoutId value: ${json['checkoutId']}',
    );
    AppLogger.checkout(
      '🛒 CheckoutSession.fromJson: checkoutId type: ${json['checkoutId'].runtimeType}',
    );

    final checkoutId = json['checkoutId']?.toString() ?? '';
    AppLogger.checkout(
      '🛒 CheckoutSession.fromJson: Final checkoutId: "$checkoutId"',
    );

    final itemsList = json['items'] as List?;
    AppLogger.checkout('🛒 CheckoutSession.fromJson: Items data: $itemsList');
    AppLogger.checkout(
      '🛒 CheckoutSession.fromJson: Items count: ${itemsList?.length ?? 0}',
    );

    final items =
        itemsList?.map((e) {
          AppLogger.checkout(
            '🛒 CheckoutSession.fromJson: Processing item: $e',
          );
          return CheckoutItem.fromJson(e);
        }).toList() ??
        [];

    AppLogger.checkout(
      '🛒 CheckoutSession.fromJson: Final items count: ${items.length}',
    );

    // Parse summary with fallback calculation
    CheckoutSummary summary;
    try {
      final summaryData = json['summary'] ?? {};
      summary = CheckoutSummary.fromJson(summaryData);

      // If all values are zero, recalculate from items
      if (summary.subtotal == 0.0 && summary.total == 0.0 && items.isNotEmpty) {
        AppLogger.checkout(
          '🛒 CheckoutSession.fromJson: Summary values are zero, recalculating from items',
        );
        summary = CheckoutSummary.fromItems(items);
      }
    } catch (e) {
      AppLogger.checkout(
        '🛒 CheckoutSession.fromJson: Error parsing summary, calculating from items: $e',
      );
      summary = CheckoutSummary.fromItems(items);
    }

    return CheckoutSession(
      checkoutId: checkoutId,
      items: items,
      summary: summary,
      shippingAddress: json['shippingAddress'] != null
          ? Address.fromJson(json['shippingAddress'])
          : null,
      billingAddress: json['billingAddress'] != null
          ? Address.fromJson(json['billingAddress'])
          : null,
      availableShippingMethods:
          (json['availableShippingMethods'] as List?)
              ?.map((e) => ShippingMethod.fromJson(e))
              .toList() ??
          [],
      availablePaymentMethods:
          (json['availablePaymentMethods'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      couponCode: json['couponCode']?.toString(),
      couponDiscount: json['couponDiscount'] is num
          ? (json['couponDiscount'] as num).toDouble()
          : double.tryParse(json['couponDiscount']?.toString() ?? '0'),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  CheckoutSession copyWith({
    String? checkoutId,
    List<CheckoutItem>? items,
    CheckoutSummary? summary,
    Address? shippingAddress,
    Address? billingAddress,
    List<ShippingMethod>? availableShippingMethods,
    List<String>? availablePaymentMethods,
    ShippingMethod? selectedShippingMethod,
    String? couponCode,
    double? couponDiscount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CheckoutSession(
      checkoutId: checkoutId ?? this.checkoutId,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      availableShippingMethods:
          availableShippingMethods ?? this.availableShippingMethods,
      availablePaymentMethods:
          availablePaymentMethods ?? this.availablePaymentMethods,
      selectedShippingMethod:
          selectedShippingMethod ?? this.selectedShippingMethod,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    checkoutId,
    items,
    summary,
    shippingAddress,
    billingAddress,
    availableShippingMethods,
    availablePaymentMethods,
    selectedShippingMethod,
    couponCode,
    couponDiscount,
    createdAt,
    updatedAt,
  ];
}

class CouponResponse extends Equatable {
  final String couponCode;
  final double discountAmount;
  final String discountType;
  final double newTotal;
  final CheckoutSummary summary;

  const CouponResponse({
    required this.couponCode,
    required this.discountAmount,
    required this.discountType,
    required this.newTotal,
    required this.summary,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      couponCode: json['couponCode']?.toString() ?? '',
      discountAmount: json['discountAmount'] is num
          ? (json['discountAmount'] as num).toDouble()
          : double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      discountType: json['discountType']?.toString() ?? '',
      newTotal: json['newTotal'] is num
          ? (json['newTotal'] as num).toDouble()
          : double.tryParse(json['newTotal']?.toString() ?? '0') ?? 0.0,
      summary: CheckoutSummary.fromJson(json['summary'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    couponCode,
    discountAmount,
    discountType,
    newTotal,
    summary,
  ];
}

class CustomerInfo extends Equatable {
  final String email;
  final String firstName;
  final String lastName;
  final String phone;

  const CustomerInfo({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [email, firstName, lastName, phone];
}

class Order extends Equatable {
  final String orderId;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final double total;
  final List<CheckoutItem> items;
  final Address? shippingAddress;
  final Address? billingAddress;
  final String? trackingNumber;
  final String? estimatedDelivery;
  final DateTime? createdAt;
  final String? paymentUrl;
  final CheckoutSummary orderSummary;

  const Order({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.items,
    this.shippingAddress,
    this.billingAddress,
    this.trackingNumber,
    this.estimatedDelivery,
    this.createdAt,
    this.paymentUrl,
    required this.orderSummary,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    AppLogger.checkout('📦 Order.fromJson: Parsing order data: $json');
    AppLogger.checkout(
      '📦 Order.fromJson: Available keys: ${json.keys.toList()}',
    );

    final orderId = json['id']?.toString() ?? '';
    final orderNumber = json['orderNumber']?.toString() ?? '';
    final status = json['status']?.toString() ?? '';
    final paymentStatus = json['paymentStatus']?.toString() ?? '';
    final total = json['totalAmount'] is num
        ? (json['totalAmount'] as num).toDouble()
        : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;

    AppLogger.checkout('📦 Order.fromJson: Parsed values:');
    AppLogger.checkout('  - orderId: "$orderId"');
    AppLogger.checkout('  - orderNumber: "$orderNumber"');
    AppLogger.checkout('  - status: "$status"');
    AppLogger.checkout('  - paymentStatus: "$paymentStatus"');
    AppLogger.checkout('  - total: $total');
    AppLogger.checkout(
      '  - items count: ${(json['items'] as List?)?.length ?? 0}',
    );
    AppLogger.checkout(
      '  - shippingAddress: ${json['shippingAddress'] != null ? 'present' : 'null'}',
    );
    AppLogger.checkout(
      '  - billingAddress: ${json['billingAddress'] != null ? 'present' : 'null'}',
    );
    AppLogger.checkout(
      '  - orderSummary: ${json['orderSummary'] != null ? 'present' : 'null'}',
    );

    // Build items: prefer top-level items, otherwise try summary.items
    final List<CheckoutItem> orderItems =
        (json['items'] as List?)?.map((e) => CheckoutItem.fromJson(e)).toList() ??
        (json['summary']?['items'] as List?)
                ?.map((e) => CheckoutItem.fromJson(e))
                .toList() ??
            [];

    // Build summary: prefer provided orderSummary/summary, else derive from items
    CheckoutSummary parsedSummary;
    try {
      final summaryData = (json['orderSummary'] as Map<String, dynamic>?) ??
          (json['summary'] as Map<String, dynamic>?) ??
          <String, dynamic>{
            'subtotal': json['subtotal'] ?? json['subTotal'],
            'shippingAmount': json['shippingAmount'] ?? json['shipping_amount'],
            'taxAmount': json['taxAmount'] ?? json['tax_amount'],
            'discountAmount': json['discountAmount'] ?? json['discount_amount'],
            'totalAmount': json['totalAmount'] ?? json['total'],
          };

      parsedSummary = CheckoutSummary.fromJson(summaryData);

      // If zeros and we have items, recalc from items
      if (parsedSummary.subtotal == 0.0 && parsedSummary.total == 0.0 && orderItems.isNotEmpty) {
        parsedSummary = CheckoutSummary.fromItems(orderItems);
      }
    } catch (_) {
      parsedSummary = CheckoutSummary.fromItems(orderItems);
    }

    return Order(
      orderId: orderId,
      orderNumber: orderNumber,
      status: status,
      paymentStatus: paymentStatus,
      total: total,
      items: orderItems,
      shippingAddress: json['shippingAddress'] != null
          ? Address.fromJson(json['shippingAddress'])
          : null,
      billingAddress: json['billingAddress'] != null
          ? Address.fromJson(json['billingAddress'])
          : null,
      trackingNumber: json['trackingNumber']?.toString(),
      estimatedDelivery: json['estimatedDeliveryDate']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      paymentUrl: json['paymentUrl']?.toString(),
      orderSummary: parsedSummary,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    orderNumber,
    status,
    paymentStatus,
    total,
    items,
    shippingAddress,
    billingAddress,
    trackingNumber,
    estimatedDelivery,
    createdAt,
    paymentUrl,
    orderSummary,
  ];

  @override
  String toString() {
    return 'Order(orderId: $orderId, orderNumber: $orderNumber, status: $status, paymentStatus: $paymentStatus, total: $total, itemsCount: ${items.length}, shippingAddress: ${shippingAddress?.toString() ?? 'null'}, billingAddress: ${billingAddress?.toString() ?? 'null'}, createdAt: $createdAt)';
  }
}
