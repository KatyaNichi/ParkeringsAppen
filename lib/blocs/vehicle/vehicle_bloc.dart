import 'package:bloc/bloc.dart';
import '../../repositories/http_vehicle_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final HttpVehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<LoadVehiclesByOwner>(_onLoadVehiclesByOwner);
    on<AddVehicle>(_onAddVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
  }

  void _onLoadVehicles(LoadVehicles event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleRepository.getAllVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError('Failed to load vehicles: $e'));
    }
  }

  void _onLoadVehiclesByOwner(LoadVehiclesByOwner event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleRepository.getVehiclesByOwnerId(event.ownerId);
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError('Failed to load owner vehicles: $e'));
    }
  }

  void _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final vehicle = await vehicleRepository.addVehicle(
        event.type, 
        event.registrationNumber, 
        event.ownerId
      );
      
      // If the state was previously VehicleLoaded, add the new vehicle to the list
      if (state is VehicleLoaded) {
        final currentVehicles = (state as VehicleLoaded).vehicles;
        emit(VehicleLoaded([...currentVehicles, vehicle], pendingChanges: true));
      } else {
        // Otherwise, just emit success and reload vehicles afterward
        emit(VehicleOperationSuccess('Vehicle added successfully', vehicle: vehicle));
        final vehicles = await vehicleRepository.getVehiclesByOwnerId(event.ownerId);
        emit(VehicleLoaded(vehicles));
      }
    } catch (e) {
      emit(VehicleError('Failed to add vehicle: $e'));
    }
  }

  void _onDeleteVehicle(DeleteVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final success = await vehicleRepository.removeVehicle(event.vehicleId);
      
      if (success) {
        if (state is VehicleLoaded) {
          final currentVehicles = (state as VehicleLoaded).vehicles;
          final updatedVehicles = currentVehicles.where((v) => v.id != event.vehicleId).toList();
          emit(VehicleLoaded(updatedVehicles, pendingChanges: true));
        } else {
          emit(VehicleOperationSuccess('Vehicle deleted successfully'));
          add(LoadVehicles()); // Reload all vehicles
        }
      } else {
        emit(VehicleError('Failed to delete vehicle: Vehicle not found'));
      }
    } catch (e) {
      emit(VehicleError('Failed to delete vehicle: $e'));
    }
  }

  void _onUpdateVehicle(UpdateVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final success = await vehicleRepository.updateVehicle(
        event.vehicleId,
        newType: event.newType,
        newRegistrationNumber: event.newRegistrationNumber,
      );
      
      if (success) {
        emit(VehicleOperationSuccess('Vehicle updated successfully'));
        add(LoadVehicles()); // Reload all vehicles to get the updated one
      } else {
        emit(VehicleError('Failed to update vehicle: Vehicle not found'));
      }
    } catch (e) {
      emit(VehicleError('Failed to update vehicle: $e'));
    }
  }
}