// REPLACE ENTIRE FILE: lib/models/vehicle.dart
import 'person.dart';

class Vehicle {
  final String id; // Changed from int to String for Firestore
  final String type;
  final int registrationNumber;
  final Person owner;

  Vehicle({
    required this.id,
    required this.type,
    required this.registrationNumber,
    required this.owner,
  });

  // Factory constructor to create a Vehicle from JSON (HTTP compatibility)
  factory Vehicle.fromJson(Map<String, dynamic> json, [Person? owner]) {
    if (owner != null) {
      return Vehicle(
        id: json['id'].toString(), // Convert to String
        type: json['type'] as String,
        registrationNumber: json['registrationNumber'] as int,
        owner: owner,
      );
    } else {
      // Create owner from nested json
      final ownerJson = json['owner'] as Map<String, dynamic>;
      final owner = Person.fromJson(ownerJson);
      
      return Vehicle(
        id: json['id'].toString(), // Convert to String
        type: json['type'] as String,
        registrationNumber: json['registrationNumber'] as int,
        owner: owner,
      );
    }
  }

  // Convert a Vehicle to JSON (HTTP compatibility)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'registrationNumber': registrationNumber,
      'ownerId': owner.id,
    };
  }

  // For Firestore document data (without ID)
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'registrationNumber': registrationNumber,
      'ownerId': owner.id,
    };
  }

  // Create from Firestore document
  factory Vehicle.fromFirestore(String docId, Map<String, dynamic> data, Person owner) {
    return Vehicle(
      id: docId,
      type: data['type'] as String,
      registrationNumber: data['registrationNumber'] as int,
      owner: owner,
    );
  }

  // Copy with method for updates
  Vehicle copyWith({
    String? id,
    String? type,
    int? registrationNumber,
    Person? owner,
  }) {
    return Vehicle(
      id: id ?? this.id,
      type: type ?? this.type,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      owner: owner ?? this.owner,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, type: $type, registrationNumber: $registrationNumber, owner: ${owner.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle &&
        other.id == id &&
        other.type == type &&
        other.registrationNumber == registrationNumber &&
        other.owner == owner;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ registrationNumber.hashCode ^ owner.hashCode;
}