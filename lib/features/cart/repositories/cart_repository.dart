import '../models/cart_models.dart';
import '../services/cart_api_service.dart';

abstract class CartRepository {
  Future<CartItem> add({
    required String productId,
    int quantity,
    List<VariantSelection>? variants,
    double? price,
  });
  Future<List<CartItem>> items();
  Future<CartSummary> summary();
  Future<Map<String, dynamic>> validateCoupon();
  Future<CartItem> update({required String cartItemId, int? quantity, List<VariantSelection>? variants, double? price});
  Future<void> remove(String cartItemId);
  Future<void> clear();
}

class CartRepositoryImpl implements CartRepository {
  final CartApiService _api;
  CartRepositoryImpl({CartApiService? api}) : _api = api ?? CartApiService();

  @override
  Future<CartItem> add({required String productId, int quantity = 1, List<VariantSelection>? variants, double? price}) {
    return _api.addToCart(productId: productId, quantity: quantity, variants: variants, price: price);
  }

  @override
  Future<void> clear() => _api.clearCart();

  @override
  Future<List<CartItem>> items() => _api.getItems();

  @override
  Future<void> remove(String cartItemId) => _api.removeItem(cartItemId);

  @override
  Future<CartSummary> summary() => _api.getSummary();

  @override
  Future<CartItem> update({required String cartItemId, int? quantity, List<VariantSelection>? variants, double? price}) {
    return _api.updateItem(cartItemId: cartItemId, quantity: quantity, variants: variants, price: price);
  }

  @override
  Future<Map<String, dynamic>> validateCoupon() => _api.validateCoupon();
}


