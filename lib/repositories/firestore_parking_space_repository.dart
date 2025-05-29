// lib/repositories/firestore_parking_space_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parking_space.dart';

class FirestoreParkingSpaceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'parkingSpaces';

  // Add a new parking space
  Future<ParkingSpace> addParkingSpace(String adress, int pricePerHour) async {
    try {
      print('🔥 Creating parking space in Firestore: $adress');
      
      // Create a new document with auto-generated ID
      final docRef = await _firestore.collection(_collection).add({
        'adress': adress,
        'pricePerHour': pricePerHour,
        'createdAt': FieldValue.serverTimestamp(),
        'isAvailable': true, // Default to available
      });
      
      print('✅ Parking space created with ID: ${docRef.id}');
      
      // Return the created parking space with the generated ID
      return ParkingSpace(
        id: docRef.id,
        adress: adress,
        pricePerHour: pricePerHour,
      );
    } catch (e) {
      print('❌ Error creating parking space: $e');
      throw Exception('Failed to create parking space: $e');
    }
  }

  // Get all parking spaces
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    try {
      print('🔥 Getting all parking spaces from Firestore');
      
      final snapshot = await _firestore.collection(_collection).get();
      
      final parkingSpaces = snapshot.docs.map((doc) {
        final data = doc.data();
        return ParkingSpace(
          id: doc.id,
          adress: data['adress'] as String,
          pricePerHour: data['pricePerHour'] as int,
        );
      }).toList();
      
      print('✅ Retrieved ${parkingSpaces.length} parking spaces');
      return parkingSpaces;
    } catch (e) {
      print('❌ Error getting parking spaces: $e');
      throw Exception('Failed to load parking spaces: $e');
    }
  }

  // Get a parking space by ID
  Future<ParkingSpace?> getParkingSpaceById(String id) async {
    try {
      print('🔥 Getting parking space by ID: $id');
      
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        print('⚠️ Parking space not found: $id');
        return null;
      }
      
      final data = doc.data()!;
      final parkingSpace = ParkingSpace(
        id: doc.id,
        adress: data['adress'] as String,
        pricePerHour: data['pricePerHour'] as int,
      );
      
      print('✅ Parking space found: ${parkingSpace.adress}');
      return parkingSpace;
    } catch (e) {
      print('❌ Error getting parking space: $e');
      throw Exception('Failed to load parking space: $e');
    }
  }

  // Update a parking space
  Future<bool> updateParkingSpace(String id, {String? newAdress, int? newPricePerHour, bool? isAvailable}) async {
    try {
      print('🔥 Updating parking space: $id');
      
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (newAdress != null) updateData['adress'] = newAdress;
      if (newPricePerHour != null) updateData['pricePerHour'] = newPricePerHour;
      if (isAvailable != null) updateData['isAvailable'] = isAvailable;
      
      await _firestore.collection(_collection).doc(id).update(updateData);
      
      print('✅ Parking space updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating parking space: $e');
      return false;
    }
  }

  // Remove a parking space
  Future<bool> removeParkingSpace(String id) async {
    try {
      print('🔥 Removing parking space: $id');
      
      await _firestore.collection(_collection).doc(id).delete();
      
      print('✅ Parking space removed successfully');
      return true;
    } catch (e) {
      print('❌ Error removing parking space: $e');
      return false;
    }
  }

  // Get available parking spaces
  Future<List<ParkingSpace>> getAvailableParkingSpaces() async {
    try {
      print('🔥 Getting available parking spaces from Firestore');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();
      
      final parkingSpaces = snapshot.docs.map((doc) {
        final data = doc.data();
        return ParkingSpace(
          id: doc.id,
          adress: data['adress'] as String,
          pricePerHour: data['pricePerHour'] as int,
        );
      }).toList();
      
      print('✅ Retrieved ${parkingSpaces.length} available parking spaces');
      return parkingSpaces;
    } catch (e) {
      print('❌ Error getting available parking spaces: $e');
      throw Exception('Failed to load available parking spaces: $e');
    }
  }

  // Get parking spaces stream for real-time updates
  Stream<List<ParkingSpace>> getParkingSpacesStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ParkingSpace(
              id: doc.id,
              adress: data['adress'] as String,
              pricePerHour: data['pricePerHour'] as int,
            );
          }).toList();
        });
  }

  // Search parking spaces by address
  Future<List<ParkingSpace>> searchParkingSpacesByAddress(String query) async {
    try {
      print('🔥 Searching parking spaces with address: $query');
      
      // Unfortunately, Firestore doesn't support native text search
      // For simple queries, we can use where with array-contains or startsWith
      // For more complex searching, consider using a service like Algolia
      
      // For this implementation, we'll get all parking spaces and filter client-side
      final snapshot = await _firestore.collection(_collection).get();
      
      final parkingSpaces = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return ParkingSpace(
              id: doc.id,
              adress: data['adress'] as String,
              pricePerHour: data['pricePerHour'] as int,
            );
          })
          .where((space) => 
              space.adress.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      print('✅ Found ${parkingSpaces.length} parking spaces matching: $query');
      return parkingSpaces;
    } catch (e) {
      print('❌ Error searching parking spaces: $e');
      throw Exception('Failed to search parking spaces: $e');
    }
  }
}