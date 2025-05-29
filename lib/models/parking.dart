class Parking {
  final String id; // Changed from int to String
  final String fordon;
  final String parkingPlace;
  final String? startTime;
  final String? endTime;

  Parking({
    required this.id,
    required this.fordon,
    required this.parkingPlace,
    this.startTime,
    this.endTime,
  });

  // Factory constructor to create a Parking from JSON
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'].toString(), // Convert to String
      fordon: json['fordon'] as String,
      parkingPlace: json['parkingPlace'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  // Convert a Parking to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fordon': fordon,
      'parkingPlace': parkingPlace,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}