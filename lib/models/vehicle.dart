// lib/models/vehicle.dart
import 'person.dart';

class Vehicle {
  final int id;
  final String type;
  final int registrationNumber;
  final Person owner;

  Vehicle({
    required this.id,
    required this.type,
    required this.registrationNumber,
    required this.owner,
  });

  // Factory constructor to create a Vehicle from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json, [Person? owner]) {
    if (owner != null) {
      return Vehicle(
        id: json['id'] as int,
        type: json['type'] as String,
        registrationNumber: json['registrationNumber'] as int,
        owner: owner,
      );
    } else {
      // Create owner from nested json
      final ownerJson = json['owner'] as Map<String, dynamic>;
      final owner = Person.fromJson(ownerJson);
      
      return Vehicle(
        id: json['id'] as int,
        type: json['type'] as String,
        registrationNumber: json['registrationNumber'] as int,
        owner: owner,
      );
    }
  }

  // Convert a Vehicle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'registrationNumber': registrationNumber,
      'ownerId': owner.id,
    };
  }
}