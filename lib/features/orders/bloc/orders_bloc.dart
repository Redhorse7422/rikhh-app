import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/order_model.dart';
import '../services/orders_api_service.dart';

// Events
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {}

class FilterOrders extends OrdersEvent {
  final OrderFilter filter;

  const FilterOrders(this.filter);

  @override
  List<Object?> get props => [filter];
}

enum OrderFilter {
  all,
  inProgress,
  delivered,
}

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

  const OrdersLoaded({
    required this.orders,
    required this.currentFilter,
  });

  List<OrderModel> get filteredOrders {
    switch (currentFilter) {
      case OrderFilter.all:
        return orders;
      case OrderFilter.inProgress:
        return orders.where((order) => 
          order.status.toLowerCase() == 'processing' ||
          order.status.toLowerCase() == 'confirmed' ||
          order.status.toLowerCase() == 'shipped'
        ).toList();
      case OrderFilter.delivered:
        return orders.where((order) => 
          order.status.toLowerCase() == 'delivered'
        ).toList();
    }
  }

  @override
  List<Object?> get props => [orders, currentFilter];
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
    on<FilterOrders>(_onFilterOrders);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    
    try {
      final response = await OrdersService.getOrders();
      emit(OrdersLoaded(
        orders: response.data,
        currentFilter: OrderFilter.all,
      ));
    } catch (e) {
      emit(OrdersError('Failed to load orders: ${e.toString()}'));
    }
  }

  void _onFilterOrders(FilterOrders event, Emitter<OrdersState> emit) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrdersLoaded(
        orders: currentState.orders,
        currentFilter: event.filter,
      ));
    }
  }
}
