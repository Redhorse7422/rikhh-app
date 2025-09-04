import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cart_models.dart';
import '../repositories/cart_repository.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repo;
  CartCubit({CartRepository? repository})
      : _repo = repository ?? CartRepositoryImpl(),
        super(const CartState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      print('🔍 CartCubit: Loading cart...');
      final items = await _repo.items();
      final summary = await _repo.summary();
      print('🔍 CartCubit: Loaded ${items.length} items, summary: $summary');
      emit(state.copyWith(status: CartStatus.loaded, items: items, summary: summary));
    } catch (e) {
      print('🔍 CartCubit: Error loading cart: $e');
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> add({
    required String productId,
    int quantity = 1,
    List<VariantSelection>? variants,
    double? price,
  }) async {
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.add(productId: productId, quantity: quantity, variants: variants, price: price);
      await load();
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(actionInProgress: false));
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.update(cartItemId: cartItemId, quantity: quantity);
      await load();
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(actionInProgress: false));
    }
  }

  Future<void> remove(String cartItemId) async {
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.remove(cartItemId);
      await load();
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(actionInProgress: false));
    }
  }

  Future<void> clear() async {
    try {
      emit(state.copyWith(actionInProgress: true));
      await _repo.clear();
      await load();
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(actionInProgress: false));
    }
  }
}


