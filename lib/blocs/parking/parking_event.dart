// lib/blocs/parking/parking_event.dart
import 'package:equatable/equatable.dart';
import '../../models/parking.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

// Event to load all parkings
class LoadParkings extends ParkingEvent {}

// Event to load active parkings (those without end time)
class LoadActiveParkings extends ParkingEvent {}

// Event to start a new parking
// Event to start a new parking
class StartParking extends ParkingEvent {
  final String vehicleId;
  final String parkingPlaceId;
  final String startTime;
  final String? notificationId;          // ADD THIS LINE
  final int? estimatedDurationHours;     // ADD THIS LINE

  const StartParking({
    required this.vehicleId,
    required this.parkingPlaceId,
    required this.startTime,
    this.notificationId,                 // ADD THIS LINE
    this.estimatedDurationHours,         // ADD THIS LINE
  });

  @override
  List<Object?> get props => [vehicleId, parkingPlaceId, startTime, notificationId, estimatedDurationHours]; // UPDATE THIS LINE
}
// Event to end a parking
class EndParking extends ParkingEvent {
  final String parkingId;  // Changed from int to String
  final String endTime;

  const EndParking({
    required this.parkingId,
    required this.endTime,
  });

  @override
  List<Object?> get props => [parkingId, endTime];
}
class LoadParkingsByUser extends ParkingEvent {
  final String userId;

  const LoadParkingsByUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Event when parkings are loaded successfully
class ParkingsLoaded extends ParkingEvent {
  final List<Parking> parkings;

  const ParkingsLoaded(this.parkings);

  @override
  List<Object?> get props => [parkings];
}