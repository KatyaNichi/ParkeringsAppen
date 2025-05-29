// lib/blocs/parking_space/parking_space_bloc.dart
import 'package:bloc/bloc.dart';
import '../../repositories/firestore_parking_space_repository.dart';
import 'parking_space_event.dart';
import 'parking_space_state.dart';

class ParkingSpaceBloc extends Bloc<ParkingSpaceEvent, ParkingSpaceState> {
  final FirestoreParkingSpaceRepository parkingSpaceRepository;

  ParkingSpaceBloc({required this.parkingSpaceRepository}) : super(ParkingSpaceInitial()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<LoadParkingSpaceById>(_onLoadParkingSpaceById);
    on<AddParkingSpace>(_onAddParkingSpace);
    on<UpdateParkingSpace>(_onUpdateParkingSpace);
    on<DeleteParkingSpace>(_onDeleteParkingSpace);
    on<SearchParkingSpaces>(_onSearchParkingSpaces);
  }

  void _onLoadParkingSpaces(LoadParkingSpaces event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpaces = await parkingSpaceRepository.getAllParkingSpaces();
      emit(ParkingSpaceLoaded(parkingSpaces));
    } catch (e) {
      emit(ParkingSpaceError('Failed to load parking spaces: $e'));
    }
  }

  void _onLoadParkingSpaceById(LoadParkingSpaceById event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpace = await parkingSpaceRepository.getParkingSpaceById(event.id);
      if (parkingSpace != null) {
        emit(SingleParkingSpaceLoaded(parkingSpace));
      } else {
        emit(ParkingSpaceError('Parking space not found'));
      }
    } catch (e) {
      emit(ParkingSpaceError('Failed to load parking space: $e'));
    }
  }

  void _onAddParkingSpace(AddParkingSpace event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpace = await parkingSpaceRepository.addParkingSpace(
        event.adress, 
        event.pricePerHour
      );
      
      // If we previously had loaded parking spaces, add the new one
      if (state is ParkingSpaceLoaded) {
        final currentSpaces = (state as ParkingSpaceLoaded).parkingSpaces;
        emit(ParkingSpaceLoaded([...currentSpaces, parkingSpace], pendingChanges: true));
      } else {
        // Otherwise just emit success and reload
        emit(ParkingSpaceOperationSuccess(
          'Parking space added successfully', 
          parkingSpace: parkingSpace
        ));
        add(LoadParkingSpaces());
      }
    } catch (e) {
      emit(ParkingSpaceError('Failed to add parking space: $e'));
    }
  }

  void _onUpdateParkingSpace(UpdateParkingSpace event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final success = await parkingSpaceRepository.updateParkingSpace(
        event.id,
        newAdress: event.newAdress,
        newPricePerHour: event.newPricePerHour,
      );
      
      if (success) {
        emit(ParkingSpaceOperationSuccess('Parking space updated successfully'));
        add(LoadParkingSpaces()); // Reload to get updated parking spaces
      } else {
        emit(ParkingSpaceError('Failed to update parking space: Parking space not found'));
      }
    } catch (e) {
      emit(ParkingSpaceError('Failed to update parking space: $e'));
    }
  }

  void _onDeleteParkingSpace(DeleteParkingSpace event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final success = await parkingSpaceRepository.removeParkingSpace(event.id);
      
      if (success) {
        if (state is ParkingSpaceLoaded) {
          final currentSpaces = (state as ParkingSpaceLoaded).parkingSpaces;
          final updatedSpaces = currentSpaces.where((space) => space.id != event.id).toList();
          emit(ParkingSpaceLoaded(updatedSpaces, pendingChanges: true));
        } else {
          emit(const ParkingSpaceOperationSuccess('Parking space deleted successfully'));
          add(LoadParkingSpaces()); // Reload all parking spaces
        }
      } else {
        emit(const ParkingSpaceError('Failed to delete parking space: Parking space not found'));
      }
    } catch (e) {
      emit(ParkingSpaceError('Failed to delete parking space: $e'));
    }
  }

  void _onSearchParkingSpaces(SearchParkingSpaces event, Emitter<ParkingSpaceState> emit) async {
    emit(ParkingSpaceLoading());
    try {
      final parkingSpaces = await parkingSpaceRepository.searchParkingSpacesByAddress(event.query);
      emit(ParkingSpaceLoaded(parkingSpaces));
    } catch (e) {
      emit(ParkingSpaceError('Failed to search parking spaces: $e'));
    }
  }
}