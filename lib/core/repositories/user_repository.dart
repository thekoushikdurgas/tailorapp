import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/shared_models.dart';

abstract class UserRepository {
  Future<UserModel?> getUser(String id);
  Future<UserModel?> getUserByPhone(String phone);
  Future<UserModel?> getUserByEmail(String email);
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String id);
  Future<List<UserModel>> searchUsers(String query);
  Future<void> updateMeasurements(
    String userId,
    BodyMeasurements measurements,
  );
  Future<void> updateStylePreferences(
    String userId,
    StylePreferences preferences,
  );
  Future<List<UserModel>> getRecentUsers(int limit);
  Future<String> uploadProfileImage(String userId, dynamic imageFile);
  Future<void> sendEmailVerification(String email);
  Future<Map<String, dynamic>> exportUserData(String userId);
}

/// Supabase implementation of UserRepository
///
/// Handles all user-related database operations using Supabase PostgreSQL
/// Includes CRUD operations, search functionality, and role management
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;
  final String _table = 'users';

  UserRepositoryImpl({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<UserModel?> getUser(String id) async {
    try {
      final response = await _supabase.from(_table).select().eq('id', id).maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      throw UserRepositoryException('Failed to get user: $e');
    }
  }

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final response = await _supabase.from(_table).select().eq('phone', phone).maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      throw UserRepositoryException('Failed to get user by phone: $e');
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _supabase.from(_table).select().eq('email', email).maybeSingle();

      if (response == null) {
        return null;
      }

      return UserModel.fromJson(response);
    } catch (e) {
      throw UserRepositoryException('Failed to get user by email: $e');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final data = user.toJson();
      data.remove('id'); // Remove ID, let Supabase generate it
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).insert(data).select().single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw UserRepositoryException('Failed to create user: $e');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final data = user.toJson();
      data.remove('id'); // Remove ID from update data
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).update(data).eq('id', user.id).select().single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw UserRepositoryException('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw UserRepositoryException('Failed to delete user: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _supabase.from(_table).select().ilike('name', '%$query%').limit(20);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw UserRepositoryException('Failed to search users: $e');
    }
  }

  @override
  Future<void> updateMeasurements(
    String userId,
    BodyMeasurements measurements,
  ) async {
    try {
      await _supabase.from(_table).update({
        'customer_data': {
          'measurements': measurements.toJson(),
        },
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw UserRepositoryException('Failed to update measurements: $e');
    }
  }

  @override
  Future<void> updateStylePreferences(
    String userId,
    StylePreferences preferences,
  ) async {
    try {
      await _supabase.from(_table).update({
        'customer_data': {
          'style_preferences': preferences.toJson(),
        },
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw UserRepositoryException(
        'Failed to update style preferences: $e',
      );
    }
  }

  @override
  Future<List<UserModel>> getRecentUsers(int limit) async {
    try {
      final response = await _supabase.from(_table).select().order('created_at', ascending: false).limit(limit);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw UserRepositoryException('Failed to get recent users: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(
    String userId,
    dynamic imageFile,
  ) async {
    try {
      // Upload to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profiles/$userId/$timestamp.jpg';

      // Upload file to storage bucket
      await _supabase.storage.from('avatars').uploadBinary(fileName, imageFile);

      // Get public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // Update user document with new image URL
      await _supabase.from(_table).update({
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return imageUrl;
    } catch (e) {
      throw UserRepositoryException('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> sendEmailVerification(String email) async {
    try {
      // Supabase handles email verification differently
      // This would typically be handled by Supabase Auth automatically
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw UserRepositoryException(
        'Failed to send email verification: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final user = await getUser(userId);

      if (user == null) {
        throw UserRepositoryException(
          'User not found for export',
        );
      }

      // Create export data with privacy considerations
      final exportData = {
        'personal_info': {
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'date_of_birth': user.dateOfBirth?.toIso8601String(),
          'gender': user.gender,
          'role': user.role.name,
        },
        'measurements': user.customerData?.measurements?.toJson(),
        'style_preferences': user.customerData?.stylePreferences.toJson(),
        'address': user.address?.toJson(),
        'tailor_data': user.tailorData?.toJson(),
        'admin_data': user.adminData?.toJson(),
        'account_info': {
          'created_at': user.createdAt.toIso8601String(),
          'updated_at': user.updatedAt.toIso8601String(),
          'is_verified': user.isVerified,
          'is_active': user.isActive,
        },
        'exported_at': DateTime.now().toIso8601String(),
      };

      return exportData;
    } catch (e) {
      throw UserRepositoryException('Failed to export user data: $e');
    }
  }
}

// Exception classes for user repository operations
class UserRepositoryException implements Exception {
  final String message;
  UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException: $message';
}
