import 'package:cloud_firestore/cloud_firestore.dart';
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

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'users';

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUser(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id; // Ensure ID is set

      return UserModel.fromJson(data);
    } catch (e) {
      throw UserRepositoryException('Failed to get user: $e');
    }
  }

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      return UserModel.fromJson(data);
    } catch (e) {
      throw UserRepositoryException('Failed to get user by phone: $e');
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
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

      return UserModel.fromJson(data);
    } catch (e) {
      throw UserRepositoryException('Failed to get user by email: $e');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final data = user.toJson();
      data.remove('id'); // Remove ID as Firestore will generate it

      final docRef = await _firestore.collection(_collection).add(data);

      // Return user with generated ID
      return user.copyWith(id: docRef.id);
    } catch (e) {
      throw UserRepositoryException('Failed to create user: $e');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final data = user.toJson();
      data.remove('id'); // Remove ID from data
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(user.id).update(data);

      return user.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw UserRepositoryException('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw UserRepositoryException('Failed to delete user: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
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
        return UserModel.fromJson(data);
      }).toList();
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
      await _firestore.collection(_collection).doc(userId).update({
        'customerData.measurements': measurements.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
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
      await _firestore.collection(_collection).doc(userId).update({
        'customerData.stylePreferences': preferences.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw UserRepositoryException(
        'Failed to update style preferences: $e',
      );
    }
  }

  @override
  Future<List<UserModel>> getRecentUsers(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
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
      // In a real implementation, this would upload to Firebase Storage
      // For now, we'll simulate the upload and return a mock URL
      await Future.delayed(const Duration(seconds: 1));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageUrl =
          'https://mock-storage.com/profiles/$userId/$timestamp.jpg';

      // Update user document with new image URL
      await _firestore.collection(_collection).doc(userId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return imageUrl;
    } catch (e) {
      throw UserRepositoryException('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> sendEmailVerification(String email) async {
    try {
      // In a real implementation, this would trigger an email verification service
      // For now, we'll simulate the process
      await Future.delayed(const Duration(milliseconds: 500));

      // In production, this would integrate with Firebase Auth or email service
      // to send verification email to the user
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
        throw const UserRepositoryException(
          'User not found for export',
        );
      }

      // Create export data with privacy considerations
      final exportData = {
        'personalInfo': {
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'dateOfBirth': user.dateOfBirth?.toIso8601String(),
          'gender': user.gender,
          'role': user.role.name,
        },
        'measurements': user.customerData?.measurements?.toJson(),
        'stylePreferences': user.customerData?.stylePreferences.toJson(),
        'address': user.address?.toJson(),
        'tailorData': user.tailorData?.toJson(),
        'adminData': user.adminData?.toJson(),
        'accountInfo': {
          'createdAt': user.createdAt.toIso8601String(),
          'updatedAt': user.updatedAt.toIso8601String(),
          'isVerified': user.isVerified,
          'isActive': user.isActive,
        },
        'exportedAt': DateTime.now().toIso8601String(),
      };

      return exportData;
    } catch (e) {
      throw UserRepositoryException('Failed to export user data: $e');
    }
  }
}

class UserRepositoryException implements Exception {
  final String message;

  const UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException: $message';
}
