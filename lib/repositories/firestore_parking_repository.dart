
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parking.dart';

class FirestoreParkingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'parkings';


Future<List<Parking>> getParkingsByUser(String userId) async {
  try {
    print('🔥 Getting parkings for user: $userId');
    
    final snapshot = await _firestore
        .collection(_collection)
        .where('fordon', isEqualTo: userId) // Assuming fordon field stores user ID
        .get();
    
    final parkings = snapshot.docs.map((doc) {
      final data = doc.data();
      return Parking(
        id: doc.id,
        fordon: data['fordon'] as String,
        parkingPlace: data['parkingPlace'] as String,
        startTime: data['startTime'] as String?,
        endTime: data['endTime'] as String?,
        notificationId: data['notificationId'] as String?,
        estimatedDurationHours: data['estimatedDurationHours'] as int?,
      );
    }).toList();
    
    print('✅ Retrieved ${parkings.length} parkings for user');
    return parkings;
  } catch (e) {
    print('❌ Error getting parkings by user: $e');
    throw Exception('Failed to load parkings by user: $e');
  }
}
  
 Future<Parking> addParking(String fordon, String parkingPlace, String startTime, String? endTime, {
  String? notificationId,
  int? estimatedDurationHours,
}) async {
  try {
    print('🔥 Creating parking in Firestore');
    
    final docRef = await _firestore.collection(_collection).add({
      'fordon': fordon,
      'parkingPlace': parkingPlace,
      'startTime': startTime,
      'endTime': endTime,
      'notificationId': notificationId,
      'estimatedDurationHours': estimatedDurationHours,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': endTime == null, // If no end time, parking is active
    });
    
    print('✅ Parking created with ID: ${docRef.id}');
    
    return Parking(
      id: docRef.id,
      fordon: fordon,
      parkingPlace: parkingPlace,
      startTime: startTime,
      endTime: endTime,
      notificationId: notificationId,
      estimatedDurationHours: estimatedDurationHours,
    );
  } catch (e) {
    print('❌ Error creating parking: $e');
    throw Exception('Failed to create parking: $e');
  }
}


  // Update the getAllParkings method to read notification data
  Future<List<Parking>> getAllParkings() async {
  try {
    print('🔥 Getting all parkings from Firestore');
    
    final snapshot = await _firestore.collection(_collection).get();
    
    final parkings = snapshot.docs.map((doc) {
      final data = doc.data();
      
      // Safe null handling
      return Parking(
        id: doc.id,
        fordon: data['fordon'] as String? ?? 'unknown',
        parkingPlace: data['parkingPlace'] as String? ?? 'unknown',
        startTime: data['startTime'] as String?,
        endTime: data['endTime'] as String?,
        notificationId: data['notificationId'] as String?,
        estimatedDurationHours: data['estimatedDurationHours'] as int?,
      );
    }).toList();
    
    print('✅ Retrieved ${parkings.length} parkings');
    return parkings;
  } catch (e) {
    print('❌ Error getting parkings: $e');
    throw Exception('Failed to load parkings: $e');
  }
}

  // Get parkings by vehicle
  Future<List<Parking>> getParkingsByVehicle(String fordon) async {
    try {
      print('🔥 Getting parkings for vehicle: $fordon');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('fordon', isEqualTo: fordon)
          .get();
      
      final parkings = snapshot.docs.map((doc) {
        final data = doc.data();
        return Parking(
          id: doc.id,
          fordon: data['fordon'] as String,
          parkingPlace: data['parkingPlace'] as String,
          startTime: data['startTime'] as String,
          endTime: data['endTime'] as String?,
        );
      }).toList();
      
      print('✅ Retrieved ${parkings.length} parkings for vehicle');
      return parkings;
    } catch (e) {
      print('❌ Error getting parkings by vehicle: $e');
      throw Exception('Failed to load parkings by vehicle: $e');
    }
  }

  // Get parkings by parking place
  Future<List<Parking>> getParkingsByPlace(String parkingPlace) async {
    try {
      print('🔥 Getting parkings for place: $parkingPlace');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('parkingPlace', isEqualTo: parkingPlace)
          .get();
      
      final parkings = snapshot.docs.map((doc) {
        final data = doc.data();
        return Parking(
          id: doc.id,
          fordon: data['fordon'] as String,
          parkingPlace: data['parkingPlace'] as String,
          startTime: data['startTime'] as String,
          endTime: data['endTime'] as String?,
        );
      }).toList();
      
      print('✅ Retrieved ${parkings.length} parkings for place');
      return parkings;
    } catch (e) {
      print('❌ Error getting parkings by place: $e');
      throw Exception('Failed to load parkings by place: $e');
    }
  }

  // End a parking (set end time)
  Future<bool> endParking(String id, String endTime) async {
    try {
      print('🔥 Ending parking: $id');
      
      await _firestore.collection(_collection).doc(id).update({
        'endTime': endTime,
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Parking ended successfully');
      return true;
    } catch (e) {
      print('❌ Error ending parking: $e');
      throw Exception('Failed to end parking: $e');
    }
  }

  // Update a parking
  Future<bool> updateParking(String id, {String? newFordon, String? newParkingPlace, String? newStartTime, String? newEndTime}) async {
    try {
      print('🔥 Updating parking: $id');
      
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (newFordon != null) updateData['fordon'] = newFordon;
      if (newParkingPlace != null) updateData['parkingPlace'] = newParkingPlace;
      if (newStartTime != null) updateData['startTime'] = newStartTime;
      if (newEndTime != null) {
        updateData['endTime'] = newEndTime;
        updateData['isActive'] = false;
      }
      
      await _firestore.collection(_collection).doc(id).update(updateData);
      
      print('✅ Parking updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating parking: $e');
      return false;
    }
  }

  // Remove a parking
  Future<bool> removeParking(String id) async {
    try {
      print('🔥 Removing parking: $id');
      
      await _firestore.collection(_collection).doc(id).delete();
      
      print('✅ Parking removed successfully');
      return true;
    } catch (e) {
      print('❌ Error removing parking: $e');
      return false;
    }
  }
Future<List<Parking>> getActiveParkings() async {
  try {
    print('🔥 Getting active parkings from Firestore (one-time load)');
    
    final snapshot = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .get();
    
    final activeParkings = snapshot.docs.map((doc) {
      final data = doc.data();
      return Parking(
        id: doc.id,
        fordon: data['fordon'] as String? ?? 'unknown',
        parkingPlace: data['parkingPlace'] as String? ?? 'unknown',
        startTime: data['startTime'] as String?,
        endTime: null, // Active parkings have no end time
        notificationId: data['notificationId'] as String?,
        estimatedDurationHours: data['estimatedDurationHours'] as int?,
      );
    }).toList();
    
    print('✅ Retrieved ${activeParkings.length} active parkings (one-time)');
    return activeParkings;
  } catch (e) {
    print('❌ Error getting active parkings: $e');
    throw Exception('Failed to load active parkings: $e');
  }
}
  // Get active parkings stream - for real-time updates
  Stream<List<Parking>> getActiveParkingsStream() {
  print('🔥 Creating active parkings stream...');
  
  return _firestore
      .collection(_collection)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        print('📱 Stream snapshot received: ${snapshot.docs.length} documents');
        
        return snapshot.docs.map((doc) {
          final data = doc.data();
          print('   - Document ${doc.id}: ${data['fordon']} at ${data['parkingPlace']}');
          
          return Parking(
            id: doc.id,
            fordon: data['fordon'] as String? ?? 'unknown',
            parkingPlace: data['parkingPlace'] as String? ?? 'unknown',
            startTime: data['startTime'] as String?,
            endTime: null, // Active parkings have no end time
            notificationId: data['notificationId'] as String?,
            estimatedDurationHours: data['estimatedDurationHours'] as int?,
          );
        }).toList();
      });
}}