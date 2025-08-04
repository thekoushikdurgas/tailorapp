import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/core/models/admin_model.dart';
import 'package:tailorapp/core/repositories/admin_repository.dart';

class SupabaseAdminRepository implements AdminRepository {
  final SupabaseClient _supabase;
  final String _table = 'admins';

  SupabaseAdminRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<AdminModel?> getAdmin(String id) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('id', id).maybeSingle();

      if (response == null) {
        return null;
      }

      return AdminModel.fromJson(response);
    } catch (e) {
      throw AdminRepositoryException('Failed to get admin: $e');
    }
  }

  @override
  Future<AdminModel> createAdmin(AdminModel admin) async {
    try {
      final data = admin.toJson();
      data.remove('id'); // Remove ID, let Supabase generate it
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _supabase.from(_table).insert(data).select().single();

      return AdminModel.fromJson(response);
    } catch (e) {
      throw AdminRepositoryException('Failed to create admin: $e');
    }
  }

  @override
  Future<AdminModel> updateAdmin(AdminModel admin) async {
    try {
      final data = admin.toJson();
      data.remove('id'); // Remove ID from update data
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_table)
          .update(data)
          .eq('id', admin.id)
          .select()
          .single();

      return AdminModel.fromJson(response);
    } catch (e) {
      throw AdminRepositoryException('Failed to update admin: $e');
    }
  }

  @override
  Future<void> deleteAdmin(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw AdminRepositoryException('Failed to delete admin: $e');
    }
  }

  @override
  Future<List<AdminModel>> searchAdmins(String query) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .ilike('name', '%$query%')
          .limit(20);

      return response.map((json) => AdminModel.fromJson(json)).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to search admins: $e');
    }
  }

  @override
  Future<AdminModel?> getAdminByEmail(String email) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return AdminModel.fromJson(response);
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
      await _supabase.from(_table).update({
        'profile': profile.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
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
      await _supabase.from(_table).update({
        'permissions': permissions.map((p) => p.toString()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
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
      await _supabase.from(_table).update({
        'role': role.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
    } catch (e) {
      throw AdminRepositoryException('Failed to update admin role: $e');
    }
  }

  @override
  Future<List<AdminModel>> getAdminsByRole(AdminRole role) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('role', role.toString())
          .order('created_at', ascending: false);

      return response.map((json) => AdminModel.fromJson(json)).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get admins by role: $e');
    }
  }

  @override
  Future<List<AdminModel>> getActiveAdmins() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map((json) => AdminModel.fromJson(json)).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get active admins: $e');
    }
  }

  @override
  Future<List<AdminModel>> getSuperAdmins() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('role', AdminRole.superAdmin.toString())
          .order('created_at', ascending: false);

      return response.map((json) => AdminModel.fromJson(json)).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get super admins: $e');
    }
  }

  @override
  Future<void> activateAdmin(String adminId) async {
    try {
      await _supabase.from(_table).update({
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
    } catch (e) {
      throw AdminRepositoryException('Failed to activate admin: $e');
    }
  }

  @override
  Future<void> deactivateAdmin(String adminId) async {
    try {
      await _supabase.from(_table).update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
    } catch (e) {
      throw AdminRepositoryException('Failed to deactivate admin: $e');
    }
  }

  @override
  Future<void> promoteToSuperAdmin(String adminId) async {
    try {
      await _supabase.from(_table).update({
        'role': AdminRole.superAdmin.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
    } catch (e) {
      throw AdminRepositoryException('Failed to promote to super admin: $e');
    }
  }

  @override
  Future<void> demoteFromSuperAdmin(String adminId) async {
    try {
      await _supabase.from(_table).update({
        'role': AdminRole.platformManager.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);
    } catch (e) {
      throw AdminRepositoryException('Failed to demote from super admin: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String adminId, dynamic imageFile) async {
    try {
      // Upload to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profiles/admins/$adminId/$timestamp.jpg';

      // Upload file to storage bucket
      await _supabase.storage.from('avatars').uploadBinary(fileName, imageFile);

      // Get public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // Update admin document with new image URL
      await _supabase.from(_table).update({
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', adminId);

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
      await _supabase.from('admin_activity_logs').insert({
        'admin_id': adminId,
        'action': action,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AdminRepositoryException('Failed to log admin activity: $e');
    }
  }

  @override
  Future<List<AdminModel>> getRecentAdmins(int limit) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => AdminModel.fromJson(json)).toList();
    } catch (e) {
      throw AdminRepositoryException('Failed to get recent admins: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      // Get total admins
      final totalAdmins =
          await _supabase.from(_table).select('*').count(CountOption.exact);

      // Get active admins
      final activeAdmins = await _supabase
          .from(_table)
          .select('*')
          .eq('is_active', true)
          .count(CountOption.exact);

      // Get super admins
      final superAdmins = await _supabase
          .from(_table)
          .select('*')
          .eq('role', AdminRole.superAdmin.toString())
          .count(CountOption.exact);

      return {
        'total_admins': totalAdmins.count,
        'active_admins': activeAdmins.count,
        'super_admins': superAdmins.count,
        'inactive_admins': totalAdmins.count - activeAdmins.count,
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
      final response = await _supabase
          .from('admin_activity_logs')
          .select()
          .eq('admin_id', adminId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      throw AdminRepositoryException('Failed to get admin activity log: $e');
    }
  }

  @override
  Future<bool> hasPermission(String adminId, AdminPermission permission) async {
    try {
      final admin = await getAdmin(adminId);
      if (admin == null) return false;

      return admin.permissions.contains(permission);
    } catch (e) {
      throw AdminRepositoryException('Failed to check admin permission: $e');
    }
  }

  @override
  Future<void> revokePermission(
    String adminId,
    AdminPermission permission,
  ) async {
    try {
      final admin = await getAdmin(adminId);
      if (admin == null) return;

      final updatedPermissions =
          admin.permissions.where((p) => p != permission).toList();
      await updateAdminPermissions(adminId, updatedPermissions);
    } catch (e) {
      throw AdminRepositoryException('Failed to revoke admin permission: $e');
    }
  }

  @override
  Future<void> grantPermission(
    String adminId,
    AdminPermission permission,
  ) async {
    try {
      final admin = await getAdmin(adminId);
      if (admin == null) return;

      if (!admin.permissions.contains(permission)) {
        final updatedPermissions = [...admin.permissions, permission];
        await updateAdminPermissions(adminId, updatedPermissions);
      }
    } catch (e) {
      throw AdminRepositoryException('Failed to grant admin permission: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportAdminData(String adminId) async {
    try {
      final admin = await getAdmin(adminId);
      if (admin == null) {
        throw const AdminRepositoryException('Admin not found for export');
      }

      // Get activity logs
      final activityLogs = await getAdminActivityLog(adminId, 100);

      final exportData = {
        'personal_info': {
          'name': admin.name,
          'email': admin.email,
          'phone': admin.phone,
          'role': admin.role.toString(),
        },
        'permissions': admin.permissions.map((p) => p.toString()).toList(),
        'profile': admin.profile.toJson(),
        'account_info': {
          'created_at': admin.createdAt.toIso8601String(),
          'updated_at': admin.updatedAt.toIso8601String(),
          'is_active': admin.isActive,
        },
        'activity_logs': activityLogs,
        'exported_at': DateTime.now().toIso8601String(),
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
