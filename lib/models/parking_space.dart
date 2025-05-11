// lib/models/parking_space.dart
class ParkingSpace {
  final int id;
  final String adress;
  final int pricePerHour;

  ParkingSpace({
    required this.id,
    required this.adress,
    required this.pricePerHour,
  });

  // Factory constructor to create a ParkingSpace from JSON
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'] as int,
      adress: json['adress'] as String,
      pricePerHour: json['pricePerHour'] as int,
    );
  }

  // Convert a ParkingSpace to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adress': adress,
      'pricePerHour': pricePerHour,
    };
  }
}