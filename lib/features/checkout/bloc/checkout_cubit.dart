import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rikhh_app/features/checkout/bloc/checkout_state.dart';
import '../models/checkout_models.dart';
import '../services/checkout_api_service.dart';
import '../../cart/bloc/cart_cubit.dart';
import '../../cart/services/cart_api_service.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutApiService _apiService;
  final CartCubit? _cartCubit;
  final CartApiService _cartApiService;
  bool _isOperationInProgress = false;

  // Cache to avoid unnecessary API calls
  DateTime? _lastAddressLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  CheckoutCubit({
    CheckoutApiService? apiService,
    CartCubit? cartCubit,
    CartApiService? cartApiService,
  }) : _apiService = apiService ?? CheckoutApiService(),
       _cartCubit = cartCubit,
       _cartApiService = cartApiService ?? CartApiService(),
       super(const CheckoutState());

  /// Address Management

  /// Load user addresses
  Future<void> loadAddresses(Map<String, dynamic> userData) async {
    if (_isOperationInProgress) {
      return;
    }

    // Check cache first
    if (state.addresses.isNotEmpty &&
        _lastAddressLoadTime != null &&
        DateTime.now().difference(_lastAddressLoadTime!) < _cacheTimeout) {
      return;
    }

    _isOperationInProgress = true;
    emit(state.copyWith(status: CheckoutStatus.addressLoading));

    try {
      final addresses = await _apiService.getAddresses(userData);
      _lastAddressLoadTime = DateTime.now();

      emit(
        state.copyWith(
          status: CheckoutStatus.addressLoaded,
          addresses: addresses,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.addressError,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Load default addresses
  Future<void> loadDefaultAddresses(Map<String, dynamic> userData) async {
    if (_isOperationInProgress) {
      return;
    }

    _isOperationInProgress = true;
    emit(state.copyWith(status: CheckoutStatus.addressLoading));

    try {
      final defaultAddresses = await _apiService.getDefaultAddresses(userData);

      emit(
        state.copyWith(
          status: CheckoutStatus.addressLoaded,
          defaultAddresses: defaultAddresses,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.addressError,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Create new address
  Future<void> createAddress(
    Map<String, dynamic> userData,
    Address address,
  ) async {
    if (_isOperationInProgress) {
      return;
    }

    _isOperationInProgress = true;
    emit(state.copyWith(isOperationInProgress: true));

    try {
      final newAddress = await _apiService.createAddress(userData, address);

      final updatedAddresses = List<Address>.from(state.addresses)
        ..add(newAddress);

      emit(
        state.copyWith(
          addresses: updatedAddresses,
          isOperationInProgress: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isOperationInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Update address
  Future<void> updateAddress(
    Map<String, dynamic> userData,
    String addressId,
    Address address,
  ) async {
    if (_isOperationInProgress) {
      return;
    }

    _isOperationInProgress = true;
    emit(state.copyWith(isOperationInProgress: true));

    try {
      final updatedAddress = await _apiService.updateAddress(
        userData,
        addressId,
        address,
      );

      final updatedAddresses = state.addresses.map((addr) {
        return addr.id == addressId ? updatedAddress : addr;
      }).toList();

      emit(
        state.copyWith(
          addresses: updatedAddresses,
          isOperationInProgress: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isOperationInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Delete address
  Future<void> deleteAddress(
    Map<String, dynamic> userData,
    String addressId,
  ) async {
    if (_isOperationInProgress) {
      return;
    }

    _isOperationInProgress = true;
    emit(state.copyWith(isOperationInProgress: true));

    try {
      await _apiService.deleteAddress(userData, addressId);

      final updatedAddresses = state.addresses
          .where((addr) => addr.id != addressId)
          .toList();

      emit(
        state.copyWith(
          addresses: updatedAddresses,
          isOperationInProgress: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isOperationInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Set address as default
  Future<void> setDefaultAddress(
    Map<String, dynamic> userData,
    String addressId,
  ) async {
    if (_isOperationInProgress) {
      return;
    }

    _isOperationInProgress = true;
    emit(state.copyWith(isOperationInProgress: true));

    try {
      final updatedAddress = await _apiService.setDefaultAddress(
        userData,
        addressId,
      );

      final updatedAddresses = state.addresses.map((addr) {
        if (addr.id == addressId) {
          return updatedAddress;
        } else if (addr.type == updatedAddress.type) {
          // Remove default status from other addresses of the same type
          return addr.copyWith(isDefault: false);
        }
        return addr;
      }).toList();

      emit(
        state.copyWith(
          addresses: updatedAddresses,
          isOperationInProgress: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isOperationInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Checkout Flow

  /// Initiate checkout
  Future<void> initiateCheckout({
    required Map<String, dynamic> userData,
    required String shippingAddressId,
    required String billingAddressId,
    String checkoutType = 'registered',
  }) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    emit(state.copyWith(status: CheckoutStatus.loading));

    try {
      final checkoutSession = await _apiService.initiateCheckout(
        userData: userData,
        checkoutType: checkoutType,
        shippingAddressId: shippingAddressId,
        billingAddressId: billingAddressId,
      );

      emit(
        state.copyWith(
          status: CheckoutStatus.checkoutInitiated,
          checkoutSession: checkoutSession,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Apply coupon
  Future<void> applyCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String couponCode,
  }) async {
    if (_isOperationInProgress || state.checkoutSession == null) return;

    _isOperationInProgress = true;
    emit(state.copyWith(isOperationInProgress: true));

    try {
      final couponResponse = await _apiService.applyCoupon(
        userData: userData,
        checkoutId: checkoutId,
        couponCode: couponCode,
        items: state.checkoutSession!.items,
      );

      // Update checkout session with new summary
      final updatedSession = state.checkoutSession!.copyWith(
        summary: couponResponse.summary,
        couponCode: couponResponse.couponCode,
        couponDiscount: couponResponse.discountAmount,
      );

      emit(
        state.copyWith(
          status: CheckoutStatus.couponApplied,
          checkoutSession: updatedSession,
          appliedCouponCode: couponResponse.couponCode,
          isOperationInProgress: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isOperationInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Remove coupon
  Future<void> removeCoupon({
    required Map<String, dynamic> userData,
    required String checkoutId,
  }) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    emit(state.copyWith(isOperationInProgress: true));

    try {
      final updatedSession = await _apiService.removeCoupon(
        userData: userData,
        checkoutId: checkoutId,
      );

      emit(
        state.copyWith(
          status: CheckoutStatus.couponRemoved,
          checkoutSession: updatedSession,
          appliedCouponCode: null,
          isOperationInProgress: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isOperationInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Update shipping method
  Future<void> updateShippingMethod({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required String shippingMethodId,
  }) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    emit(state.copyWith(isOperationInProgress: true));

    try {
      final updatedSession = await _apiService.updateShippingMethod(
        userData: userData,
        checkoutId: checkoutId,
        shippingMethodId: shippingMethodId,
      );

      // Shipping method updated successfully

      emit(
        state.copyWith(
          status: CheckoutStatus.shippingMethodUpdated,
          checkoutSession: updatedSession,
          selectedShippingMethodId: shippingMethodId,
          isOperationInProgress: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isOperationInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Get checkout session (for review)
  Future<void> getCheckoutSession({
    required Map<String, dynamic> userData,
    required String checkoutId,
  }) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    emit(state.copyWith(status: CheckoutStatus.loading));

    try {
      final checkoutSession = await _apiService.getCheckoutSession(
        userData: userData,
        checkoutId: checkoutId,
      );

      emit(
        state.copyWith(
          status: CheckoutStatus.loaded,
          checkoutSession: checkoutSession,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Confirm order
  Future<void> confirmOrder({
    required Map<String, dynamic> userData,
    required String checkoutId,
    required CustomerInfo customerInfo,
    String? notes,
    String? couponCode,
  }) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    emit(state.copyWith(status: CheckoutStatus.loading));

    try {
      final order = await _apiService.confirmOrder(
        userData: userData,
        checkoutId: checkoutId,
        customerInfo: customerInfo,
        notes: notes,
        couponCode: couponCode,
      );

      // Validate that we have a proper order response
      if (order.orderId.isEmpty || order.orderNumber.isEmpty) {
        throw Exception(
          'Invalid order response: Missing order ID or order number',
        );
      }

      // Only proceed if order has valid data
      if (order.status.isEmpty) {
        throw Exception('Invalid order response: Missing order status');
      }
      // Add a small delay to ensure order is processed on backend
      await Future.delayed(const Duration(seconds: 2));

      // Clear the cart when order is successfully confirmed
      _cartCubit?.reset();

      emit(
        state.copyWith(
          status: CheckoutStatus.orderConfirmed,
          order: order,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isOperationInProgress = false;
    }
  }

  /// Reset state
  void reset() {
    emit(const CheckoutState());
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Set selected shipping method (for UI state)
  void setSelectedShippingMethod(String? shippingMethodId) {
    emit(state.copyWith(selectedShippingMethodId: shippingMethodId));
  }

  /// Recalculate summary from items (fallback method)
  void recalculateSummary() {
    if (state.checkoutSession == null) return;

    final session = state.checkoutSession!;
    final recalculatedSummary = CheckoutSummary.fromItems(session.items);

    final updatedSession = session.copyWith(summary: recalculatedSummary);

    emit(state.copyWith(checkoutSession: updatedSession));
  }

  /// Fetch image data from cart and update checkout items
  Future<void> fetchImagesFromCart(Map<String, dynamic> userData) async {
    if (state.checkoutSession == null) return;

    try {
      // Create a new instance if the current one is null
      final cartService = _cartApiService;
      final cartItems = await cartService.getItems(userData);

      // Create a map of productId -> imageUrl from cart
      final Map<String, String> cartImageMap = {};
      for (final cartItem in cartItems) {
        if (cartItem.thumbnailUrl != null &&
            cartItem.thumbnailUrl!.isNotEmpty) {
          cartImageMap[cartItem.productId] = cartItem.thumbnailUrl!;
        }
      }

      // Update checkout items with images from cart
      final session = state.checkoutSession!;
      final updatedItems = session.items.map((item) {
        if ((item.imageUrl == null || item.imageUrl!.isEmpty) &&
            cartImageMap.containsKey(item.productId)) {
          return CheckoutItem(
            productId: item.productId,
            name: item.name,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            totalPrice: item.totalPrice,
            imageUrl: cartImageMap[item.productId],
          );
        }
        return item;
      }).toList();

      final updatedSession = session.copyWith(items: updatedItems);
      emit(state.copyWith(checkoutSession: updatedSession));
    } catch (e) {
      // Silently handle errors
    }
  }
}
