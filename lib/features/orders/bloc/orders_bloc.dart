import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/order_model.dart';
import '../models/order_status_update_model.dart';
import '../services/orders_api_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  final int page;
  final int limit;

  const LoadOrders({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class RefreshOrders extends OrdersEvent {
  final int page;
  final int limit;

  const RefreshOrders({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class CancelOrder extends OrdersEvent {
  final String orderId;
  final String? notes;

  const CancelOrder({required this.orderId, this.notes});

  @override
  List<Object?> get props => [orderId, notes];
}

class FilterOrders extends OrdersEvent {
  final OrderFilter filter;

  const FilterOrders(this.filter);

  @override
  List<Object?> get props => [filter];
}

enum OrderFilter { all, inProgress, delivered }

// States
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final OrderFilter currentFilter;
  final int currentPage;
  final int limit;
  final bool hasMorePages;

  const OrdersLoaded({
    required this.orders,
    required this.currentFilter,
    this.currentPage = 1,
    this.limit = 10,
    this.hasMorePages = false,
  });

  List<OrderModel> get filteredOrders {
    switch (currentFilter) {
      case OrderFilter.all:
        return orders;
      case OrderFilter.inProgress:
        return orders
            .where(
              (order) =>
                  order.status.toLowerCase() == 'processing' ||
                  order.status.toLowerCase() == 'confirmed' ||
                  order.status.toLowerCase() == 'shipped',
            )
            .toList();
      case OrderFilter.delivered:
        return orders
            .where((order) => order.status.toLowerCase() == 'delivered')
            .toList();
    }
  }

  @override
  List<Object?> get props => [
    orders,
    currentFilter,
    currentPage,
    limit,
    hasMorePages,
  ];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<CancelOrder>(_onCancelOrder);
    on<FilterOrders>(_onFilterOrders);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    try {
      // Ensure authentication token is properly set before making API call
      await _ensureAuthTokenIsSet();

      final response = await OrdersService.getOrders(
        page: event.page,
        limit: event.limit,
      );

      // Determine if there are more pages using the total count from response
      final hasMorePages = (response.page * response.limit) < response.total;

      final newState = OrdersLoaded(
        orders: response.data,
        currentFilter: OrderFilter.all,
        currentPage: response.page,
        limit: response.limit,
        hasMorePages: hasMorePages,
      );

      emit(newState);
    } catch (e) {
      emit(OrdersError('Failed to load orders: ${e.toString()}'));
    }
  }

  Future<void> _ensureAuthTokenIsSet() async {
    // Check if token is already set in DioClient
    final currentToken = DioClient.getCurrentToken();
    if (currentToken != null && currentToken.isNotEmpty) {
      return; // Token is already set
    }

    // If not set, get it from SharedPreferences and set it
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.tokenKey);
    if (token != null && token.isNotEmpty) {
      DioClient.updateAuthToken(token);
    }
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    // If we're in initial state, don't refresh - let LoadOrders handle it
    if (state is OrdersInitial) {
      return;
    }

    // Don't show loading state for refresh, keep current state
    try {
      // Ensure authentication token is properly set before making API call
      await _ensureAuthTokenIsSet();

      final response = await OrdersService.getOrders(
        page: event.page,
        limit: event.limit,
      );

      // Determine if there are more pages using the total count from response
      final hasMorePages = (response.page * response.limit) < response.total;

      final currentFilter = state is OrdersLoaded
          ? (state as OrdersLoaded).currentFilter
          : OrderFilter.all;

      final newState = OrdersLoaded(
        orders: response.data,
        currentFilter: currentFilter,
        currentPage: response.page,
        limit: response.limit,
        hasMorePages: hasMorePages,
      );

      emit(newState);

      // If this is a refresh from order confirmation and we got no orders,
      // try again after a short delay to account for backend processing time
      if (response.data.isEmpty && event.page == 1) {
        await Future.delayed(const Duration(seconds: 2));

        try {
          final retryResponse = await OrdersService.getOrders(
            page: event.page,
            limit: event.limit,
          );

          if (retryResponse.data.isNotEmpty) {
            final retryHasMorePages =
                (retryResponse.page * retryResponse.limit) <
                retryResponse.total;
            final retryState = OrdersLoaded(
              orders: retryResponse.data,
              currentFilter: currentFilter,
              currentPage: retryResponse.page,
              limit: retryResponse.limit,
              hasMorePages: retryHasMorePages,
            );

            emit(retryState);
          }
        } catch (retryError) {
          // Don't emit error state for retry failure, keep the original empty state
        }
      }
    } catch (e) {
      if (state is OrdersLoaded) {
        emit(OrdersError('Failed to refresh orders: ${e.toString()}'));
      } else {
        emit(OrdersError('Failed to refresh orders: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final request = OrderStatusUpdateRequest(
        reason: 'other',
        notes: event.notes ?? 'Order cancelled by customer',
      );

      await OrdersService.cancelOrder(event.orderId, request);

      // Refresh orders after successful cancellation
      final response = await OrdersService.getOrders();
      emit(
        OrdersLoaded(
          orders: response.data,
          currentFilter: state is OrdersLoaded
              ? (state as OrdersLoaded).currentFilter
              : OrderFilter.all,
        ),
      );
    } catch (e) {
      emit(OrdersError('Failed to cancel order: ${e.toString()}'));
    }
  }

  void _onFilterOrders(FilterOrders event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(
        OrdersLoaded(
          orders: currentState.orders,
          currentFilter: event.filter,
          currentPage: currentState.currentPage,
          limit: currentState.limit,
          hasMorePages: currentState.hasMorePages,
        ),
      );
    }
  }
}
