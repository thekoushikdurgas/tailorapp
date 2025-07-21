import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/models/order_model.dart';
// import 'package:tailorapp/core/models/garment_model.dart';

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  final String selectedFilter;
  final String searchQuery;

  const OrdersLoaded({
    required this.orders,
    required this.filteredOrders,
    this.selectedFilter = 'all',
    this.searchQuery = '',
  });

  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
    String? selectedFilter,
    String? searchQuery,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [orders, filteredOrders, selectedFilter, searchQuery];
}

class OrderDetailsLoaded extends OrderState {
  final OrderModel order;

  const OrderDetailsLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderCreated extends OrderState {
  final OrderModel order;
  final String message;

  const OrderCreated({
    required this.order,
    required this.message,
  });

  @override
  List<Object?> get props => [order, message];
}

class OrderUpdated extends OrderState {
  final OrderModel order;
  final String message;

  const OrderUpdated({
    required this.order,
    required this.message,
  });

  @override
  List<Object?> get props => [order, message];
}

class PaymentProcessing extends OrderState {
  final String orderId;

  const PaymentProcessing({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class PaymentSuccess extends OrderState {
  final String orderId;
  final String paymentId;
  final String message;

  const PaymentSuccess({
    required this.orderId,
    required this.paymentId,
    required this.message,
  });

  @override
  List<Object?> get props => [orderId, paymentId, message];
}

class PaymentFailure extends OrderState {
  final String orderId;
  final String error;

  const PaymentFailure({
    required this.orderId,
    required this.error,
  });

  @override
  List<Object?> get props => [orderId, error];
}

// Cubit
class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(const OrderInitial());

  Future<void> loadOrders(String customerId) async {
    emit(const OrderLoading());

    try {
      final orders =
          await ServiceLocator.orderRepository.getCustomerOrders(customerId);

      emit(OrdersLoaded(
        orders: orders,
        filteredOrders: orders,
      ));
    } catch (e) {
      emit(OrderError(message: 'Failed to load orders: ${e.toString()}'));
    }
  }

  void filterOrders(String filter) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final filteredOrders = _applyFilters(
        currentState.orders,
        filter,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        selectedFilter: filter,
        filteredOrders: filteredOrders,
      ));
    }
  }

  void searchOrders(String query) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;

      if (query.isEmpty) {
        final filteredOrders = _applyFilters(
          currentState.orders,
          currentState.selectedFilter,
          '',
        );

        emit(currentState.copyWith(
          searchQuery: '',
          filteredOrders: filteredOrders,
        ));
        return;
      }

