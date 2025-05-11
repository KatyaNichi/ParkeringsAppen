import 'package:equatable/equatable.dart';
import '../../models/vehicle.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class VehicleInitial extends VehicleState {}

// Loading state
class VehicleLoading extends VehicleState {}

// Loaded state - when vehicles have been loaded
class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  final bool pendingChanges;

  const VehicleLoaded(this.vehicles, {this.pendingChanges = false});

  @override
  List<Object?> get props => [vehicles, pendingChanges];

  // Create a copy with updated properties
  VehicleLoaded copyWith({
    List<Vehicle>? vehicles,
    bool? pendingChanges,
  }) {
    return VehicleLoaded(
      vehicles ?? this.vehicles,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }
}

// Operation success state
class VehicleOperationSuccess extends VehicleState {
  final String message;
  final Vehicle? vehicle;

  const VehicleOperationSuccess(this.message, {this.vehicle});

  @override
  List<Object?> get props => [message, vehicle];
}

// Error state
class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}