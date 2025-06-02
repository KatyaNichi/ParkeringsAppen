// lib/blocs/parking/parking_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:parking_app_flutter/models/parking.dart';
import '../../repositories/firestore_parking_repository.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final FirestoreParkingRepository parkingRepository;

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    on<LoadParkings>(_onLoadParkings);
    on<LoadActiveParkings>(_onLoadActiveParkings);
    on<LoadActiveParkingsStream>(_onLoadActiveParkingsStream); // ADD THIS LINE
    on<StartParking>(_onStartParking);
    on<EndParking>(_onEndParking);
    on<LoadParkingsByUser>(_onLoadParkingsByUser);
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

  // ADD THIS METHOD - it was missing!
  void _onLoadActiveParkings(LoadActiveParkings event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final activeParkings = await parkingRepository.getActiveParkings();
      emit(ActiveParkingsLoaded(activeParkings));
    } catch (e) {
      emit(ParkingError('Failed to load active parkings: $e'));
    }
  }

  // NEW STREAM METHOD for real-time updates
  void _onLoadActiveParkingsStream(LoadActiveParkingsStream event, Emitter<ParkingState> emit) async {
    await emit.forEach<List<Parking>>(
      parkingRepository.getActiveParkingsStream(),
      onData: (parkings) => ActiveParkingsLoaded(parkings),
      onError: (error, stackTrace) => ParkingError('Real-time loading failed: $error'),
    );
  }

  void _onStartParking(StartParking event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      await parkingRepository.addParking(
        event.vehicleId, 
        event.parkingPlaceId, 
        event.startTime, 
        null, // endTime is null for new parkings
        notificationId: event.notificationId,
        estimatedDurationHours: event.estimatedDurationHours,
      );
      
      emit(const ParkingOperationSuccess('Parking started successfully'));
      // Don't manually reload - the stream will automatically update!
    } catch (e) {
      emit(ParkingError('Failed to start parking: $e'));
    }
  }

  void _onLoadParkingsByUser(LoadParkingsByUser event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());
    try {
      final parkings = await parkingRepository.getParkingsByUser(event.userId);
      emit(ParkingLoaded(parkings));
    } catch (e) {
      emit(ParkingError('Failed to load user parkings: $e'));
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
        emit(const ParkingOperationSuccess('Parking ended successfully'));
        // Don't manually reload - the stream will automatically update!
      } else {
        emit(const ParkingError('Failed to end parking: Parking not found'));
      }
    } catch (e) {
      emit(ParkingError('Failed to end parking: $e'));
    }
  }
}