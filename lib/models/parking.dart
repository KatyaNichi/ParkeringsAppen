// lib/models/parking.dart (Updated version)
class Parking {
  final String id;
  final String fordon;
  final String parkingPlace;
  final String? startTime;
  final String? endTime;
  final String? notificationId; // New field for tracking notification
  final int? estimatedDurationHours; // New field for duration estimation

  Parking({
    required this.id,
    required this.fordon,
    required this.parkingPlace,
    this.startTime,
    this.endTime,
    this.notificationId,
    this.estimatedDurationHours,
  });

  // Factory constructor to create a Parking from JSON
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'].toString(),
      fordon: json['fordon'] as String,
      parkingPlace: json['parkingPlace'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      notificationId: json['notificationId'] as String?,
      estimatedDurationHours: json['estimatedDurationHours'] as int?,
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
      if (notificationId != null) 'notificationId': notificationId,
      if (estimatedDurationHours != null) 'estimatedDurationHours': estimatedDurationHours,
    };
  }

  // Create a copy with updated fields
  Parking copyWith({
    String? id,
    String? fordon,
    String? parkingPlace,
    String? startTime,
    String? endTime,
    String? notificationId,
    int? estimatedDurationHours,
  }) {
    return Parking(
      id: id ?? this.id,
      fordon: fordon ?? this.fordon,
      parkingPlace: parkingPlace ?? this.parkingPlace,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notificationId: notificationId ?? this.notificationId,
      estimatedDurationHours: estimatedDurationHours ?? this.estimatedDurationHours,
    );
  }

  // Helper method to check if parking is active
  bool get isActive => endTime == null;

  // Helper method to get estimated end time
  DateTime? get estimatedEndTime {
    if (startTime == null || estimatedDurationHours == null) return null;
    
    try {
      final parts = startTime!.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, hour, minute);
      
      return start.add(Duration(hours: estimatedDurationHours!));
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Parking(id: $id, fordon: $fordon, parkingPlace: $parkingPlace, '
           'startTime: $startTime, endTime: $endTime, '
           'notificationId: $notificationId, estimatedDurationHours: $estimatedDurationHours)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Parking &&
        other.id == id &&
        other.fordon == fordon &&
        other.parkingPlace == parkingPlace &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.notificationId == notificationId &&
        other.estimatedDurationHours == estimatedDurationHours;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fordon.hashCode ^
        parkingPlace.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        notificationId.hashCode ^
        estimatedDurationHours.hashCode;
  }
}