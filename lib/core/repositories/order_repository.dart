import 'package:tailorapp/core/models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel?> getOrder(String id);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrder(OrderModel order);
  Future<void> deleteOrder(String id);
  Future<List<OrderModel>> searchOrders(String query);
  Future<List<OrderModel>> getOrdersByCustomer(String customerId);
  Future<List<OrderModel>> getCustomerOrders(String customerId);
  Future<List<OrderModel>> getOrdersByTailor(String tailorId);
  Future<List<OrderModel>> getOrdersByStatus(String status);
  Future<List<OrderModel>> getRecentOrders(int limit);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> assignOrderToTailor(String orderId, String tailorId);
  Future<void> addOrderNote(String orderId, String note);
  Future<void> updateOrderPriority(String orderId, String priority);
  Future<void> updateOrderDeadline(String orderId, DateTime deadline);
  Future<void> updatePaymentStatus(String orderId, String paymentStatus);
  Future<void> requestRefund(String orderId);
  Future<Map<String, dynamic>> getOrderStats();
  Future<List<OrderModel>> getOrdersInDateRange(DateTime start, DateTime end);
  Future<Map<String, dynamic>> exportOrderData(String orderId);
  Stream<OrderModel> watchOrder(String id);
  Stream<List<OrderModel>> watchCustomerOrders(String customerId);
}

// Exception classes for order repository operations
class OrderRepositoryException implements Exception {
  final String message;
  OrderRepositoryException(this.message);

  @override
  String toString() => 'OrderRepositoryException: $message';
}
