import 'package:dio/dio.dart';
import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../models/cart_models.dart';

class CartApiService {
  final Dio _dio = DioClient.instance;

  String get _v1 => '/${AppConfig.apiVersion}';

  /// Get user ID from user data
  String _getUserId(Map<String, dynamic> userData) {
    if (userData['id'] == null) {
      throw Exception('User ID not found in user data');
    }
    return userData['id'] as String;
  }

  Future<CartItem> addToCart({
    required Map<String, dynamic> userData,
    required String productId,
    int quantity = 1,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    final userId = _getUserId(userData);
    
    print('🔍 Cart API: Adding to cart for userId: $userId');
    final response = await _dio.post(
      '$_v1/cart/add',
      queryParameters: {'userId': userId},
      data: {
        'productId': productId,
        if (quantity > 0) 'quantity': quantity,
        if (variants != null && variants.isNotEmpty)
          'variants': variants.map((e) => e.toJson()).toList(),
        if (price != null) 'price': price,
      },
    );
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    final itemJson = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : Map<String, dynamic>.from(data['data']);
    return CartItem.fromJson(itemJson);
  }

  Future<List<CartItem>> getItems(Map<String, dynamic> userData) async {
    final userId = _getUserId(userData);
    
    print('🔍 Cart API: Getting items for userId: $userId with headers: ${_dio.options.headers}');
    final response = await _dio.get(
      '$_v1/cart/items',
      queryParameters: {'userId': userId},
    );
    print('🔍 Cart API Response: ${response.data}');
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    final list = (data['data'] as List?) ?? const [];
    
    print('🔍 Cart API: Processing ${list.length} cart items...');
    try {
      final items = list
          .map((e) {
            print('🔍 Cart API: Processing item: ${e['id']} - ${e['product']?['name']} - Price: ${e['price']} (${e['price'].runtimeType})');
            return CartItem.fromJson(Map<String, dynamic>.from(e));
          })
          .toList();
      print('🔍 Cart API: Successfully parsed ${items.length} cart items');
      return items;
    } catch (e) {
      print('🔍 Cart API: Error parsing cart items: $e');
      rethrow;
    }
  }

  Future<CartSummary> getSummary(Map<String, dynamic> userData) async {
    final userId = _getUserId(userData);
    
    print('🔍 Cart API: Getting summary for userId: $userId with headers: ${_dio.options.headers}');
    final response = await _dio.get(
      '$_v1/cart/summary',
      queryParameters: {'userId': userId},
    );
    print('🔍 Cart Summary Response: ${response.data}');
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    return CartSummary.fromJson(Map<String, dynamic>.from(data['data'] ?? {}));
  }

  Future<Map<String, dynamic>> validateCoupon(Map<String, dynamic> userData) async {
    final userId = _getUserId(userData);
    
    print('🔍 Cart API: Validating coupon for userId: $userId');
    final response = await _dio.get(
      '$_v1/cart/coupon-validation',
      queryParameters: {'userId': userId},
    );
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    return Map<String, dynamic>.from(data['data'] ?? {});
  }

  Future<CartItem> updateItem({
    required Map<String, dynamic> userData,
    required String cartItemId,
    int? quantity,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    final userId = _getUserId(userData);
    
    print('🔍 Cart API: Updating item $cartItemId for userId: $userId');
    final response = await _dio.put(
      '$_v1/cart/$cartItemId',
      queryParameters: {'userId': userId},
      data: {
        if (quantity != null && quantity > 0) 'quantity': quantity,
        if (variants != null && variants.isNotEmpty)
          'variants': variants.map((e) => e.toJson()).toList(),
        if (price != null) 'price': price,
      },
    );
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    return CartItem.fromJson(Map<String, dynamic>.from(data['data'] ?? {}));
  }

  Future<void> removeItem(Map<String, dynamic> userData, String cartItemId) async {
    final userId = _getUserId(userData);
    
    print('🔍 Cart API: Removing item $cartItemId for userId: $userId');
    await _dio.delete(
      '$_v1/cart/remove/$cartItemId',
      queryParameters: {'userId': userId},
    );
  }

  Future<void> clearCart(Map<String, dynamic> userData) async {
    final userId = _getUserId(userData);
    
    print('🔍 Cart API: Clearing cart for userId: $userId');
    await _dio.delete(
      '$_v1/cart/clear',
      queryParameters: {'userId': userId},
    );
  }
}
