// lib/models/parking_space.dart
class ParkingSpace {
  final String id; // Changed from int to String for consistency
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
      id: json['id'].toString(), // Convert to String
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

  // For Firestore document data (without ID)
  Map<String, dynamic> toFirestore() {
    return {
      'adress': adress,
      'pricePerHour': pricePerHour,
    };
  }

  // Create from Firestore document
  factory ParkingSpace.fromFirestore(String docId, Map<String, dynamic> data) {
    return ParkingSpace(
      id: docId,
      adress: data['adress'] as String,
      pricePerHour: data['pricePerHour'] as int,
    );
  }
}
 