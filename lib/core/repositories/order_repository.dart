import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailorapp/core/models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel?> getOrder(String id);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrder(OrderModel order);
  Future<void> deleteOrder(String id);
  Future<List<OrderModel>> getCustomerOrders(String customerId);
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status);
  Future<List<OrderModel>> getRecentOrders(int limit);
  Future<void> updateOrderStatus(
      String orderId, OrderStatus status, String? message);
  Future<List<OrderModel>> searchOrders(String query);
  Future<List<OrderModel>> getOrdersInDateRange(DateTime start, DateTime end);
  Future<void> updatePaymentStatus(
      String orderId, PaymentStatus status, String? paymentId);
  Future<void> requestRefund(String orderId, double amount, String reason);
  Stream<OrderModel> watchOrder(String id);
  Stream<List<OrderModel>> watchCustomerOrders(String customerId);
}

class FirebaseOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'orders';

  FirebaseOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<OrderModel?> getOrder(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return OrderModel.fromJson(data);
    } catch (e) {
      throw OrderRepositoryException('Failed to get order: $e');
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final data = order.toJson();
      data.remove('id'); // Remove ID as Firestore will generate it

      final docRef = await _firestore.collection(_collection).add(data);

      return order.copyWith(id: docRef.id);
    } catch (e) {
      throw OrderRepositoryException('Failed to create order: $e');
    }
  }

  @override
  Future<OrderModel> updateOrder(OrderModel order) async {
    try {
      final data = order.toJson();
      data.remove('id');

      await _firestore.collection(_collection).doc(order.id).update(data);

      return order;
    } catch (e) {
      throw OrderRepositoryException('Failed to update order: $e');
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw OrderRepositoryException('Failed to delete order: $e');
    }
  }

  @override
  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: customerId)
          .orderBy('orderDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get customer orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.value)
          .orderBy('orderDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get orders by status: $e');
    }
  }

  @override
  Future<List<OrderModel>> getRecentOrders(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('orderDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get recent orders: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
      String orderId, OrderStatus status, String? message) async {
    try {
      final statusUpdate = OrderStatusUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: status,
        message: message,
        timestamp: DateTime.now(),
        updatedBy: 'system', // In real app, this would be the current user
      );

      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.value,
        'statusHistory': FieldValue.arrayUnion([statusUpdate.toJson()]),
      });
    } catch (e) {
      throw OrderRepositoryException('Failed to update order status: $e');
    }
  }

  @override
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      // Search by order ID
      final idQuery = await _firestore
          .collection(_collection)
          .where('id', isGreaterThanOrEqualTo: query)
          .where('id', isLessThan: '$query\uf8ff')
          .limit(10)
          .get();

      // Search by customer name
      final nameQuery = await _firestore
          .collection(_collection)
          .where('customerName', isGreaterThanOrEqualTo: query)
          .where('customerName', isLessThan: '$query\uf8ff')
          .limit(10)
          .get();

      final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      allDocs.addAll(idQuery.docs);
      allDocs.addAll(nameQuery.docs);

      // Remove duplicates
      final uniqueDocs = allDocs
          .fold<Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>>(
        {},
        (map, doc) {
          map[doc.id] = doc;
          return map;
        },
      );

      return uniqueDocs.values.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to search orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersInDateRange(
      DateTime start, DateTime end) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('orderDate', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('orderDate', isLessThanOrEqualTo: end.toIso8601String())
          .orderBy('orderDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw OrderRepositoryException('Failed to get orders in date range: $e');
    }
  }

  @override
  Stream<OrderModel> watchOrder(String id) {
    try {
      return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
        if (!doc.exists) {
          throw OrderRepositoryException('Order not found: $id');
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      });
    } catch (e) {
      throw OrderRepositoryException('Failed to watch order: $e');
    }
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerId) {
    try {
      return _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: customerId)
          .orderBy('orderDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return OrderModel.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw OrderRepositoryException('Failed to watch customer orders: $e');
    }
  }

  @override
  Future<void> updatePaymentStatus(
      String orderId, PaymentStatus status, String? paymentId) async {
    try {
      final updateData = <String, dynamic>{
        'paymentStatus': status.value,
      };

      if (paymentId != null) {
        updateData['paymentId'] = paymentId;
      }

      await _firestore.collection(_collection).doc(orderId).update(updateData);
    } catch (e) {
      throw OrderRepositoryException('Failed to update payment status: $e');
    }
  }

  @override
  Future<void> requestRefund(
      String orderId, double amount, String reason) async {
    try {
      final refundData = {
        'refund': {
          'amount': amount,
          'reason': reason,
          'requestedAt': DateTime.now().toIso8601String(),
          'status': 'requested',
        }
      };

      await _firestore.collection(_collection).doc(orderId).update(refundData);
    } catch (e) {
      throw OrderRepositoryException('Failed to request refund: $e');
    }
  }
}

class OrderRepositoryException implements Exception {
  final String message;

  const OrderRepositoryException(this.message);

  @override
  String toString() => 'OrderRepositoryException: $message';
}
