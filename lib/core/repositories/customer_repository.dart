import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/shared_models.dart';

abstract class CustomerRepository {
  Future<CustomerModel?> getCustomer(String id);
  Future<CustomerModel> createCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<List<CustomerModel>> searchCustomers(String query);
  Future<CustomerModel?> getCustomerByEmail(String email);
  Future<void> updateMeasurements(
    String customerId,
    BodyMeasurements measurements,
  );
  Future<void> updateStylePreferences(
    String customerId,
    StylePreferences preferences,
  );
  Future<List<CustomerModel>> getRecentCustomers(int limit);
  Future<String> uploadProfileImage(String customerId, dynamic imageFile);
  Future<void> sendEmailVerification(String email);
  Future<Map<String, dynamic>> exportCustomerData(String customerId);
}

// Exception classes for customer repository operations
class CustomerRepositoryException implements Exception {
  final String message;
  CustomerRepositoryException(this.message);

  @override
  String toString() => 'CustomerRepositoryException: $message';
}
