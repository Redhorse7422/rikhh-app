import 'package:dio/dio.dart';
import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../models/cart_models.dart';
import '../../../core/utils/app_logger.dart';

class CartApiService {
  final Dio _dio = DioClient.instance;

  String get _v1 => '/${AppConfig.apiVersion}';

  /// Get user ID from user data
  String _getUserId(Map<String, dynamic> userData) {
    
    if (userData['id'] == null) {
      throw Exception('User ID not found in user data');
    }
    
    final userId = userData['id'].toString();
    return userId;
  }

  Future<CartItem> addToCart({
    required Map<String, dynamic> userData,
    required String productId,
    int quantity = 1,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    try {
      final userId = _getUserId(userData);

      final requestData = {
        'productId': productId,
        if (quantity > 0) 'quantity': quantity,
        if (variants != null && variants.isNotEmpty)
          'variants': variants.map((e) => e.toJson()).toList(),
        if (price != null) 'price': price,
      };

      final response = await _dio.post(
        '$_v1/cart/add',
        queryParameters: {'userId': userId},
        data: requestData,
      );

      // Only process successful responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);
        final itemJson = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(data['data']);

        return CartItem.fromJson(itemJson);
      } else {
        // Let Dio throw the error so interceptors can handle it
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          AppLogger.cart(
            'Response status: ${e.response?.statusCode}',
          );
          AppLogger.cart('Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  Future<List<CartItem>> getItems(Map<String, dynamic> userData) async {
    final userId = _getUserId(userData);

    final response = await _dio.get(
      '$_v1/cart/items',
      queryParameters: {'userId': userId},
    );

    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    final list = (data['data'] as List?) ?? const [];

    try {
      final items = list.map((e) {
        return CartItem.fromJson(Map<String, dynamic>.from(e));
      }).toList();
      return items;
    } catch (e) {
      rethrow;
    }
  }

  Future<CartSummary> getSummary(Map<String, dynamic> userData) async {
    final userId = _getUserId(userData);

    final response = await _dio.get(
      '$_v1/cart/summary',
      queryParameters: {'userId': userId},
    );
    final data = (response.data is Map<String, dynamic>)
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data);
    
    
    return CartSummary.fromJson(Map<String, dynamic>.from(data['data'] ?? {}));
  }

  Future<Map<String, dynamic>> validateCoupon(
    Map<String, dynamic> userData,
  ) async {
    final userId = _getUserId(userData);

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

  Future<void> removeItem(
    Map<String, dynamic> userData,
    String cartItemId,
  ) async {
    final userId = _getUserId(userData);

    await _dio.delete(
      '$_v1/cart/remove/$cartItemId',
      queryParameters: {'userId': userId},
    );
  }

  Future<void> clearCart(Map<String, dynamic> userData) async {
    final userId = _getUserId(userData);

    await _dio.delete('$_v1/cart/clear', queryParameters: {'userId': userId});
  }
}
