import 'package:equatable/equatable.dart';
import '../../models/parking.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class ParkingInitial extends ParkingState {}

// Loading state
class ParkingLoading extends ParkingState {}

// Loaded state - when data has been loaded successfully
class ParkingLoaded extends ParkingState {
  final List<Parking> parkings;
  final bool pendingChanges;

  const ParkingLoaded(this.parkings, {this.pendingChanges = false});

  @override
  List<Object?> get props => [parkings, pendingChanges];

  // Create a copy with updated properties
  ParkingLoaded copyWith({
    List<Parking>? parkings,
    bool? pendingChanges,
  }) {
    return ParkingLoaded(
      parkings ?? this.parkings,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }
}

// Active parkings loaded state
class ActiveParkingsLoaded extends ParkingState {
  final List<Parking> activeParkings;

  const ActiveParkingsLoaded(this.activeParkings);

  @override
  List<Object?> get props => [activeParkings];
}

// Operation success state
class ParkingOperationSuccess extends ParkingState {
  final String message;

  const ParkingOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Error state
class ParkingError extends ParkingState {
  final String message;

  const ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}