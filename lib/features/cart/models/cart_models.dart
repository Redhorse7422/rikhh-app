import 'package:equatable/equatable.dart';

class VariantSelection extends Equatable {
  final String? attributeId;
  final String? attributeValueId;
  final String? attributeValue;

  const VariantSelection({this.attributeId, this.attributeValueId, this.attributeValue});

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
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Helper function to safely convert to int
    int _toInt(dynamic value) {
      if (value == null) return 1;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 1;
      }
      return 1;
    }

    final quantity = _toInt(json['quantity']);
    final price = _toDouble(json['price'] ?? json['unitPrice']);
    final lineTotalFromApi = _toDouble(json['lineTotal'] ?? json['total']);
    final calculatedLineTotal = price * quantity;
    
    print('🔍 CartItem.fromJson: Parsing item data:');
    print('  - Raw JSON: $json');
    print('  - quantity: ${json['quantity']} -> $quantity');
    print('  - price: ${json['price'] ?? json['unitPrice']} -> $price');
    print('  - lineTotal from API: ${json['lineTotal'] ?? json['total']} -> $lineTotalFromApi');
    print('  - calculated lineTotal: $calculatedLineTotal');
    print('  - final lineTotal: ${lineTotalFromApi > 0 ? lineTotalFromApi : calculatedLineTotal}');
    
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['product']?['name']?.toString() ?? json['name']?.toString() ?? 'Product',
      thumbnailUrl: (json['product']?['thumbnailImg']?['url'] ?? json['thumbnailUrl'])?.toString(),
      quantity: quantity,
      price: price,
      lineTotal: lineTotalFromApi > 0 ? lineTotalFromApi : price * quantity, // Fallback calculation
      variants: (json['variants'] as List?)
              ?.map((e) => VariantSelection(
                    attributeId: e['attributeId']?.toString(),
                    attributeValueId: e['attributeValueId']?.toString(),
                    attributeValue: e['attributeValue']?.toString(),
                  ))
              .toList() ??
          const [],
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
  List<Object?> get props => [id, productId, name, thumbnailUrl, quantity, price, lineTotal, variants];

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

  const CartSummary({required this.itemsCount, required this.subtotal, required this.discount, required this.total});

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Helper function to safely convert to int
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    final itemsCount = _toInt(json['totalItems'] ?? json['itemsCount'] ?? json['count']);
    final subtotal = _toDouble(json['totalAmount'] ?? json['subtotal']);
    final discount = _toDouble(json['discount'] ?? 0.0);
    final total = _toDouble(json['totalAmount'] ?? json['total']);
    
    print('🔍 CartSummary.fromJson: Parsing summary data:');
    print('  - Raw JSON: $json');
    print('  - totalItems: ${json['totalItems']} -> itemsCount: $itemsCount');
    print('  - totalAmount: ${json['totalAmount']} -> subtotal: $subtotal, total: $total');
    print('  - discount: ${json['discount']} -> $discount');
    
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


