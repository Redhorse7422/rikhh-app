import '../models/cart_models.dart';
import '../services/cart_api_service.dart';

abstract class CartRepository {
  Future<CartItem> add({
    required Map<String, dynamic> userData,
    required String productId,
    int quantity,
    List<VariantSelection>? variants,
    double? price,
  });
  Future<List<CartItem>> items(Map<String, dynamic> userData);
  Future<CartSummary> summary(Map<String, dynamic> userData);
  Future<Map<String, dynamic>> validateCoupon(Map<String, dynamic> userData);
  Future<CartItem> update({
    required Map<String, dynamic> userData,
    required String cartItemId,
    int? quantity,
    List<VariantSelection>? variants,
    double? price,
  });
  Future<void> remove(Map<String, dynamic> userData, String cartItemId);
  Future<void> clear(Map<String, dynamic> userData);
}

class CartRepositoryImpl implements CartRepository {
  final CartApiService _api;
  CartRepositoryImpl({CartApiService? api}) : _api = api ?? CartApiService();

  @override
  Future<CartItem> add({
    required Map<String, dynamic> userData,
    required String productId,
    int quantity = 1,
    List<VariantSelection>? variants,
    double? price,
  }) {
    return _api.addToCart(
      userData: userData,
      productId: productId,
      quantity: quantity,
      variants: variants,
      price: price,
    );
  }

  @override
  Future<void> clear(Map<String, dynamic> userData) => _api.clearCart(userData);

  @override
  Future<List<CartItem>> items(Map<String, dynamic> userData) =>
      _api.getItems(userData);

  @override
  Future<void> remove(Map<String, dynamic> userData, String cartItemId) =>
      _api.removeItem(userData, cartItemId);

  @override
  Future<CartSummary> summary(Map<String, dynamic> userData) =>
      _api.getSummary(userData);

  @override
  Future<CartItem> update({
    required Map<String, dynamic> userData,
    required String cartItemId,
    int? quantity,
    List<VariantSelection>? variants,
    double? price,
  }) {
    return _api.updateItem(
      userData: userData,
      cartItemId: cartItemId,
      quantity: quantity,
      variants: variants,
      price: price,
    );
  }

  @override
  Future<Map<String, dynamic>> validateCoupon(Map<String, dynamic> userData) =>
      _api.validateCoupon(userData);
}
