import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cart_models.dart';
import '../repositories/cart_repository.dart';
import '../../../core/utils/app_logger.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repo;
  bool _isOperationInProgress = false;

  CartCubit({CartRepository? repository})
    : _repo = repository ?? CartRepositoryImpl(),
      super(const CartState.initial());

  Future<void> load(Map<String, dynamic> userData) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final items = await _repo.items(userData);
      // Fetch summary from API to get correct pricing (including taxes, discounts, etc.)
      CartSummary? summary;
      try {
        summary = await _repo.summary(userData);
      } catch (e) {
        summary = _calculateSummary(items);
      }

      emit(
        state.copyWith(
          status: CartStatus.loaded,
          items: items,
          summary: summary,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> refresh(Map<String, dynamic> userData) async {
    await load(userData);
  }

  Future<void> refreshSummary(Map<String, dynamic> userData) async {
    try {
      final summary = await _repo.summary(userData);

      emit(state.copyWith(summary: summary));
    } catch (e) {
      AppLogger.cart('Error refreshing summary: $e');
    }
  }

  Future<void> add({
    required Map<String, dynamic> userData,
    required String productId,
    int quantity = 1,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    if (_isOperationInProgress) {
      return;
    }

    _isOperationInProgress = true;

    try {
      emit(state.copyWith(actionInProgress: true));

      await _repo.add(
        userData: userData,
        productId: productId,
        quantity: quantity,
        variants: variants,
        price: price,
      );

      await load(userData);
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    } finally {
      emit(state.copyWith(actionInProgress: false));
      _isOperationInProgress = false;
    }
  }

  Future<void> updateQuantity(
    Map<String, dynamic> userData,
    String cartItemId,
    int quantity,
  ) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.update(
        userData: userData,
        cartItemId: cartItemId,
        quantity: quantity,
      );
      await load(userData);
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    } finally {
      emit(state.copyWith(actionInProgress: false));
      _isOperationInProgress = false;
    }
  }

  Future<void> remove(Map<String, dynamic> userData, String cartItemId) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.remove(userData, cartItemId);
      await load(userData);
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    } finally {
      emit(state.copyWith(actionInProgress: false));
      _isOperationInProgress = false;
    }
  }

  Future<void> clear(Map<String, dynamic> userData) async {
    if (_isOperationInProgress) return;

    _isOperationInProgress = true;
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.clear(userData);
      await load(userData);
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    } finally {
      emit(state.copyWith(actionInProgress: false));
      _isOperationInProgress = false;
    }
  }

  void reset() {
    AppLogger.cart('Resetting cart state');
    emit(const CartState.initial());
    AppLogger.cart('Cart state reset to initial');
  }

  /// Calculate cart summary from items
  CartSummary _calculateSummary(List<CartItem> items) {
    final itemsCount = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.lineTotal,
    );
    const discount = 0.0; // No discount applied for now
    final total = subtotal - discount;

    return CartSummary(
      itemsCount: itemsCount,
      subtotal: subtotal,
      discount: discount,
      total: total,
    );
  }
}
