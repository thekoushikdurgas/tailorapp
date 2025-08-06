import 'package:supabase_flutter/supabase_flutter.dart';
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

/// Supabase implementation of OrderRepository
///
/// Manages order lifecycle including creation, updates, status tracking,
/// payments, and real-time order updates using Supabase PostgreSQL
class OrderRepositoryImpl implements OrderRepository {
  final SupabaseClient _supabase;
  final String _table = 'orders';

  OrderRepositoryImpl({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<OrderModel?> getOrder(String id) async {
    try {
      final response = await _supabase.from(_table).select().eq('id', id).maybeSingle();

      if (response == null) {
        return null;
      }

      return OrderModel.fromJson(response);
    } catch (e) {
      throw OrderRepositoryException('Failed to get order: $e');
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final data = order.toJson();
      data.remove('id'); // Remove ID, let Supabase generate it
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).insert(data).select().single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw OrderRepositoryException('Failed to create order: $e');
    }
  }

  @override
  Future<OrderModel> updateOrder(OrderModel order) async {
    try {
      final data = order.toJson();
      data.remove('id'); // Remove ID from update data
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).update(data).eq('id', order.id).select().single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw OrderRepositoryException('Failed to update order: $e');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw OrderRepositoryException('Failed to delete order: $e');
    }
  }

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('customer_id', customerId).order('created_at', ascending: false);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get customer orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase.from(_table).select().eq('status', status).order('created_at', ascending: false);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get orders by status: $e');
    }
  }

  @override
  Future<List<OrderModel>> getRecentOrders(int limit) async {
    try {
      final response = await _supabase.from(_table).select().order('created_at', ascending: false).limit(limit);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get recent orders: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from(_table).update(updateData).eq('id', orderId);
    } catch (e) {
      throw OrderRepositoryException('Failed to update order status: $e');
    }
  }

  @override
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .or('order_number.ilike.%$query%,customer_name.ilike.%$query%')
          .limit(20);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to search orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .order('created_at', ascending: false);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get orders in date range: $e');
    }
  }

  @override
  Stream<OrderModel> watchOrder(String id) {
    return _supabase.from(_table).stream(primaryKey: ['id']).eq('id', id).map((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            return OrderModel.fromJson(data.first);
          }
          throw const OrderRepositoryException('Order not found');
        });
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerId) {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('created_at', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data.map((json) => OrderModel.fromJson(json)).toList();
        });
  }

  @override
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _supabase.from(_table).update({
        'payment_status': paymentStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw OrderRepositoryException('Failed to update payment status: $e');
    }
  }

  @override
  Future<void> requestRefund(String orderId) async {
    try {
      await _supabase.from(_table).update({
        'payment_status': 'refund_requested',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw OrderRepositoryException('Failed to request refund: $e');
    }
  }

  @override
  Future<void> assignOrderToTailor(String orderId, String tailorId) async {
    try {
      await _supabase.from(_table).update({
        'tailor_id': tailorId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw OrderRepositoryException('Failed to assign order to tailor: $e');
    }
  }

  @override
  Future<void> addOrderNote(String orderId, String note) async {
    try {
      // First get current notes
      final response = await _supabase.from(_table).select('notes').eq('id', orderId).single();

      final currentNotes = List<String>.from(response['notes'] ?? []);
      currentNotes.add(note);

      await _supabase.from(_table).update({
        'notes': currentNotes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw OrderRepositoryException('Failed to add order note: $e');
    }
  }

  @override
  Future<void> updateOrderPriority(String orderId, String priority) async {
    try {
      await _supabase.from(_table).update({
        'priority': priority,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw OrderRepositoryException('Failed to update order priority: $e');
    }
  }

  @override
  Future<void> updateOrderDeadline(String orderId, DateTime deadline) async {
    try {
      await _supabase.from(_table).update({
        'deadline': deadline.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw OrderRepositoryException('Failed to update order deadline: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderStats() async {
    try {
      // Get total orders
      final totalOrders = await _supabase.from(_table).select('*').count(CountOption.exact);

      // Get orders by status
      final pendingOrders = await _supabase.from(_table).select('*').eq('status', 'pending').count(CountOption.exact);

      final completedOrders =
          await _supabase.from(_table).select('*').eq('status', 'delivered').count(CountOption.exact);

      return {
        'total_orders': totalOrders.count,
        'pending_orders': pendingOrders.count,
        'completed_orders': completedOrders.count,
        'in_progress_orders': totalOrders.count - pendingOrders.count - completedOrders.count,
      };
    } catch (e) {
      throw OrderRepositoryException('Failed to get order stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportOrderData(String orderId) async {
    try {
      final order = await getOrder(orderId);
      if (order == null) {
        throw const OrderRepositoryException('Order not found');
      }

      return {
        'order_info': order.toJson(),
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw OrderRepositoryException('Failed to export order data: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('customer_id', customerId).order('created_at', ascending: false);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get orders by customer: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByTailor(String tailorId) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('tailor_id', tailorId).order('created_at', ascending: false);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get orders by tailor: $e');
    }
  }
}

// Exception classes for order repository operations
class OrderRepositoryException implements Exception {
  final String message;

  const OrderRepositoryException(this.message);

  @override
  String toString() => 'OrderRepositoryException: $message';
}
