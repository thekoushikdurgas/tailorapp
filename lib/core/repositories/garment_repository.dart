import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/core/models/garment_model.dart';

abstract class GarmentRepository {
  Future<GarmentModel?> getGarment(String id);
  Future<GarmentModel> createGarment(GarmentModel garment);
  Future<GarmentModel> updateGarment(GarmentModel garment);
  Future<void> deleteGarment(String id);
  Future<List<GarmentModel>> searchGarments(String query);
  Future<List<GarmentModel>> getGarmentsByCategory(String category);
  Future<List<GarmentModel>> getGarmentsByTailor(String tailorId);
  Future<List<GarmentModel>> getGarmentsByCustomer(String customerId);
  Future<List<GarmentModel>> getFeaturedGarments();
  Future<List<GarmentModel>> getRecentGarments(int limit);
  Future<String> uploadGarmentImage(String garmentId, dynamic imageFile);
  Future<void> updateGarmentStatus(String garmentId, String status);
  Future<void> addGarmentTag(String garmentId, String tag);
  Future<void> removeGarmentTag(String garmentId, String tag);
  Future<Map<String, dynamic>> exportGarmentData(String garmentId);
  Future<List<GarmentModel>> getGarmentsByType(GarmentType type);
  Future<List<GarmentModel>> getGarmentsByStatus(GarmentStatus status);
  Future<List<GarmentModel>> getGarmentsByPriceRange(
    double minPrice,
    double maxPrice,
  );
  Stream<GarmentModel> watchGarment(String id);
}

/// Supabase implementation of GarmentRepository
///
/// Handles garment data management including designs, fabrics, patterns,
/// customizations, and AI suggestions using Supabase PostgreSQL
class GarmentRepositoryImpl implements GarmentRepository {
  final SupabaseClient _supabase;
  final String _table = 'garments';

  GarmentRepositoryImpl({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<GarmentModel?> getGarment(String id) async {
    try {
      final response = await _supabase.from(_table).select().eq('id', id).maybeSingle();

      if (response == null) {
        return null;
      }

      return GarmentModel.fromJson(response);
    } catch (e) {
      throw GarmentRepositoryException('Failed to get garment: $e');
    }
  }

  @override
  Future<GarmentModel> createGarment(GarmentModel garment) async {
    try {
      final data = garment.toJson();
      data.remove('id'); // Remove ID, let Supabase generate it
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).insert(data).select().single();

      return GarmentModel.fromJson(response);
    } catch (e) {
      throw GarmentRepositoryException('Failed to create garment: $e');
    }
  }

  @override
  Future<GarmentModel> updateGarment(GarmentModel garment) async {
    try {
      final data = garment.toJson();
      data.remove('id'); // Remove ID from update data
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase.from(_table).update(data).eq('id', garment.id).select().single();

      return GarmentModel.fromJson(response);
    } catch (e) {
      throw GarmentRepositoryException('Failed to update garment: $e');
    }
  }

  @override
  Future<void> deleteGarment(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw GarmentRepositoryException('Failed to delete garment: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByType(GarmentType type) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('type', type.toString()).order('created_at', ascending: false);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get garments by type: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByStatus(GarmentStatus status) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('status', status.toString()).order('created_at', ascending: false);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get garments by status: $e');
    }
  }

  @override
  Future<List<GarmentModel>> searchGarments(String query) async {
    try {
      final response = await _supabase.from(_table).select().ilike('name', '%$query%').limit(20);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to search garments: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getRecentGarments(int limit) async {
    try {
      final response = await _supabase.from(_table).select().order('created_at', ascending: false).limit(limit);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get recent garments: $e');
    }
  }

  @override
  Future<void> updateGarmentStatus(
    String garmentId,
    String status,
  ) async {
    try {
      await _supabase.from(_table).update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', garmentId);
    } catch (e) {
      throw GarmentRepositoryException('Failed to update garment status: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .gte('price', minPrice)
          .lte('price', maxPrice)
          .order('price', ascending: true);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException(
        'Failed to get garments by price range: $e',
      );
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByCustomer(String customerId) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('customer_id', customerId).order('created_at', ascending: false);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException(
        'Failed to get garments by customer: $e',
      );
    }
  }

  @override
  Stream<GarmentModel> watchGarment(String id) {
    return _supabase.from(_table).stream(primaryKey: ['id']).eq('id', id).map((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            return GarmentModel.fromJson(data.first);
          }
          throw const GarmentRepositoryException('Garment not found');
        });
  }

  @override
  Future<List<GarmentModel>> getGarmentsByCategory(String category) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('category', category).order('created_at', ascending: false);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException(
        'Failed to get garments by category: $e',
      );
    }
  }

  @override
  Future<List<GarmentModel>> getFeaturedGarments() async {
    try {
      final response =
          await _supabase.from(_table).select().eq('is_featured', true).order('created_at', ascending: false);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get featured garments: $e');
    }
  }

  @override
  Future<void> addGarmentTag(String garmentId, String tag) async {
    try {
      // First get current tags
      final response = await _supabase.from(_table).select('tags').eq('id', garmentId).single();

      final currentTags = List<String>.from(response['tags'] ?? []);
      if (!currentTags.contains(tag)) {
        currentTags.add(tag);

        await _supabase.from(_table).update({
          'tags': currentTags,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', garmentId);
      }
    } catch (e) {
      throw GarmentRepositoryException('Failed to add garment tag: $e');
    }
  }

  @override
  Future<void> removeGarmentTag(String garmentId, String tag) async {
    try {
      // First get current tags
      final response = await _supabase.from(_table).select('tags').eq('id', garmentId).single();

      final currentTags = List<String>.from(response['tags'] ?? []);
      currentTags.remove(tag);

      await _supabase.from(_table).update({
        'tags': currentTags,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', garmentId);
    } catch (e) {
      throw GarmentRepositoryException('Failed to remove garment tag: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportGarmentData(String garmentId) async {
    try {
      final garment = await getGarment(garmentId);
      if (garment == null) {
        throw const GarmentRepositoryException('Garment not found');
      }

      return {
        'garment_info': garment.toJson(),
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw GarmentRepositoryException('Failed to export garment data: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByTailor(String tailorId) async {
    try {
      final response =
          await _supabase.from(_table).select().eq('tailor_id', tailorId).order('created_at', ascending: false);

      return response.map((json) => GarmentModel.fromJson(json)).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get garments by tailor: $e');
    }
  }

  @override
  Future<String> uploadGarmentImage(String garmentId, dynamic imageFile) async {
    try {
      // For now, return a placeholder URL
      // In a real implementation, you would upload to Supabase Storage
      final fileName = 'garment_${garmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Placeholder implementation - replace with actual Supabase Storage upload
      final imageUrl = 'https://placeholder.example.com/images/$fileName';

      // Update the garment record with the image URL
      await _supabase.from(_table).update({
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', garmentId);

      return imageUrl;
    } catch (e) {
      throw GarmentRepositoryException('Failed to upload garment image: $e');
    }
  }
}

// Exception classes for garment repository operations
class GarmentRepositoryException implements Exception {
  final String message;

  const GarmentRepositoryException(this.message);

  @override
  String toString() => 'GarmentRepositoryException: $message';
}
