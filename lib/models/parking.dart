class Parking {
  final int id;
  final String fordon;       // Vehicle ID
  final String parkingPlace; // Parking Space ID
  final String startTime;
  final String? endTime;

  Parking({
    required this.id,
    required this.fordon,
    required this.parkingPlace,
    required this.startTime,
    this.endTime,
  });

  // Create a Parking from JSON
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      fordon: json['fordon'],
      parkingPlace: json['parkingPlace'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  // Convert Parking to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fordon': fordon,
      'parkingPlace': parkingPlace,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // Check if parking is active (no end time)
  bool get isActive => endTime == null;

  // Create a copy of the Parking with possible updates
  Parking copyWith({
    int? id,
    String? fordon,
    String? parkingPlace,
    String? startTime,
    String? endTime,
  }) {
    return Parking(
      id: id ?? this.id,
      fordon: fordon ?? this.fordon,
      parkingPlace: parkingPlace ?? this.parkingPlace,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}