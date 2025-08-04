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

// Exception classes for garment repository operations
class GarmentRepositoryException implements Exception {
  final String message;
  GarmentRepositoryException(this.message);

  @override
  String toString() => 'GarmentRepositoryException: $message';
}
