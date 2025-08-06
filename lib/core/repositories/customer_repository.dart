import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/shared_models.dart';
import 'package:tailorapp/core/services/supabase_database_service.dart';

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

/// Supabase implementation of CustomerRepository
///
/// Manages customer data operations including profiles, measurements,
/// style preferences, and order history using Supabase Database Service
class CustomerRepositoryImpl implements CustomerRepository {
  final SupabaseClient _supabase;
  final SupabaseDatabaseService? _databaseService;
  final String _table = 'customers';

  CustomerRepositoryImpl({
    SupabaseClient? supabase,
    SupabaseDatabaseService? databaseService,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _databaseService = databaseService;

  @override
  Future<CustomerModel?> getCustomer(String id) async {
    try {
      if (_databaseService != null) {
        final response = await _databaseService.select(
          table: _table,
          filters: {'id': id},
          limit: 1,
        );

        if (response.isEmpty) {
          return null;
        }

        return CustomerModel.fromJson(response.first);
      } else {
        final response = await _supabase.from(_table).select().eq('id', id).maybeSingle();

        if (response == null) {
          return null;
        }

        return CustomerModel.fromJson(response);
      }
    } catch (e) {
      throw CustomerRepositoryException('Failed to get customer: $e');
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final data = customer.toJson();
      data.remove('id'); // Remove ID, let Supabase generate it
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      if (_databaseService != null) {
        final response = await _databaseService.insert(
          table: _table,
          data: data,
        );

        return CustomerModel.fromJson(response);
      } else {
        final response = await _supabase.from(_table).insert(data).select().single();

        return CustomerModel.fromJson(response);
      }
    } catch (e) {
      throw CustomerRepositoryException('Failed to create customer: $e');
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final data = customer.toJson();
      data.remove('id'); // Remove ID from update data
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).update(data).eq('id', customer.id).select().single();

      return CustomerModel.fromJson(response);
    } catch (e) {
      throw CustomerRepositoryException('Failed to update customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw CustomerRepositoryException('Failed to delete customer: $e');
    }
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final response = await _supabase.from(_table).select().ilike('name', '%$query%').limit(20);

      return response.map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e) {
      throw CustomerRepositoryException('Failed to search customers: $e');
    }
  }

  @override
  Future<CustomerModel?> getCustomerByEmail(String email) async {
    try {
      final response = await _supabase.from(_table).select().eq('email', email).maybeSingle();

      if (response == null) {
        return null;
      }

      return CustomerModel.fromJson(response);
    } catch (e) {
      throw CustomerRepositoryException('Failed to get customer by email: $e');
    }
  }

  @override
  Future<void> updateMeasurements(
    String customerId,
    BodyMeasurements measurements,
  ) async {
    try {
      await _supabase.from(_table).update({
        'measurements': measurements.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', customerId);
    } catch (e) {
      throw CustomerRepositoryException('Failed to update measurements: $e');
    }
  }

  @override
  Future<void> updateStylePreferences(
    String customerId,
    StylePreferences preferences,
  ) async {
    try {
      await _supabase.from(_table).update({
        'style_preferences': preferences.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', customerId);
    } catch (e) {
      throw CustomerRepositoryException(
        'Failed to update style preferences: $e',
      );
    }
  }

  @override
  Future<List<CustomerModel>> getRecentCustomers(int limit) async {
    try {
      final response = await _supabase.from(_table).select().order('created_at', ascending: false).limit(limit);

      return response.map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e) {
      throw CustomerRepositoryException('Failed to get recent customers: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(
    String customerId,
    dynamic imageFile,
  ) async {
    try {
      // Upload to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profiles/$customerId/$timestamp.jpg';

      // Upload file to storage bucket
      await _supabase.storage.from('avatars').uploadBinary(fileName, imageFile);

      // Get public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // Update customer document with new image URL
      await _supabase.from(_table).update({
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', customerId);

      return imageUrl;
    } catch (e) {
      throw CustomerRepositoryException('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> sendEmailVerification(String email) async {
    try {
      // Supabase handles email verification through auth
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw CustomerRepositoryException(
        'Failed to send email verification: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> exportCustomerData(String customerId) async {
    try {
      final customer = await getCustomer(customerId);

      if (customer == null) {
        throw CustomerRepositoryException(
          'Customer not found for export',
        );
      }

      // Create export data with privacy considerations
      final exportData = {
        'personal_info': {
          'name': customer.name,
          'email': customer.email,
          'phone': customer.phone,
          'date_of_birth': customer.dateOfBirth?.toIso8601String(),
          'gender': customer.gender,
        },
        'measurements': customer.measurements?.toJson(),
        'style_preferences': customer.stylePreferences.toJson(),
        'address': customer.address?.toJson(),
        'account_info': {
          'created_at': customer.createdAt.toIso8601String(),
          'updated_at': customer.updatedAt.toIso8601String(),
          'is_verified': customer.isVerified,
        },
        'exported_at': DateTime.now().toIso8601String(),
      };

      return exportData;
    } catch (e) {
      throw CustomerRepositoryException('Failed to export customer data: $e');
    }
  }
}

// Exception classes for customer repository operations
class CustomerRepositoryException implements Exception {
  final String message;
  CustomerRepositoryException(this.message);

  @override
  String toString() => 'CustomerRepositoryException: $message';
}
