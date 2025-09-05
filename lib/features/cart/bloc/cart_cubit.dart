import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cart_models.dart';
import '../repositories/cart_repository.dart';

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
      print('🔍 CartCubit: Loading cart...');
      final items = await _repo.items(userData);
      print('🔍 CartCubit: Loaded ${items.length} items');
      
      // Fetch summary from API to get correct pricing (including taxes, discounts, etc.)
      CartSummary? summary;
      try {
        summary = await _repo.summary(userData);
        print('🔍 CartCubit: Loaded summary from API - Total: ${summary.total}, ItemsCount: ${summary.itemsCount}');
      } catch (e) {
        print('🔍 CartCubit: Error loading summary from API, calculating locally: $e');
        // Fallback to local calculation if API fails
        summary = _calculateSummary(items);
        print('🔍 CartCubit: Calculated summary locally - Total: ${summary.total}, ItemsCount: ${summary.itemsCount}');
      }
      
      emit(state.copyWith(status: CartStatus.loaded, items: items, summary: summary));
    } catch (e) {
      print('🔍 CartCubit: Error loading cart: $e');
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh(Map<String, dynamic> userData) async {
    print('🔍 CartCubit: Refreshing cart...');
    await load(userData);
  }

  Future<void> refreshSummary(Map<String, dynamic> userData) async {
    try {
      print('🔍 CartCubit: Refreshing summary...');
      final summary = await _repo.summary(userData);
      print('🔍 CartCubit: Refreshed summary from API - Total: ${summary.total}');
      emit(state.copyWith(summary: summary));
    } catch (e) {
      print('🔍 CartCubit: Error refreshing summary: $e');
      // Don't emit error state for summary refresh failure
    }
  }

  Future<void> add({
    required Map<String, dynamic> userData,
    required String productId,
    int quantity = 1,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.add(userData: userData, productId: productId, quantity: quantity, variants: variants, price: price);
      await load(userData);
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(actionInProgress: false));
      _isOperationInProgress = false;
    }
  }

  Future<void> updateQuantity(Map<String, dynamic> userData, String cartItemId, int quantity) async {
    if (_isOperationInProgress) return;
    
    _isOperationInProgress = true;
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.update(userData: userData, cartItemId: cartItemId, quantity: quantity);
      await load(userData);
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
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
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
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
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(actionInProgress: false));
      _isOperationInProgress = false;
    }
  }

  void reset() {
    emit(const CartState.initial());
  }

  /// Calculate cart summary from items
  CartSummary _calculateSummary(List<CartItem> items) {
    final itemsCount = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final subtotal = items.fold<double>(0.0, (sum, item) => sum + item.lineTotal);
    const discount = 0.0; // No discount applied for now
    final total = subtotal - discount;
    
    print('🔍 CartCubit: _calculateSummary details:');
    print('  - Items: ${items.length}');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      print('    Item $i: ${item.name} - Qty: ${item.quantity}, Price: ${item.price}, LineTotal: ${item.lineTotal}');
    }
    print('  - ItemsCount: $itemsCount');
    print('  - Subtotal: $subtotal');
    print('  - Total: $total');
    
    return CartSummary(
      itemsCount: itemsCount,
      subtotal: subtotal,
      discount: discount,
      total: total,
    );
  }
}


