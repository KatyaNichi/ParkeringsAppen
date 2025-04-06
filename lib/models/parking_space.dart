class ParkingSpace {
  final int id;
  final String adress;
  final int pricePerHour;

  ParkingSpace({
    required this.id,
    required this.adress,
    required this.pricePerHour,
  });

  // Create a ParkingSpace from JSON
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      adress: json['adress'],
      pricePerHour: json['pricePerHour'],
    );
  }

  // Convert ParkingSpace to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adress': adress,
      'pricePerHour': pricePerHour,
    };
  }

  // Create a copy of the ParkingSpace with possible updates
  ParkingSpace copyWith({
    int? id,
    String? adress,
    int? pricePerHour,
  }) {
    return ParkingSpace(
      id: id ?? this.id,
      adress: adress ?? this.adress,
      pricePerHour: pricePerHour ?? this.pricePerHour,
    );
  }
}