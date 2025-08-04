import 'package:tailorapp/core/models/admin_model.dart';

abstract class AdminRepository {
  Future<AdminModel?> getAdmin(String id);
  Future<AdminModel> createAdmin(AdminModel admin);
  Future<AdminModel> updateAdmin(AdminModel admin);
  Future<void> deleteAdmin(String id);
  Future<List<AdminModel>> searchAdmins(String query);
  Future<AdminModel?> getAdminByEmail(String email);
  Future<void> updateAdminProfile(String adminId, AdminProfile profile);
  Future<void> updateAdminPermissions(
    String adminId,
    List<AdminPermission> permissions,
  );
  Future<void> updateAdminRole(String adminId, AdminRole role);
  Future<List<AdminModel>> getAdminsByRole(AdminRole role);
  Future<List<AdminModel>> getActiveAdmins();
  Future<List<AdminModel>> getSuperAdmins();
  Future<void> activateAdmin(String adminId);
  Future<void> deactivateAdmin(String adminId);
  Future<void> promoteToSuperAdmin(String adminId);
  Future<void> demoteFromSuperAdmin(String adminId);
  Future<String> uploadProfileImage(String adminId, dynamic imageFile);
  Future<void> logAdminActivity(
    String adminId,
    String action,
    Map<String, dynamic> details,
  );
  Future<List<AdminModel>> getRecentAdmins(int limit);
  Future<Map<String, dynamic>> getAdminStats();
  Future<List<Map<String, dynamic>>> getAdminActivityLog(
    String adminId,
    int limit,
  );
  Future<bool> hasPermission(String adminId, AdminPermission permission);
  Future<void> revokePermission(String adminId, AdminPermission permission);
  Future<void> grantPermission(String adminId, AdminPermission permission);
  Future<Map<String, dynamic>> exportAdminData(String adminId);
}

// Exception classes for admin repository operations
class AdminRepositoryException implements Exception {
  final String message;
  AdminRepositoryException(this.message);

  @override
  String toString() => 'AdminRepositoryException: $message';
}
