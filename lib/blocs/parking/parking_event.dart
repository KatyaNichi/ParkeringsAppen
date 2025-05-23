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
class StartParking extends ParkingEvent {
  final String vehicleId;
  final String parkingPlaceId;
  final String startTime;

  const StartParking({
    required this.vehicleId,
    required this.parkingPlaceId,
    required this.startTime,
  });

  @override
  List<Object?> get props => [vehicleId, parkingPlaceId, startTime];
}

// Event to end a parking
class EndParking extends ParkingEvent {
  final int parkingId;
  final String endTime;

  const EndParking({
    required this.parkingId,
    required this.endTime,
  });

  @override
  List<Object?> get props => [parkingId, endTime];
}

// Event when parkings are loaded successfully
class ParkingsLoaded extends ParkingEvent {
  final List<Parking> parkings;

  const ParkingsLoaded(this.parkings);

  @override
  List<Object?> get props => [parkings];
}