import 'package:tailorapp/core/models/tailor_model.dart';

abstract class TailorRepository {
  Future<TailorModel?> getTailor(String id);
  Future<TailorModel> createTailor(TailorModel tailor);
  Future<TailorModel> updateTailor(TailorModel tailor);
  Future<void> deleteTailor(String id);
  Future<List<TailorModel>> searchTailors(String query);
  Future<TailorModel?> getTailorByEmail(String email);
  Future<List<TailorModel>> getVerifiedTailors();
  Future<List<TailorModel>> getTailorsByLocation(
    double lat,
    double lng,
    double radius,
  );
  Future<List<TailorModel>> getTailorsBySpecialty(String specialty);
  Future<List<TailorModel>> getRecentTailors(int limit);
  Future<String> uploadProfileImage(String tailorId, dynamic imageFile);
  Future<void> updateTailorProfile(String tailorId, TailorProfile profile);
  Future<void> verifyTailor(String tailorId);
  Future<void> unverifyTailor(String tailorId);
  Future<void> updateTailorSkills(String tailorId, List<String> skills);
  Future<void> updateTailorSpecialties(
    String tailorId,
    List<String> specialties,
  );
  Future<void> addTailorCertificate(
    String tailorId,
    String certificateUrl,
    String description,
  );
  Future<void> removeTailorCertificate(String tailorId, String certificateUrl);
  Future<Map<String, dynamic>> exportTailorData(String tailorId);
  Future<void> updateBusinessInfo(
    String tailorId,
    TailorBusinessInfo businessInfo,
  );
  Future<void> updateSpecializations(
    String tailorId,
    List<String> specializations,
  );
  Future<void> updateRatings(
    String tailorId,
    TailorRatings ratings,
  );
  Future<List<TailorModel>> getTailorsBySpecialization(
    String specialization,
  );
  Future<List<TailorModel>> getActiveTailors();
  Future<void> activateTailor(String tailorId);
  Future<void> deactivateTailor(String tailorId);
  Future<void> addCertification(String tailorId, String certification);
  Future<void> removeCertification(
    String tailorId,
    String certification,
  );
  Future<List<TailorModel>> getTailorsByRating(double minRating);
}

// Exception classes for tailor repository operations
class TailorRepositoryException implements Exception {
  final String message;
  TailorRepositoryException(this.message);

  @override
  String toString() => 'TailorRepositoryException: $message';
}
