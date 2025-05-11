import 'package:equatable/equatable.dart';
import '../../models/parking_space.dart';

abstract class ParkingSpaceEvent extends Equatable {
  const ParkingSpaceEvent();

  @override
  List<Object?> get props => [];
}

// Event to load all parking spaces
class LoadParkingSpaces extends ParkingSpaceEvent {}

// Event to load a specific parking space by ID
class LoadParkingSpaceById extends ParkingSpaceEvent {
  final int id;

  const LoadParkingSpaceById(this.id);

  @override
  List<Object?> get props => [id];
}

// Event to add a new parking space
class AddParkingSpace extends ParkingSpaceEvent {
  final String adress;
  final int pricePerHour;

  const AddParkingSpace({
    required this.adress,
    required this.pricePerHour,
  });

  @override
  List<Object?> get props => [adress, pricePerHour];
}

// Event to update a parking space
class UpdateParkingSpace extends ParkingSpaceEvent {
  final int id;
  final String? newAdress;
  final int? newPricePerHour;

  const UpdateParkingSpace({
    required this.id,
    this.newAdress,
    this.newPricePerHour,
  });

  @override
  List<Object?> get props => [id, newAdress, newPricePerHour];
}

// Event to delete a parking space
class DeleteParkingSpace extends ParkingSpaceEvent {
  final int id;

  const DeleteParkingSpace(this.id);

  @override
  List<Object?> get props => [id];
}