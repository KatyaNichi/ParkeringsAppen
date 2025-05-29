// lib/blocs/parking/parking_bloc.dart
import 'package:bloc/bloc.dart';
import '../../repositories/firestore_parking_repository.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final FirestoreParkingRepository parkingRepository;

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    on<LoadParkings>(_onLoadParkings);
    on<LoadActiveParkings>(_onLoadActiveParkings);
    on<StartParking>(_onStartParking);
    on<EndParking>(_onEndParking);
  }

  void _onLoadParkings(LoadParkings event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parkings = await parkingRepository.getAllParkings();
      emit(ParkingLoaded(parkings));
    } catch (e) {
      emit(ParkingError('Failed to load parkings: $e'));
    }
  }

  void _onLoadActiveParkings(LoadActiveParkings event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final activeParkings = await parkingRepository.getActiveParkings();
      emit(ActiveParkingsLoaded(activeParkings));
    } catch (e) {
      emit(ParkingError('Failed to load active parkings: $e'));
    }
  }

  void _onStartParking(StartParking event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      await parkingRepository.addParking(
        event.vehicleId, 
        event.parkingPlaceId, 
        event.startTime, 
        null
      );
      
      // Load all active parkings after starting a new one
      final activeParkings = await parkingRepository.getActiveParkings();
      emit(const ParkingOperationSuccess('Parking started successfully'));
      emit(ActiveParkingsLoaded(activeParkings));
    } catch (e) {
      emit(ParkingError('Failed to start parking: $e'));
    }
  }

  void _onEndParking(EndParking event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final success = await parkingRepository.endParking(
        event.parkingId, 
        event.endTime
      );
      
      if (success) {
        // Reload active parkings after ending one
        final activeParkings = await parkingRepository.getActiveParkings();
        emit(const ParkingOperationSuccess('Parking ended successfully'));
        emit(ActiveParkingsLoaded(activeParkings));
      } else {
        emit(const ParkingError('Failed to end parking: Parking not found'));
      }
    } catch (e) {
      emit(ParkingError('Failed to end parking: $e'));
    }
  }
}