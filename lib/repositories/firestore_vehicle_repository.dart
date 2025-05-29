// lib/repositories/firestore_vehicle_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../models/person.dart';
import 'firestore_person_repository.dart';

class FirestoreVehicleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vehicles';
  final FirestorePersonRepository _personRepository;
  
  FirestoreVehicleRepository({required FirestorePersonRepository personRepository})
      : _personRepository = personRepository;

  // Add a vehicle to Firestore
  Future<Vehicle> addVehicle(String type, int registrationNumber, String ownerId) async {
    try {
      print('🔥 Creating vehicle in Firestore: $type');
      
      // First, get the owner from Firestore
      final owner = await _personRepository.getPersonById(ownerId);
      if (owner == null) {
        throw Exception('Owner not found with ID: $ownerId');
      }
      
      // Create a new document with auto-generated ID
      final docRef = await _firestore.collection(_collection).add({
        'type': type,
        'registrationNumber': registrationNumber,
        'ownerId': ownerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Vehicle created with ID: ${docRef.id}');
      
      // Return the created vehicle with the generated ID
      return Vehicle(
        id: docRef.id,
        type: type,
        registrationNumber: registrationNumber,
        owner: owner,
      );
    } catch (e) {
      print('❌ Error creating vehicle: $e');
      throw Exception('Failed to create vehicle: $e');
    }
  }

  // Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      print('🔥 Getting all vehicles from Firestore');
      
      final snapshot = await _firestore.collection(_collection).get();
      
      // Process the vehicles
      List<Vehicle> vehicles = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final ownerId = data['ownerId'] as String;
        
        // Get the owner for each vehicle
        final owner = await _personRepository.getPersonById(ownerId);
        if (owner != null) {
          vehicles.add(
            Vehicle(
              id: doc.id,
              type: data['type'] as String,
              registrationNumber: data['registrationNumber'] as int,
              owner: owner,
            ),
          );
        }
      }
      
      print('✅ Retrieved ${vehicles.length} vehicles');
      return vehicles;
    } catch (e) {
      print('❌ Error getting vehicles: $e');
      throw Exception('Failed to load vehicles: $e');
    }
  }

  // Get vehicles by owner ID
  Future<List<Vehicle>> getVehiclesByOwnerId(String ownerId) async {
    try {
      print('🔥 Getting vehicles for owner: $ownerId');
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: ownerId)
          .get();
      
      // Get the owner once for all vehicles
      final owner = await _personRepository.getPersonById(ownerId);
      if (owner == null) {
        print('⚠️ Owner not found with ID: $ownerId');
        return [];
      }
      
      // Process the vehicles
      final vehicles = snapshot.docs.map((doc) {
        final data = doc.data();
        return Vehicle(
          id: doc.id,
          type: data['type'] as String,
          registrationNumber: data['registrationNumber'] as int,
          owner: owner,
        );
      }).toList();
      
      print('✅ Retrieved ${vehicles.length} vehicles for owner: $ownerId');
      return vehicles;
    } catch (e) {
      print('❌ Error getting vehicles by owner: $e');
      throw Exception('Failed to load vehicles by owner: $e');
    }
  }

  // Get a vehicle by ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      print('🔥 Getting vehicle by ID: $id');
      
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        print('⚠️ Vehicle not found: $id');
        return null;
      }
      
      final data = doc.data()!;
      final ownerId = data['ownerId'] as String;
      
      // Get the owner
      final owner = await _personRepository.getPersonById(ownerId);
      if (owner == null) {
        print('⚠️ Owner not found for vehicle: $id');
        throw Exception('Owner not found for vehicle: $id');
      }
      
      final vehicle = Vehicle(
        id: doc.id,
        type: data['type'] as String,
        registrationNumber: data['registrationNumber'] as int,
        owner: owner,
      );
      
      print('✅ Vehicle found: ${vehicle.type}');
      return vehicle;
    } catch (e) {
      print('❌ Error getting vehicle: $e');
      throw Exception('Failed to load vehicle: $e');
    }
  }

  // Update a vehicle
  Future<bool> updateVehicle(String id, {String? newType, int? newRegistrationNumber}) async {
    try {
      print('🔥 Updating vehicle: $id');
      
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (newType != null) updateData['type'] = newType;
      if (newRegistrationNumber != null) updateData['registrationNumber'] = newRegistrationNumber;
      
      await _firestore.collection(_collection).doc(id).update(updateData);
      
      print('✅ Vehicle updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating vehicle: $e');
      return false;
    }
  }

  // Remove a vehicle
  Future<bool> removeVehicle(String id) async {
    try {
      print('🔥 Removing vehicle: $id');
      
      await _firestore.collection(_collection).doc(id).delete();
      
      print('✅ Vehicle removed successfully');
      return true;
    } catch (e) {
      print('❌ Error removing vehicle: $e');
      return false;
    }
  }

  // Get a stream of vehicles for an owner - for real-time updates
  Stream<List<Vehicle>> getVehiclesByOwnerIdStream(String ownerId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .asyncMap((snapshot) async {
          // Get the owner once for all vehicles
          final owner = await _personRepository.getPersonById(ownerId);
          if (owner == null) {
            print('⚠️ Owner not found with ID: $ownerId');
            return [];
          }
          
          // Process the vehicles
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Vehicle(
              id: doc.id,
              type: data['type'] as String,
              registrationNumber: data['registrationNumber'] as int,
              owner: owner,
            );
          }).toList();
        });
  }
}