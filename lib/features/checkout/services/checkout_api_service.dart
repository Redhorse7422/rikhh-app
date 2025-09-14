import 'package:dio/dio.dart';
import '../../../core/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../models/checkout_models.dart';

class CheckoutApiService {
  final Dio _dio = DioClient.instance;

  String get _v1 => '/${AppConfig.apiVersion}';

  /// Phase 1: Address Management

  /// Get user addresses
  Future<List<Address>> getAddresses(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.get('$_v1/checkout/addresses');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        // Handle the nested structure: data.shipping and data.billing
        final dataContent = data['data'] as Map<String, dynamic>? ?? {};
        final shippingAddresses = (dataContent['shipping'] as List?) ?? [];
        final billingAddresses = (dataContent['billing'] as List?) ?? [];

        // Combine all addresses into a single list
        final allAddresses = [...shippingAddresses, ...billingAddresses];

        final addresses = allAddresses.map((e) {
          return Address.fromJson(Map<String, dynamic>.from(e));
        }).toList();
        return addresses;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get default addresses
  Future<DefaultAddresses> getDefaultAddresses(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _dio.get('$_v1/checkout/addresses/default');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        final dataContent = data['data'] as Map<String, dynamic>? ?? {};

        dynamic shippingData = dataContent['shipping'];
        dynamic billingData = dataContent['billing'];

        Address? shippingAddress;
        Address? billingAddress;

        if (shippingData != null) {
          if (shippingData is List) {
            shippingAddress = shippingData.isNotEmpty
                ? Address.fromJson(
                    Map<String, dynamic>.from(shippingData.first),
                  )
                : null;
          } else if (shippingData is Map) {
            shippingAddress = Address.fromJson(
              Map<String, dynamic>.from(shippingData),
            );
          }
        }

        if (billingData != null) {
          if (billingData is List) {
            billingAddress = billingData.isNotEmpty
                ? Address.fromJson(Map<String, dynamic>.from(billingData.first))
                : null;
          } else if (billingData is Map) {
            billingAddress = Address.fromJson(
              Map<String, dynamic>.from(billingData),
            );
          }
        }

        // Create the default addresses object directly
        final defaultAddresses = DefaultAddresses(
          shippingAddress: shippingAddress,
          billingAddress: billingAddress,
        );

        return defaultAddresses;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create new address
  Future<Address> createAddress(
    Map<String, dynamic> userData,
    Address address,
  ) async {
    try {
      final response = await _dio.post(
        '$_v1/addresses',
        data: address.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        final addressData = data['data'] ?? {};

        final createdAddress = Address.fromJson(addressData);

        return createdAddress;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update address
  Future<Address> updateAddress(
    Map<String, dynamic> userData,
    String addressId,
    Address address,
  ) async {
    try {
      final response = await _dio.put(
        '$_v1/addresses/$addressId',
        data: address.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        final addressData = data['data'] ?? {};

        final updatedAddress = Address.fromJson(addressData);

        return updatedAddress;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete address
  Future<void> deleteAddress(
    Map<String, dynamic> userData,
    String addressId,
  ) async {
    try {
      final response = await _dio.delete('$_v1/addresses/$addressId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Set address as default
  Future<Address> setDefaultAddress(
    Map<String, dynamic> userData,
    String addressId,
  ) async {
    try {
      final response = await _dio.put('$_v1/addresses/$addressId/default');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        final addressData = data['data'] ?? {};

        final updatedAddress = Address.fromJson(addressData);

        return updatedAddress;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Phase 2: Checkout Initiation

  /// Initiate checkout
  Future<CheckoutSession> initiateCheckout({
    required Map<String, dynamic> userData,
    required String checkoutType,
    required String shippingAddressId,
    required String billingAddressId,
  }) async {
    try {
      final response = await _dio.post(
        '$_v1/checkout/initiate',
        data: {
          'checkoutType': checkoutType,
          'shippingAddressId': shippingAddressId,
          'billingAddressId': billingAddressId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);
        final checkoutData = data['data'] ?? {};

        final checkoutSession = CheckoutSession.fromJson(checkoutData);

        return checkoutSession;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {}
      }
      rethrow;
    }
  }

  /// Apply coupon
  Future<CouponResponse> applyCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String couponCode,
    required List<CheckoutItem> items,
  }) async {
    try {
      final response = await _dio.post(
        '$_v1/checkout/apply-coupon',
        data: {
          'checkoutId': checkoutId,
          'couponCode': couponCode,
          'items': items
              .map(
                (e) => {
                  'productId': e.productId,
                  'quantity': e.quantity,
                  'unitPrice': e.unitPrice,
                },
              )
              .toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return CouponResponse.fromJson(data['data'] ?? {});
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {}
      }
      rethrow;
    }
  }

  /// Get checkout session (optional - review before confirming)
  Future<CheckoutSession> getCheckoutSession({
    required Map<String, dynamic> userData,
    required String checkoutId,
  }) async {
    try {
      final response = await _dio.get('$_v1/checkout/session/$checkoutId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);
        final checkoutData = data['data'] ?? {};

        return CheckoutSession.fromJson(checkoutData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {}
      }
      rethrow;
    }
  }

  /// Confirm order (place order)
  Future<Order> confirmOrder({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required CustomerInfo customerInfo,
    String? notes,
    String? couponCode,
  }) async {
    try {
      final requestData = {
        'checkoutId': checkoutId,
        'userId': userData['id'],
        'customerInfo': customerInfo.toJson(),
        if (notes != null) 'notes': notes,
        if (couponCode != null) 'couponCode': couponCode,
      };

      final response = await _dio.post(
        '$_v1/checkout/confirm-order',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        // Validate response structure
        if (data['code'] != 0 && data['success'] != true) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error:
                'Order confirmation failed: ${data['message'] ?? 'Unknown error'}',
          );
        }

        final dataContent = data['data'] ?? {};
        final orderData = dataContent['order'] ?? {};

        // Validate that we have order data
        if (orderData.isEmpty) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Order confirmation failed: No order data in response',
          );
        }

        // Validate required order fields
        if (orderData['id'] == null || orderData['orderNumber'] == null) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Order confirmation failed: Missing required order fields',
          );
        }

        final order = Order.fromJson(orderData);

        return order;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {}
      }
      rethrow;
    }
  }

  /// Update shipping method
  Future<CheckoutSession> updateShippingMethod({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String shippingMethodId,
  }) async {
    try {
      final response = await _dio.put(
        '$_v1/checkout/shipping-method',
        data: {'checkoutId': checkoutId, 'shippingMethodId': shippingMethodId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return CheckoutSession.fromJson(data['data'] ?? {});
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {}
      }
      rethrow;
    }
  }

  /// Remove coupon
  Future<CheckoutSession> removeCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
  }) async {
    try {
      final response = await _dio.delete(
        '$_v1/checkout/coupon',
        data: {'checkoutId': checkoutId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data);

        return CheckoutSession.fromJson(data['data'] ?? {});
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {}
      }
      rethrow;
    }
  }
}
