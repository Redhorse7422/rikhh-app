import 'package:equatable/equatable.dart';
import '../models/checkout_models.dart';

enum CheckoutStatus {
  initial,
  loading,
  loaded,
  error,
  addressLoading,
  addressLoaded,
  addressError,
  checkoutInitiated,
  couponApplied,
  couponRemoved,
  orderConfirmed,
  shippingMethodUpdated,
}

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final String? errorMessage;
  final List<Address> addresses;
  final DefaultAddresses? defaultAddresses;
  final CheckoutSession? checkoutSession;
  final Order? order;
  final bool isOperationInProgress;
  final String? selectedShippingMethodId;
  final String? appliedCouponCode;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.errorMessage,
    this.addresses = const [],
    this.defaultAddresses,
    this.checkoutSession,
    this.order,
    this.isOperationInProgress = false,
    this.selectedShippingMethodId,
    this.appliedCouponCode,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? errorMessage,
    List<Address>? addresses,
    DefaultAddresses? defaultAddresses,
    CheckoutSession? checkoutSession,
    Order? order,
    bool? isOperationInProgress,
    String? selectedShippingMethodId,
    String? appliedCouponCode,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      addresses: addresses ?? this.addresses,
      defaultAddresses: defaultAddresses ?? this.defaultAddresses,
      checkoutSession: checkoutSession ?? this.checkoutSession,
      order: order ?? this.order,
      isOperationInProgress: isOperationInProgress ?? this.isOperationInProgress,
      selectedShippingMethodId: selectedShippingMethodId ?? this.selectedShippingMethodId,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        addresses,
        defaultAddresses,
        checkoutSession,
        order,
        isOperationInProgress,
        selectedShippingMethodId,
        appliedCouponCode,
      ];
}