      try {
        // Perform search through repository
        final searchResults =
            await ServiceLocator.orderRepository.searchOrders(query);

        final filteredOrders = _applyFilters(
          searchResults,
          currentState.selectedFilter,
          query,
        );

        emit(currentState.copyWith(
          orders: searchResults,
          searchQuery: query,
          filteredOrders: filteredOrders,
        ));
      } catch (e) {
        emit(OrderError(message: 'Search failed: ${e.toString()}'));
      }
    }
  }

  List<OrderModel> _applyFilters(
      List<OrderModel> orders, String filter, String searchQuery) {
    var filteredOrders = orders.where((order) {
      // Apply status filter
      bool statusMatch = filter == 'all' || order.status.value == filter;

      // Apply search filter
      bool searchMatch = searchQuery.isEmpty ||
          order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.items.any((item) => item.garmentName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()));

      return statusMatch && searchMatch;
    }).toList();

    // Sort by creation date (newest first)
    filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return filteredOrders;
  }

  Future<void> loadOrderDetails(String orderId) async {
    emit(const OrderLoading());

    try {
      final order = await ServiceLocator.orderRepository.getOrder(orderId);
      if (order == null) {
        emit(const OrderError(message: 'Order not found'));
        return;
      }
      emit(OrderDetailsLoaded(order: order));
    } catch (e) {
      emit(
          OrderError(message: 'Failed to load order details: ${e.toString()}'));
    }
  }

  Future<void> createOrder(OrderModel order) async {
    emit(const OrderLoading());

    try {
      final createdOrder =
          await ServiceLocator.orderRepository.createOrder(order);
      emit(OrderCreated(
        order: createdOrder,
        message: 'Order created successfully',
      ));
    } catch (e) {
      emit(OrderError(message: 'Failed to create order: ${e.toString()}'));
    }
  }

  Future<void> updateOrderStatus(
      String orderId, OrderStatus status, String? message) async {
    try {
      await ServiceLocator.orderRepository
          .updateOrderStatus(orderId, status, message);

      // Reload order if currently viewing details
      if (state is OrderDetailsLoaded) {
        await loadOrderDetails(orderId);
      }

      // Update the order in the list if currently loaded
      if (state is OrdersLoaded) {
        final currentState = state as OrdersLoaded;
        final updatedOrders = currentState.orders.map((order) {
          if (order.id == orderId) {
            return order.copyWith(status: status);
          }
          return order;
        }).toList();

        final filteredOrders = _applyFilters(
          updatedOrders,
          currentState.selectedFilter,
          currentState.searchQuery,
        );

        emit(currentState.copyWith(
          orders: updatedOrders,
          filteredOrders: filteredOrders,
        ));
      }
    } catch (e) {
      emit(OrderError(
          message: 'Failed to update order status: ${e.toString()}'));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(
          orderId, OrderStatus.cancelled, 'Order cancelled by customer');
      emit(OrderUpdated(
        order: OrderModel(
          id: '',
          customerId: '',
          customerName: '',
          customerEmail: '',
          items: [],
          totalAmount: 0,
          taxAmount: 0,
          shippingAmount: 0,
          discountAmount: 0,
          finalAmount: 0,
          status: OrderStatus.cancelled,
          paymentStatus: PaymentStatus.pending,
          orderDate: DateTime.now(),
          progressImages: [],
          statusHistory: [],
        ),
        message: 'Order cancelled successfully',
      ));
    } catch (e) {
      emit(OrderError(message: 'Failed to cancel order: ${e.toString()}'));
    }
  }

  Future<void> processPayment(
      String orderId, Map<String, dynamic> paymentData) async {
    emit(PaymentProcessing(orderId: orderId));

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      final paymentId = 'PAY_${DateTime.now().millisecondsSinceEpoch}';

      // Update order payment status
      await ServiceLocator.orderRepository.updatePaymentStatus(
        orderId,
        PaymentStatus.paid,
        paymentId,
      );

      emit(PaymentSuccess(
        orderId: orderId,
        paymentId: paymentId,
        message: 'Payment processed successfully',
      ));
    } catch (e) {
      emit(PaymentFailure(
        orderId: orderId,
        error: 'Payment failed: ${e.toString()}',
      ));
    }
  }

  Future<void> requestRefund(
      String orderId, double amount, String reason) async {
    emit(const OrderLoading());

    try {
      await ServiceLocator.orderRepository
          .requestRefund(orderId, amount, reason);

      // Update payment status to refunded
      await ServiceLocator.orderRepository.updatePaymentStatus(
        orderId,
        PaymentStatus.refunded,
        null,
      );

      emit(OrderUpdated(
        order: OrderModel(
          id: '',
          customerId: '',
          customerName: '',
          customerEmail: '',
          items: [],
          totalAmount: 0,
          taxAmount: 0,
          shippingAmount: 0,
          discountAmount: 0,
          finalAmount: 0,
          status: OrderStatus.refunded,
          paymentStatus: PaymentStatus.refunded,
          orderDate: DateTime.now(),
          progressImages: [],
          statusHistory: [],
        ),
        message: 'Refund requested successfully',
      ));
    } catch (e) {
      emit(OrderError(message: 'Failed to request refund: ${e.toString()}'));
    }
  }

  Future<void> trackOrder(String orderId) async {
    try {
      final order = await ServiceLocator.orderRepository.getOrder(orderId);
      if (order != null) {
        emit(OrderDetailsLoaded(order: order));
      } else {
        emit(const OrderError(message: 'Order not found'));
      }
    } catch (e) {
      emit(OrderError(message: 'Failed to track order: ${e.toString()}'));
    }
  }

  Future<void> reorderFromPrevious(String originalOrderId) async {
    emit(const OrderLoading());

    try {
      final originalOrder =
          await ServiceLocator.orderRepository.getOrder(originalOrderId);
      if (originalOrder == null) {
        emit(const OrderError(message: 'Original order not found'));
        return;
      }

      // Create new order based on original
      final newOrder = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: originalOrder.customerId,
        customerName: originalOrder.customerName,
        customerEmail: originalOrder.customerEmail,
        customerPhone: originalOrder.customerPhone,
        items: originalOrder.items
            .map((item) => OrderItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  garmentId: item.garmentId,
                  garmentName: item.garmentName,
                  garmentType: item.garmentType,
                  quantity: item.quantity,
                  unitPrice: item.unitPrice,
                  totalPrice: item.totalPrice,
                  measurements: item.measurements,
                  customizations: item.customizations,
                  imageUrl: item.imageUrl,
                ))
            .toList(),
        totalAmount: originalOrder.totalAmount,
        taxAmount: originalOrder.taxAmount,
        shippingAmount: originalOrder.shippingAmount,
        discountAmount: 0.0, // Reset discount
        finalAmount: originalOrder.totalAmount +
            originalOrder.taxAmount +
            originalOrder.shippingAmount,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        orderDate: DateTime.now(),
        estimatedCompletionDate: DateTime.now().add(const Duration(days: 14)),
        shippingAddress: originalOrder.shippingAddress,
        progressImages: [],
        statusHistory: [
          OrderStatusUpdate(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: OrderStatus.pending,
            timestamp: DateTime.now(),
            message: 'Reorder created from order #${originalOrder.id}',
          ),
        ],
      );

      await createOrder(newOrder);
    } catch (e) {
      emit(OrderError(message: 'Failed to reorder: ${e.toString()}'));
    }
  }

  void clearError() {
    if (state is OrderError) {
      emit(const OrderInitial());
    }
  }

  Future<void> refreshOrders(String customerId) async {
    // Refresh without showing loading state
    try {
      final orders =
          await ServiceLocator.orderRepository.getCustomerOrders(customerId);

      if (state is OrdersLoaded) {
        final currentState = state as OrdersLoaded;
        final filteredOrders = _applyFilters(
          orders,
          currentState.selectedFilter,
          currentState.searchQuery,
        );

        emit(currentState.copyWith(
          orders: orders,
          filteredOrders: filteredOrders,
        ));
      } else {
        emit(OrdersLoaded(
          orders: orders,
          filteredOrders: orders,
        ));
      }
    } catch (e) {
      emit(OrderError(message: 'Failed to refresh orders: ${e.toString()}'));
    }
  }
}
