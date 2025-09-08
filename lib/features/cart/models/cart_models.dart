import 'package:equatable/equatable.dart';

class VariantSelection extends Equatable {
  final String? attributeId;
  final String? attributeValueId;
  final String? attributeValue;

  const VariantSelection({
    this.attributeId,
    this.attributeValueId,
    this.attributeValue,
  });

  Map<String, dynamic> toJson() => {
    if (attributeId != null) 'attributeId': attributeId,
    if (attributeValueId != null) 'attributeValueId': attributeValueId,
    if (attributeValue != null) 'attributeValue': attributeValue,
  };

  @override
  List<Object?> get props => [attributeId, attributeValueId, attributeValue];
}

class CartItem extends Equatable {
  final String id; // cart item id
  final String productId;
  final String name;
  final String? thumbnailUrl;
  final int quantity;
  final double price; // unit price selected
  final double lineTotal; // price * qty
  final List<VariantSelection> variants;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    required this.variants,
    this.thumbnailUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Helper function to safely convert to int
    int toInt(dynamic value) {
      if (value == null) return 1;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 1;
      }
      return 1;
    }

    // Helper function to safely parse variants
    List<VariantSelection> parseVariants(Map<String, dynamic> json) {
      try {
        final variantsData = json['variants'];
        if (variantsData == null) {
          return const [];
        }

        if (variantsData is! List) {
          return const [];
        }

        if (variantsData.isEmpty) {
          return const [];
        }

        final variants = <VariantSelection>[];
        for (int i = 0; i < variantsData.length; i++) {
          try {
            final variantData = variantsData[i];
            if (variantData is Map<String, dynamic>) {
              final variant = VariantSelection(
                attributeId: variantData['attributeId']?.toString(),
                attributeValueId: variantData['attributeValueId']?.toString(),
                attributeValue: variantData['attributeValue']?.toString(),
              );
              variants.add(variant);
            }
          } catch (e) {
            // Skip invalid variants
          }
        }

        return variants;
      } catch (e) {
        return const [];
      }
    }

    final quantity = toInt(json['quantity']);
    final price = toDouble(json['price'] ?? json['unitPrice']);
    final lineTotalFromApi = toDouble(json['lineTotal'] ?? json['total']);
    // Extract thumbnail URL - handle both string and object formats
    String? thumbnailUrl;
    final productThumbnailImg = json['product']?['thumbnailImg'];
    if (productThumbnailImg is String) {
      thumbnailUrl = productThumbnailImg;
    } else if (productThumbnailImg is Map<String, dynamic>) {
      thumbnailUrl = productThumbnailImg['url']?.toString();
    } else {
      thumbnailUrl = json['thumbnailUrl']?.toString();
    }
    List<VariantSelection> variants;
    try {
      variants = parseVariants(json);
    } catch (e) {
      variants = const [];
    }
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name:
          json['product']?['name']?.toString() ??
          json['name']?.toString() ??
          'Product',
      thumbnailUrl: thumbnailUrl,
      quantity: quantity,
      price: price,
      lineTotal: lineTotalFromApi > 0
          ? lineTotalFromApi
          : price * quantity, // Fallback calculation
      variants: variants,
    );
  }

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    productId: productId,
    name: name,
    thumbnailUrl: thumbnailUrl,
    quantity: quantity ?? this.quantity,
    price: price,
    lineTotal: price * (quantity ?? this.quantity),
    variants: variants,
  );

  @override
  List<Object?> get props => [
    id,
    productId,
    name,
    thumbnailUrl,
    quantity,
    price,
    lineTotal,
    variants,
  ];

  @override
  String toString() {
    return 'CartItem(id: $id, name: $name, quantity: $quantity, price: $price, lineTotal: $lineTotal)';
  }
}

class CartSummary extends Equatable {
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double total;

  const CartSummary({
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Helper function to safely convert to int
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    final itemsCount = toInt(
      json['totalItems'] ?? json['itemsCount'] ?? json['count'],
    );

    final subtotal = toDouble(json['totalAmount'] ?? json['subtotal']);
    final discount = toDouble(json['discount'] ?? 0.0);
    final total = toDouble(json['totalAmount'] ?? json['total']);

    return CartSummary(
      itemsCount: itemsCount,
      subtotal: subtotal,
      discount: discount,
      total: total,
    );
  }

  @override
  List<Object?> get props => [itemsCount, subtotal, discount, total];

  @override
  String toString() {
    return 'CartSummary(itemsCount: $itemsCount, subtotal: $subtotal, discount: $discount, total: $total)';
  }
}
