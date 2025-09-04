import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../models/cart_models.dart';

class CartApiService {
  final Dio _dio = DioClient.instance;

  String get _v1 => '/${AppConfig.apiVersion}';

  Future<CartItem> addToCart({
    required String productId,
    int quantity = 1,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    final response = await _dio.post(
      '$_v1/cart/add',
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

  Future<List<CartItem>> getItems() async {
    // Get user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(AppConfig.userKey);
    
    if (userStr == null) {
      throw Exception('User not logged in');
    }
    
    final userData = jsonDecode(userStr) as Map<String, dynamic>;
    print('User ===> $userData');
    final userId = userData['id'] as String?;
    
    if (userId == null) {
      throw Exception('User ID not found in stored user data');
    }
    
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
    return list
        .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CartSummary> getSummary() async {
    print('🔍 Cart API: Getting summary with headers: ${_dio.options.headers}');
    final response = await _dio.get('$_v1/cart/summary');
    print('🔍 Cart Summary Response: ${response.data}');
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    return CartSummary.fromJson(Map<String, dynamic>.from(data['data'] ?? {}));
  }

  Future<Map<String, dynamic>> validateCoupon() async {
    final response = await _dio.get('$_v1/cart/coupon-validation');
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    return Map<String, dynamic>.from(data['data'] ?? {});
  }

  Future<CartItem> updateItem({
    required String cartItemId,
    int? quantity,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    final response = await _dio.put(
      '$_v1/cart/$cartItemId',
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

  Future<void> removeItem(String cartItemId) async {
    await _dio.delete('$_v1/cart/remove/$cartItemId');
  }

  Future<void> clearCart() async {
    await _dio.delete('$_v1/cart/clear');
  }
}
