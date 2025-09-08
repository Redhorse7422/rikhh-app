import '../models/checkout_models.dart';
import '../services/checkout_api_service.dart';

abstract class CheckoutRepository {
  Future<List<Address>> getAddresses(Map<String, dynamic> userData);
  Future<DefaultAddresses> getDefaultAddresses(Map<String, dynamic> userData);
  Future<Address> createAddress(Map<String, dynamic> userData, Address address);
  Future<CheckoutSession> initiateCheckout({
    required Map<String, dynamic> userData,
    required String shippingAddressId,
    required String billingAddressId,
    String checkoutType = 'registered',
  });
  Future<CouponResponse> applyCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String couponCode,
    required List<CheckoutItem> items,
  });
  Future<CheckoutSession> removeCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
  });
  Future<CheckoutSession> updateShippingMethod({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String shippingMethodId,
  });
  Future<CheckoutSession> getCheckoutSession({
    required Map<String, dynamic> userData,
    required String checkoutId,
  });
  Future<Order> confirmOrder({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required CustomerInfo customerInfo,
    String? notes,
    String? couponCode,
  });
}

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutApiService _apiService;

  CheckoutRepositoryImpl({CheckoutApiService? apiService})
      : _apiService = apiService ?? CheckoutApiService();

  @override
  Future<List<Address>> getAddresses(Map<String, dynamic> userData) {
    return _apiService.getAddresses(userData);
  }

  @override
  Future<DefaultAddresses> getDefaultAddresses(Map<String, dynamic> userData) {
    return _apiService.getDefaultAddresses(userData);
  }

  @override
  Future<Address> createAddress(Map<String, dynamic> userData, Address address) {
    return _apiService.createAddress(userData, address);
  }

  @override
  Future<CheckoutSession> initiateCheckout({
    required Map<String, dynamic> userData,
    required String shippingAddressId,
    required String billingAddressId,
    String checkoutType = 'registered',
  }) {
    return _apiService.initiateCheckout(
      userData: userData,
      checkoutType: checkoutType,
      shippingAddressId: shippingAddressId,
      billingAddressId: billingAddressId,
    );
  }

  @override
  Future<CouponResponse> applyCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String couponCode,
    required List<CheckoutItem> items,
  }) {
    return _apiService.applyCoupon(
      userData: userData,
      checkoutId: checkoutId,
      couponCode: couponCode,
      items: items,
    );
  }

  @override
  Future<CheckoutSession> removeCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
  }) {
    return _apiService.removeCoupon(
      userData: userData,
      checkoutId: checkoutId,
    );
  }

  @override
  Future<CheckoutSession> updateShippingMethod({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String shippingMethodId,
  }) {
    return _apiService.updateShippingMethod(
      userData: userData,
      checkoutId: checkoutId,
      shippingMethodId: shippingMethodId,
    );
  }

  @override
  Future<CheckoutSession> getCheckoutSession({
    required Map<String, dynamic> userData,
    required String checkoutId,
  }) {
    return _apiService.getCheckoutSession(
      userData: userData,
      checkoutId: checkoutId,
    );
  }

  @override
  Future<Order> confirmOrder({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required CustomerInfo customerInfo,
    String? notes,
    String? couponCode,
  }) {
    return _apiService.confirmOrder(
      userData: userData,
      checkoutId: checkoutId,
      customerInfo: customerInfo,
      notes: notes,
      couponCode: couponCode,
    );
  }
}
