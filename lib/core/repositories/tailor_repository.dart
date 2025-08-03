import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailorapp/core/models/tailor_model.dart';

abstract class TailorRepository {
  Future<TailorModel?> getTailor(String id);
  Future<TailorModel> createTailor(TailorModel tailor);
  Future<TailorModel> updateTailor(TailorModel tailor);
  Future<void> deleteTailor(String id);
  Future<List<TailorModel>> searchTailors(String query);
  Future<TailorModel?> getTailorByEmail(String email);
  Future<void> updateTailorProfile(
    String tailorId,
    TailorProfile profile,
  );
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
  Future<List<TailorModel>> getTailorsBySpecialization(String specialization);
  Future<List<TailorModel>> getRecentTailors(int limit);
  Future<List<TailorModel>> getActiveTailors();
  Future<List<TailorModel>> getVerifiedTailors();
  Future<void> verifyTailor(String tailorId);
  Future<void> activateTailor(String tailorId);
  Future<void> deactivateTailor(String tailorId);
  Future<String> uploadProfileImage(String tailorId, dynamic imageFile);
  Future<void> addCertification(String tailorId, String certification);
  Future<void> removeCertification(String tailorId, String certification);
  Future<List<TailorModel>> getTailorsByLocation(String location);
  Future<List<TailorModel>> getTailorsByRating(double minRating);
  Future<Map<String, dynamic>> exportTailorData(String tailorId);
}

class FirebaseTailorRepository implements TailorRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'tailors';

  FirebaseTailorRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<TailorModel?> getTailor(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id; // Ensure ID is set

      return TailorModel.fromJson(data);
    } catch (e) {
      throw TailorRepositoryException('Failed to get tailor: $e');
    }
  }

  @override
  Future<TailorModel> createTailor(TailorModel tailor) async {
    try {
      final data = tailor.toJson();
      data.remove('id'); // Remove ID as Firestore will generate it

      final docRef = await _firestore.collection(_collection).add(data);

      // Return tailor with generated ID
      return tailor.copyWith(id: docRef.id);
    } catch (e) {
      throw TailorRepositoryException('Failed to create tailor: $e');
    }
  }

  @override
  Future<TailorModel> updateTailor(TailorModel tailor) async {
    try {
      final data = tailor.toJson();
      data.remove('id'); // Remove ID from data
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(tailor.id).update(data);

      return tailor.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw TailorRepositoryException('Failed to update tailor: $e');
    }
  }

  @override
  Future<void> deleteTailor(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw TailorRepositoryException('Failed to delete tailor: $e');
    }
  }

  @override
  Future<List<TailorModel>> searchTailors(String query) async {
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
        return TailorModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to search tailors: $e');
    }
  }

  @override
  Future<TailorModel?> getTailorByEmail(String email) async {
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

      return TailorModel.fromJson(data);
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
      await _firestore.collection(_collection).doc(tailorId).update({
        'profile': profile.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
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
      await _firestore.collection(_collection).doc(tailorId).update({
        'businessInfo': businessInfo.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
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
      await _firestore.collection(_collection).doc(tailorId).update({
        'specializations': specializations,
        'updatedAt': DateTime.now().toIso8601String(),
      });
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
      await _firestore.collection(_collection).doc(tailorId).update({
        'ratings': ratings.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw TailorRepositoryException('Failed to update ratings: $e');
    }
  }

  @override
  Future<List<TailorModel>> getTailorsBySpecialization(
      String specialization) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('specializations', arrayContains: specialization)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TailorModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw TailorRepositoryException(
          'Failed to get tailors by specialization: $e');
    }
  }

  @override
  Future<List<TailorModel>> getRecentTailors(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TailorModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get recent tailors: $e');
    }
  }

  @override
  Future<List<TailorModel>> getActiveTailors() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TailorModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get active tailors: $e');
    }
  }

  @override
  Future<List<TailorModel>> getVerifiedTailors() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isVerified', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TailorModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get verified tailors: $e');
    }
  }

  @override
  Future<void> verifyTailor(String tailorId) async {
    try {
      await _firestore.collection(_collection).doc(tailorId).update({
        'isVerified': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw TailorRepositoryException('Failed to verify tailor: $e');
    }
  }

  @override
  Future<void> activateTailor(String tailorId) async {
    try {
      await _firestore.collection(_collection).doc(tailorId).update({
        'isActive': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw TailorRepositoryException('Failed to activate tailor: $e');
    }
  }

  @override
  Future<void> deactivateTailor(String tailorId) async {
    try {
      await _firestore.collection(_collection).doc(tailorId).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw TailorRepositoryException('Failed to deactivate tailor: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(
    String tailorId,
    dynamic imageFile,
  ) async {
    try {
      // In a real implementation, this would upload to Firebase Storage
      // For now, we'll simulate the upload and return a mock URL
      await Future.delayed(const Duration(seconds: 1));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageUrl =
          'https://mock-storage.com/tailors/$tailorId/$timestamp.jpg';

      // Update tailor document with new image URL
      await _firestore.collection(_collection).doc(tailorId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return imageUrl;
    } catch (e) {
      throw TailorRepositoryException('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> addCertification(String tailorId, String certification) async {
    try {
      await _firestore.collection(_collection).doc(tailorId).update({
        'certifications': FieldValue.arrayUnion([certification]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw TailorRepositoryException('Failed to add certification: $e');
    }
  }

  @override
  Future<void> removeCertification(
      String tailorId, String certification) async {
    try {
      await _firestore.collection(_collection).doc(tailorId).update({
        'certifications': FieldValue.arrayRemove([certification]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw TailorRepositoryException('Failed to remove certification: $e');
    }
  }

  @override
  Future<List<TailorModel>> getTailorsByLocation(String location) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('address.city', isEqualTo: location)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TailorModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get tailors by location: $e');
    }
  }

  @override
  Future<List<TailorModel>> getTailorsByRating(double minRating) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('ratings.averageRating', isGreaterThanOrEqualTo: minRating)
          .where('isActive', isEqualTo: true)
          .orderBy('ratings.averageRating', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TailorModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw TailorRepositoryException('Failed to get tailors by rating: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportTailorData(String tailorId) async {
    try {
      final tailor = await getTailor(tailorId);

      if (tailor == null) {
        throw const TailorRepositoryException(
          'Tailor not found for export',
        );
      }

      // Create export data with privacy considerations
      final exportData = {
        'personalInfo': {
          'name': tailor.name,
          'email': tailor.email,
          'phone': tailor.phone,
          'dateOfBirth': tailor.dateOfBirth?.toIso8601String(),
          'gender': tailor.gender,
        },
        'profile': tailor.profile.toJson(),
        'businessInfo': tailor.businessInfo.toJson(),
        'specializations': tailor.specializations,
        'certifications': tailor.certifications,
        'ratings': tailor.ratings.toJson(),
        'address': tailor.address?.toJson(),
        'accountInfo': {
          'createdAt': tailor.createdAt.toIso8601String(),
          'updatedAt': tailor.updatedAt.toIso8601String(),
          'isVerified': tailor.isVerified,
          'isActive': tailor.isActive,
        },
        'orderStats': {
          'activeOrdersCount': tailor.activeOrders.length,
          'completedOrdersCount': tailor.completedOrders.length,
        },
        'exportedAt': DateTime.now().toIso8601String(),
      };

      return exportData;
    } catch (e) {
      throw TailorRepositoryException('Failed to export tailor data: $e');
    }
  }
}

class TailorRepositoryException implements Exception {
  final String message;

  const TailorRepositoryException(this.message);

  @override
  String toString() => 'TailorRepositoryException: $message';
}
