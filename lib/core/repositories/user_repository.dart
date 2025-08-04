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

// Exception classes for user repository operations
class UserRepositoryException implements Exception {
  final String message;
  UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException: $message';
}
