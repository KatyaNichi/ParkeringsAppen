import 'package:equatable/equatable.dart';
import '../../models/parking_space.dart';

abstract class ParkingSpaceState extends Equatable {
  const ParkingSpaceState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class ParkingSpaceInitial extends ParkingSpaceState {}

// Loading state
class ParkingSpaceLoading extends ParkingSpaceState {}

// Loaded state - when parking spaces have been loaded
class ParkingSpaceLoaded extends ParkingSpaceState {
  final List<ParkingSpace> parkingSpaces;
  final bool pendingChanges;

  const ParkingSpaceLoaded(this.parkingSpaces, {this.pendingChanges = false});

  @override
  List<Object?> get props => [parkingSpaces, pendingChanges];

  // Create a copy with updated properties
  ParkingSpaceLoaded copyWith({
    List<ParkingSpace>? parkingSpaces,
    bool? pendingChanges,
  }) {
    return ParkingSpaceLoaded(
      parkingSpaces ?? this.parkingSpaces,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }
}

// Single parking space loaded
class SingleParkingSpaceLoaded extends ParkingSpaceState {
  final ParkingSpace parkingSpace;

  const SingleParkingSpaceLoaded(this.parkingSpace);

  @override
  List<Object?> get props => [parkingSpace];
}

// Operation success state
class ParkingSpaceOperationSuccess extends ParkingSpaceState {
  final String message;
  final ParkingSpace? parkingSpace;

  const ParkingSpaceOperationSuccess(this.message, {this.parkingSpace});

  @override
  List<Object?> get props => [message, parkingSpace];
}

// Error state
class ParkingSpaceError extends ParkingSpaceState {
  final String message;

  const ParkingSpaceError(this.message);

  @override
  List<Object?> get props => [message];
}