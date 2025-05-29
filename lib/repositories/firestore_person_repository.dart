// lib/repositories/firestore_person_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';

class FirestorePersonRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'persons';

  // Add a person to Firestore with a specific ID (the Firebase Auth UID)
  Future<Person> addPerson(String uid, String name, int personnummer) async {
    try {
      print('🔥 Creating person in Firestore with ID: $uid');
      
      // Use the provided UID as the document ID
      await _firestore.collection(_collection).doc(uid).set({
        'name': name,
        'personnummer': personnummer,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Person created with ID: $uid');
      
      return Person(
        id: uid,
        name: name,
        personnummer: personnummer,
      );
    } catch (e) {
      print('❌ Error creating person: $e');
      throw Exception('Failed to create person: $e');
    }
  }

  // Get all persons
  Future<List<Person>> getAllPersons() async {
    try {
      print('🔥 Getting all persons from Firestore');
      
      final snapshot = await _firestore.collection(_collection).get();
      
      final persons = snapshot.docs.map((doc) {
        final data = doc.data();
        return Person(
          id: doc.id,
          name: data['name'] as String,
          personnummer: data['personnummer'] as int,
        );
      }).toList();
      
      print('✅ Retrieved ${persons.length} persons');
      return persons;
    } catch (e) {
      print('❌ Error getting persons: $e');
      throw Exception('Failed to load persons: $e');
    }
  }

  // Get a person by ID (Firebase Auth UID)
  Future<Person?> getPersonById(String id) async {
    try {
      print('🔥 Getting person by ID: $id');
      
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        print('⚠️ Person not found: $id');
        return null;
      }
      
      final data = doc.data()!;
      final person = Person(
        id: doc.id,
        name: data['name'] as String,
        personnummer: data['personnummer'] as int,
      );
      
      print('✅ Person found: ${person.name}');
      return person;
    } catch (e) {
      print('❌ Error getting person: $e');
      throw Exception('Failed to load person: $e');
    }
  }

  // Update a person
  Future<bool> updatePerson(String id, {String? newName, int? newPersonnummer}) async {
    try {
      print('🔥 Updating person: $id');
      
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (newName != null) updateData['name'] = newName;
      if (newPersonnummer != null) updateData['personnummer'] = newPersonnummer;
      
      await _firestore.collection(_collection).doc(id).update(updateData);
      
      print('✅ Person updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating person: $e');
      return false;
    }
  }
}