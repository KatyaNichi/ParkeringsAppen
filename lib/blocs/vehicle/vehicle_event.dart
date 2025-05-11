import 'package:equatable/equatable.dart';
import '../../models/vehicle.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

// Event to load all vehicles
class LoadVehicles extends VehicleEvent {}

// Event to load vehicles by owner ID
class LoadVehiclesByOwner extends VehicleEvent {
  final int ownerId;

  const LoadVehiclesByOwner(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

// Event to add a new vehicle
class AddVehicle extends VehicleEvent {
  final String type;
  final int registrationNumber;
  final int ownerId;

  const AddVehicle({
    required this.type,
    required this.registrationNumber,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [type, registrationNumber, ownerId];
}

// Event to delete a vehicle
class DeleteVehicle extends VehicleEvent {
  final int vehicleId;

  const DeleteVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

// Event to update a vehicle
class UpdateVehicle extends VehicleEvent {
  final int vehicleId;
  final String? newType;
  final int? newRegistrationNumber;

  const UpdateVehicle({
    required this.vehicleId,
    this.newType,
    this.newRegistrationNumber,
  });

  @override
  List<Object?> get props => [vehicleId, newType, newRegistrationNumber];
}