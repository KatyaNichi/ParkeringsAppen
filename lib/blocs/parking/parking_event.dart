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

class LoadActiveParkingsStream extends ParkingEvent {
  const LoadActiveParkingsStream();
  
  @override
  List<Object?> get props => [];
  
  @override
  String toString() => 'LoadActiveParkingsStream()';
}

// Event to start a new parking
class StartParking extends ParkingEvent {
  final String vehicleId;
  final String parkingPlaceId;
  final String startTime;
  final String? notificationId;
  final int? estimatedDurationHours;

  const StartParking({
    required this.vehicleId,
    required this.parkingPlaceId,
    required this.startTime,
    this.notificationId,
    this.estimatedDurationHours,
  });

  @override
  List<Object?> get props => [vehicleId, parkingPlaceId, startTime, notificationId, estimatedDurationHours];
}

// Event to end a parking
class EndParking extends ParkingEvent {
  final String parkingId;
  final String endTime;

  const EndParking({
    required this.parkingId,
    required this.endTime,
  });

  @override
  List<Object?> get props => [parkingId, endTime];
}

// Event to load parkings by user
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