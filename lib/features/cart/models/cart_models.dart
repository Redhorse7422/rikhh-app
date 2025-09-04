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
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['product']?['name']?.toString() ?? json['name']?.toString() ?? 'Product',
      thumbnailUrl: (json['product']?['thumbnailImg']?['url'] ?? json['thumbnailUrl'])?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: ((json['price'] ?? json['unitPrice']) as num?)?.toDouble() ?? 0.0,
      lineTotal: ((json['lineTotal'] ?? json['total']) as num?)?.toDouble() ?? 0.0,
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
}

class CartSummary extends Equatable {
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double total;

  const CartSummary({required this.itemsCount, required this.subtotal, required this.discount, required this.total});

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [itemsCount, subtotal, discount, total];
}


