import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailorapp/core/models/admin_model.dart';

abstract class AdminRepository {
  Future<AdminModel?> getAdmin(String id);
  Future<AdminModel> createAdmin(AdminModel admin);
  Future<AdminModel> updateAdmin(AdminModel admin);
  Future<void> deleteAdmin(String id);
  Future<List<AdminModel>> searchAdmins(String query);
  Future<AdminModel?> getAdminByEmail(String email);
  Future<void> updateAdminProfile(
    String adminId,
    AdminProfile profile,
  );
  Future<void> updateAdminPermissions(
    String adminId,
    List<AdminPermission> permissions,
  );
  Future<void> updateAdminRole(
    String adminId,
    AdminRole role,
  );
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

class FirebaseAdminRepository implements AdminRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'admins';

  FirebaseAdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AdminModel?> getAdmin(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id; // Ensure ID is set

      return AdminModel.fromJson(data);
    } catch (e) {
      throw AdminRepositoryException('Failed to get admin: $e');
    }
  }

  @override
  Future<AdminModel> createAdmin(AdminModel admin) async {
    try {
      final data = admin.toJson();
      data.remove('id'); // Remove ID as Firestore will generate it

      final docRef = await _firestore.collection(_collection).add(data);

      // Return admin with generated ID
      return admin.copyWith(id: docRef.id);
    } catch (e) {
      throw AdminRepositoryException('Failed to create admin: $e');
    }
  }

  @override
  Future<AdminModel> updateAdmin(AdminModel admin) async {
    try {
      final data = admin.toJson();
      data.remove('id'); // Remove ID from data
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(admin.id).update(data);

      return admin.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw AdminRepositoryException('Failed to update admin: $e');
    }
  }

  @override
  Future<void> deleteAdmin(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw AdminRepositoryException('Failed to delete admin: $e');
    }
  }

  @override
  Future<List<AdminModel>> searchAdmins(String query) async {
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
        return AdminModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to search admins: $e');
    }
  }

  @override
  Future<AdminModel?> getAdminByEmail(String email) async {
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

      return AdminModel.fromJson(data);
    } catch (e) {
      throw AdminRepositoryException('Failed to get admin by email: $e');
    }
  }

  @override
  Future<void> updateAdminProfile(
    String adminId,
    AdminProfile profile,
  ) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'profile': profile.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AdminRepositoryException('Failed to update admin profile: $e');
    }
  }

  @override
  Future<void> updateAdminPermissions(
    String adminId,
    List<AdminPermission> permissions,
  ) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'permissions': permissions.map((p) => p.name).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AdminRepositoryException('Failed to update admin permissions: $e');
    }
  }

  @override
  Future<void> updateAdminRole(
    String adminId,
    AdminRole role,
  ) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'role': role.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AdminRepositoryException('Failed to update admin role: $e');
    }
  }

  @override
  Future<List<AdminModel>> getAdminsByRole(AdminRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: role.name)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AdminModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get admins by role: $e');
    }
  }

  @override
  Future<List<AdminModel>> getActiveAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AdminModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get active admins: $e');
    }
  }

  @override
  Future<List<AdminModel>> getSuperAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isSuperAdmin', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AdminModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get super admins: $e');
    }
  }

  @override
  Future<void> activateAdmin(String adminId) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'isActive': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AdminRepositoryException('Failed to activate admin: $e');
    }
  }

  @override
  Future<void> deactivateAdmin(String adminId) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AdminRepositoryException('Failed to deactivate admin: $e');
    }
  }

  @override
  Future<void> promoteToSuperAdmin(String adminId) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'isSuperAdmin': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Log this significant action
      await logAdminActivity(
        adminId,
        'promoted_to_super_admin',
        {'promotedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw AdminRepositoryException('Failed to promote to super admin: $e');
    }
  }

  @override
  Future<void> demoteFromSuperAdmin(String adminId) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'isSuperAdmin': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Log this significant action
      await logAdminActivity(
        adminId,
        'demoted_from_super_admin',
        {'demotedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw AdminRepositoryException('Failed to demote from super admin: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(
    String adminId,
    dynamic imageFile,
  ) async {
    try {
      // In a real implementation, this would upload to Firebase Storage
      // For now, we'll simulate the upload and return a mock URL
      await Future.delayed(const Duration(seconds: 1));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageUrl =
          'https://mock-storage.com/admins/$adminId/$timestamp.jpg';

      // Update admin document with new image URL
      await _firestore.collection(_collection).doc(adminId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return imageUrl;
    } catch (e) {
      throw AdminRepositoryException('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> logAdminActivity(
    String adminId,
    String action,
    Map<String, dynamic> details,
  ) async {
    try {
      final activityData = {
        'adminId': adminId,
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('admin_activity_logs').add(activityData);

      // Also update the admin's activity log
      await _firestore.collection(_collection).doc(adminId).update({
        'activityLog.lastActivity': DateTime.now().toIso8601String(),
        'activityLog.totalActions': FieldValue.increment(1),
      });
    } catch (e) {
      throw AdminRepositoryException('Failed to log admin activity: $e');
    }
  }

  @override
  Future<List<AdminModel>> getRecentAdmins(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AdminModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get recent admins: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final totalAdminsSnapshot =
          await _firestore.collection(_collection).get();
      final activeAdminsSnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();
      final superAdminsSnapshot = await _firestore
          .collection(_collection)
          .where('isSuperAdmin', isEqualTo: true)
          .get();

      return {
        'totalAdmins': totalAdminsSnapshot.docs.length,
        'activeAdmins': activeAdminsSnapshot.docs.length,
        'superAdmins': superAdminsSnapshot.docs.length,
        'inactiveAdmins':
            totalAdminsSnapshot.docs.length - activeAdminsSnapshot.docs.length,
      };
    } catch (e) {
      throw AdminRepositoryException('Failed to get admin stats: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAdminActivityLog(
    String adminId,
    int limit,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('admin_activity_logs')
          .where('adminId', isEqualTo: adminId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get admin activity log: $e');
    }
  }

  @override
  Future<bool> hasPermission(String adminId, AdminPermission permission) async {
    try {
      final admin = await getAdmin(adminId);
      if (admin == null) return false;

      // Super admins have all permissions
      if (admin.isSuperAdmin) return true;

      return admin.permissions.contains(permission);
    } catch (e) {
      throw AdminRepositoryException('Failed to check admin permission: $e');
    }
  }

  @override
  Future<void> revokePermission(
      String adminId, AdminPermission permission) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'permissions': FieldValue.arrayRemove([permission.name]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await logAdminActivity(
        adminId,
        'permission_revoked',
        {'permission': permission.name},
      );
    } catch (e) {
      throw AdminRepositoryException('Failed to revoke permission: $e');
    }
  }

  @override
  Future<void> grantPermission(
      String adminId, AdminPermission permission) async {
    try {
      await _firestore.collection(_collection).doc(adminId).update({
        'permissions': FieldValue.arrayUnion([permission.name]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await logAdminActivity(
        adminId,
        'permission_granted',
        {'permission': permission.name},
      );
    } catch (e) {
      throw AdminRepositoryException('Failed to grant permission: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportAdminData(String adminId) async {
    try {
      final admin = await getAdmin(adminId);

      if (admin == null) {
        throw const AdminRepositoryException(
          'Admin not found for export',
        );
      }

      // Create export data with privacy considerations
      final exportData = {
        'personalInfo': {
          'name': admin.name,
          'email': admin.email,
          'phone': admin.phone,
        },
        'profile': admin.profile.toJson(),
        'role': admin.role.name,
        'permissions': admin.permissions.map((p) => p.name).toList(),
        'preferences': admin.preferences.toJson(),
        'accountInfo': {
          'createdAt': admin.createdAt.toIso8601String(),
          'updatedAt': admin.updatedAt.toIso8601String(),
          'isActive': admin.isActive,
          'isSuperAdmin': admin.isSuperAdmin,
        },
        'activityLog': admin.activityLog.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
      };

      return exportData;
    } catch (e) {
      throw AdminRepositoryException('Failed to export admin data: $e');
    }
  }
}

class AdminRepositoryException implements Exception {
  final String message;

  const AdminRepositoryException(this.message);

  @override
  String toString() => 'AdminRepositoryException: $message';
}
