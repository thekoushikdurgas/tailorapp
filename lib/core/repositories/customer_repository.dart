import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailorapp/core/models/customer_model.dart';

abstract class CustomerRepository {
  Future<CustomerModel?> getCustomer(String id);
  Future<CustomerModel> createCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<List<CustomerModel>> searchCustomers(String query);
  Future<CustomerModel?> getCustomerByEmail(String email);
  Future<void> updateMeasurements(
      String customerId, BodyMeasurements measurements);
  Future<void> updateStylePreferences(
      String customerId, StylePreferences preferences);
  Future<List<CustomerModel>> getRecentCustomers(int limit);
}

class FirebaseCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'customers';

  FirebaseCustomerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CustomerModel?> getCustomer(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id; // Ensure ID is set

      return CustomerModel.fromJson(data);
    } catch (e) {
      throw CustomerRepositoryException('Failed to get customer: $e');
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final data = customer.toJson();
      data.remove('id'); // Remove ID as Firestore will generate it

      final docRef = await _firestore.collection(_collection).add(data);

      // Return customer with generated ID
      return customer.copyWith(id: docRef.id);
    } catch (e) {
      throw CustomerRepositoryException('Failed to create customer: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final data = customer.toJson();
      data.remove('id'); // Remove ID from data
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(customer.id).update(data);

      return customer.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw CustomerRepositoryException('Failed to update customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw CustomerRepositoryException('Failed to delete customer: $e');
    }
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CustomerModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw CustomerRepositoryException('Failed to search customers: $e');
    }
  }

  @override
  Future<CustomerModel?> getCustomerByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      return CustomerModel.fromJson(data);
    } catch (e) {
      throw CustomerRepositoryException('Failed to get customer by email: $e');
    }
  }

  @override
  Future<void> updateMeasurements(
      String customerId, BodyMeasurements measurements) async {
    try {
      await _firestore.collection(_collection).doc(customerId).update({
        'measurements': measurements.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw CustomerRepositoryException('Failed to update measurements: $e');
    }
  }

  @override
  Future<void> updateStylePreferences(
      String customerId, StylePreferences preferences) async {
    try {
      await _firestore.collection(_collection).doc(customerId).update({
        'stylePreferences': preferences.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw CustomerRepositoryException(
          'Failed to update style preferences: $e');
    }
  }

  @override
  Future<List<CustomerModel>> getRecentCustomers(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CustomerModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw CustomerRepositoryException('Failed to get recent customers: $e');
    }
  }
}

class CustomerRepositoryException implements Exception {
  final String message;

  const CustomerRepositoryException(this.message);

  @override
  String toString() => 'CustomerRepositoryException: $message';
}
