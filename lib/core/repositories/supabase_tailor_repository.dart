import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/core/models/tailor_model.dart';
import 'package:tailorapp/core/repositories/tailor_repository.dart';

class SupabaseTailorRepository implements TailorRepository {
  final SupabaseClient _supabase;
  final String _table = 'tailors';

  SupabaseTailorRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<TailorModel?> getTailor(String id) async {
    try {
      final response = await _supabase.from(_table).select().eq('id', id).maybeSingle();

      if (response == null) {
        return null;
      }

      return TailorModel.fromJson(response);
    } catch (e) {
      throw TailorRepositoryException('Failed to get tailor: $e');
    }
  }

  @override
  Future<TailorModel> createTailor(TailorModel tailor) async {
    try {
      final data = tailor.toJson();
      data.remove('id'); // Remove ID, let Supabase generate it
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).insert(data).select().single();

      return TailorModel.fromJson(response);
    } catch (e) {
      throw TailorRepositoryException('Failed to create tailor: $e');
    }
  }

  @override
  Future<TailorModel> updateTailor(TailorModel tailor) async {
    try {
      final data = tailor.toJson();
      data.remove('id'); // Remove ID from update data
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).update(data).eq('id', tailor.id).select().single();

      return TailorModel.fromJson(response);
    } catch (e) {
      throw TailorRepositoryException('Failed to update tailor: $e');
    }
  }

  @override
  Future<void> deleteTailor(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw TailorRepositoryException('Failed to delete tailor: $e');
    }
  }

  @override
  Future<List<TailorModel>> searchTailors(String query) async {
    try {
      final response = await _supabase.from(_table).select().ilike('name', '%$query%').limit(20);

      return response.map((json) => TailorModel.fromJson(json)).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to search tailors: $e');
    }
  }

  @override
  Future<TailorModel?> getTailorByEmail(String email) async {
    try {
      final response = await _supabase.from(_table).select().eq('email', email).maybeSingle();

      if (response == null) {
        return null;
      }

      return TailorModel.fromJson(response);
    } catch (e) {
      throw TailorRepositoryException('Failed to get tailor by email: $e');
    }
  }

  @override
  Future<void> updateTailorProfile(
    String tailorId,
    TailorProfile profile,
  ) async {
    try {
      await _supabase.from(_table).update({
        'profile': profile.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to update tailor profile: $e');
    }
  }

  @override
  Future<void> updateBusinessInfo(
    String tailorId,
    TailorBusinessInfo businessInfo,
  ) async {
    try {
      await _supabase.from(_table).update({
        'business_info': businessInfo.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to update business info: $e');
    }
  }

  @override
  Future<void> updateSpecializations(
    String tailorId,
    List<String> specializations,
  ) async {
    try {
      await _supabase.from(_table).update({
        'specializations': specializations,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to update specializations: $e');
    }
  }

  @override
  Future<void> updateRatings(
    String tailorId,
    TailorRatings ratings,
  ) async {
    try {
      await _supabase.from(_table).update({
        'ratings': ratings.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to update ratings: $e');
    }
  }

  @override
  Future<List<TailorModel>> getTailorsBySpecialization(
    String specialization,
  ) async {
    try {
      final response = await _supabase.from(_table).select().contains('specializations', [specialization]).order(
        'created_at',
        ascending: false,
      );

      return response.map((json) => TailorModel.fromJson(json)).toList();
    } catch (e) {
      throw TailorRepositoryException(
        'Failed to get tailors by specialization: $e',
      );
    }
  }

  @override
  Future<List<TailorModel>> getRecentTailors(int limit) async {
    try {
      final response = await _supabase.from(_table).select().order('created_at', ascending: false).limit(limit);

      return response.map((json) => TailorModel.fromJson(json)).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get recent tailors: $e');
    }
  }

  @override
  Future<List<TailorModel>> getActiveTailors() async {
    try {
      final response =
          await _supabase.from(_table).select().eq('is_active', true).order('created_at', ascending: false);

      return response.map((json) => TailorModel.fromJson(json)).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get active tailors: $e');
    }
  }

  @override
  Future<List<TailorModel>> getVerifiedTailors() async {
    try {
      final response =
          await _supabase.from(_table).select().eq('is_verified', true).order('created_at', ascending: false);

      return response.map((json) => TailorModel.fromJson(json)).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get verified tailors: $e');
    }
  }

  @override
  Future<void> verifyTailor(String tailorId) async {
    try {
      await _supabase.from(_table).update({
        'is_verified': true,
        'verified_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to verify tailor: $e');
    }
  }

  @override
  Future<void> activateTailor(String tailorId) async {
    try {
      await _supabase.from(_table).update({
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to activate tailor: $e');
    }
  }

  @override
  Future<void> deactivateTailor(String tailorId) async {
    try {
      await _supabase.from(_table).update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to deactivate tailor: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String tailorId, dynamic imageFile) async {
    try {
      // Upload to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profiles/tailors/$tailorId/$timestamp.jpg';

      // Upload file to storage bucket
      await _supabase.storage.from('avatars').uploadBinary(fileName, imageFile);

      // Get public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // Update tailor document with new image URL
      await _supabase.from(_table).update({
        'profile_image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);

      return imageUrl;
    } catch (e) {
      throw TailorRepositoryException('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> addCertification(String tailorId, String certification) async {
    try {
      final tailor = await getTailor(tailorId);
      if (tailor == null) return;

      final updatedCertifications = [
        ...tailor.certifications,
        certification,
      ];
      await _supabase.from(_table).update({
        'certifications': updatedCertifications,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to add certification: $e');
    }
  }

  @override
  Future<void> removeCertification(
    String tailorId,
    String certification,
  ) async {
    try {
      final tailor = await getTailor(tailorId);
      if (tailor == null) return;

      final updatedCertifications = tailor.certifications.where((cert) => cert != certification).toList();

      await _supabase.from(_table).update({
        'certifications': updatedCertifications,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to remove certification: $e');
    }
  }

  @override
  Future<List<TailorModel>> getTailorsByLocation(
    double lat,
    double lng,
    double radius,
  ) async {
    try {
      // For now, implement a simple location-based search
      // In a real implementation, you would use geospatial queries
      final response = await _supabase.from(_table).select().order('created_at', ascending: false);

      // Filter by distance in-memory (placeholder implementation)
      final tailors = response.map((json) => TailorModel.fromJson(json)).toList();

      // Return all tailors for now - implement proper geospatial filtering later
      return tailors;
    } catch (e) {
      throw TailorRepositoryException('Failed to get tailors by location: $e');
    }
  }

  @override
  Future<List<TailorModel>> getTailorsByRating(double minRating) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .gte('ratings.average_rating', minRating)
          .order('ratings.average_rating', ascending: false);

      return response.map((json) => TailorModel.fromJson(json)).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get tailors by rating: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportTailorData(String tailorId) async {
    try {
      final tailor = await getTailor(tailorId);
      if (tailor == null) {
        throw const TailorRepositoryException('Tailor not found for export');
      }

      final exportData = {
        'personal_info': {
          'name': tailor.name,
          'email': tailor.email,
          'phone': tailor.phone,
          'address': tailor.address?.toJson(),
        },
        'profile': tailor.profile.toJson(),
        'business_info': tailor.businessInfo.toJson(),
        'specializations': tailor.specializations,
        'certifications': tailor.certifications,
        'ratings': tailor.ratings.toJson(),
        'account_info': {
          'created_at': tailor.createdAt.toIso8601String(),
          'updated_at': tailor.updatedAt.toIso8601String(),
          'is_verified': tailor.isVerified,
          'is_active': tailor.isActive,
        },
        'exported_at': DateTime.now().toIso8601String(),
      };

      return exportData;
    } catch (e) {
      throw TailorRepositoryException('Failed to export tailor data: $e');
    }
  }

  // Missing interface methods
  @override
  Future<List<TailorModel>> getTailorsBySpecialty(String specialty) async {
    return getTailorsBySpecialization(specialty);
  }

  @override
  Future<void> unverifyTailor(String tailorId) async {
    try {
      await _supabase.from(_table).update({
        'is_verified': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to unverify tailor: $e');
    }
  }

  @override
  Future<void> updateTailorSkills(String tailorId, List<String> skills) async {
    try {
      await _supabase.from(_table).update({
        'skills': skills,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', tailorId);
    } catch (e) {
      throw TailorRepositoryException('Failed to update tailor skills: $e');
    }
  }

  @override
  Future<void> updateTailorSpecialties(
    String tailorId,
    List<String> specialties,
  ) async {
    return updateSpecializations(tailorId, specialties);
  }

  @override
  Future<void> addTailorCertificate(
    String tailorId,
    String certificateUrl,
    String description,
  ) async {
    return addCertification(tailorId, '$certificateUrl|$description');
  }

  @override
  Future<void> removeTailorCertificate(
    String tailorId,
    String certificateUrl,
  ) async {
    return removeCertification(tailorId, certificateUrl);
  }
}

class TailorRepositoryException implements Exception {
  final String message;

  const TailorRepositoryException(this.message);

  @override
  String toString() => 'TailorRepositoryException: $message';
}
