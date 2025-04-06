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

  // Create a Vehicle from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      type: json['type'],
      registrationNumber: json['registrationNumber'],
      owner: Person.fromJson(json['owner']),
    );
  }

  // Convert Vehicle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'registrationNumber': registrationNumber,
      'owner': owner.toJson(),
    };
  }

  // Create simplified JSON for update/create operations
  Map<String, dynamic> toSimpleJson() {
    return {
      'type': type,
      'registrationNumber': registrationNumber,
      'ownerId': owner.id,
    };
  }

  // Create a copy of the Vehicle with possible updates
  Vehicle copyWith({
    int? id,
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
}