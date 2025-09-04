part of 'cart_cubit.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final CartSummary? summary;
  final String? errorMessage;
  final bool actionInProgress;

  const CartState({
    required this.status,
    required this.items,
    required this.summary,
    required this.errorMessage,
    required this.actionInProgress,
  });

  const CartState.initial()
      : status = CartStatus.initial,
        items = const [],
        summary = null,
        errorMessage = null,
        actionInProgress = false;

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    CartSummary? summary,
    String? errorMessage,
    bool? actionInProgress,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
      actionInProgress: actionInProgress ?? this.actionInProgress,
    );
  }

  @override
  List<Object?> get props => [status, items, summary, errorMessage, actionInProgress];
}


