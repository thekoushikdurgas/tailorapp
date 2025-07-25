import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailorapp/core/models/garment_model.dart';

abstract class GarmentRepository {
  Future<GarmentModel?> getGarment(String id);
  Future<GarmentModel> createGarment(GarmentModel garment);
  Future<GarmentModel> updateGarment(GarmentModel garment);
  Future<void> deleteGarment(String id);
  Future<List<GarmentModel>> getGarmentsByType(GarmentType type);
  Future<List<GarmentModel>> getGarmentsByStatus(GarmentStatus status);
  Future<List<GarmentModel>> searchGarments(String query);
  Future<List<GarmentModel>> getRecentGarments(int limit);
  Future<void> updateGarmentStatus(String garmentId, GarmentStatus status);
  Future<List<GarmentModel>> getGarmentsByPriceRange(
    double minPrice,
    double maxPrice,
  );
  Future<List<GarmentModel>> getGarmentsByCustomer(String customerId);
  Stream<GarmentModel> watchGarment(String id);
}

class FirebaseGarmentRepository implements GarmentRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'garments';

  FirebaseGarmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<GarmentModel?> getGarment(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return GarmentModel.fromJson(data);
    } catch (e) {
      throw GarmentRepositoryException('Failed to get garment: $e');
    }
  }

  @override
  Future<GarmentModel> createGarment(GarmentModel garment) async {
    try {
      final data = garment.toJson();
      data.remove('id'); // Remove ID as Firestore will generate it

      final docRef = await _firestore.collection(_collection).add(data);

      return garment.copyWith(id: docRef.id);
    } catch (e) {
      throw GarmentRepositoryException('Failed to create garment: $e');
    }
  }

  @override
  Future<GarmentModel> updateGarment(GarmentModel garment) async {
    try {
      final data = garment.toJson();
      data.remove('id');
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(garment.id).update(data);

      return garment.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw GarmentRepositoryException('Failed to update garment: $e');
    }
  }

  @override
  Future<void> deleteGarment(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw GarmentRepositoryException('Failed to delete garment: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByType(GarmentType type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('type', isEqualTo: type.value)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GarmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get garments by type: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByStatus(GarmentStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.value)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GarmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get garments by status: $e');
    }
  }

  @override
  Future<List<GarmentModel>> searchGarments(String query) async {
    try {
      final nameQuery = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .limit(20)
          .get();

      final descriptionQuery = await _firestore
          .collection(_collection)
          .where('description', isGreaterThanOrEqualTo: query)
          .where('description', isLessThan: '$query\uf8ff')
          .limit(20)
          .get();

      final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      allDocs.addAll(nameQuery.docs);
      allDocs.addAll(descriptionQuery.docs);

      // Remove duplicates
      final uniqueDocs = allDocs
          .fold<Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>>(
        {},
        (map, doc) {
          map[doc.id] = doc;
          return map;
        },
      );

      return uniqueDocs.values.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GarmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to search garments: $e');
    }
  }

  @override
  Future<List<GarmentModel>> getRecentGarments(int limit) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GarmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw GarmentRepositoryException('Failed to get recent garments: $e');
    }
  }

  @override
  Future<void> updateGarmentStatus(
    String garmentId,
    GarmentStatus status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(garmentId).update({
        'status': status.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
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
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .orderBy('price')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GarmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw GarmentRepositoryException(
        'Failed to get garments by price range: $e',
      );
    }
  }

  @override
  Future<List<GarmentModel>> getGarmentsByCustomer(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GarmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw GarmentRepositoryException(
        'Failed to get garments by customer: $e',
      );
    }
  }

  @override
  Stream<GarmentModel> watchGarment(String id) {
    try {
      return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
        if (!doc.exists) {
          throw GarmentRepositoryException('Garment not found: $id');
        }

        final data = doc.data()!;
        data['id'] = doc.id;
        return GarmentModel.fromJson(data);
      });
    } catch (e) {
      throw GarmentRepositoryException('Failed to watch garment: $e');
    }
  }
}

class GarmentRepositoryException implements Exception {
  final String message;

  const GarmentRepositoryException(this.message);

  @override
  String toString() => 'GarmentRepositoryException: $message';
}
