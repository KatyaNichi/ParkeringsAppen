import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:parking_app_flutter/blocs/parking/parking_bloc.dart';
import 'package:parking_app_flutter/blocs/parking/parking_event.dart';
import 'package:parking_app_flutter/blocs/parking/parking_state.dart';
import 'package:parking_app_flutter/models/parking.dart';
import '../mocks/mock_parking_repository.dart';

void main() {
  group('ParkingBloc', () {
    late MockParkingRepository mockParkingRepository;
    late ParkingBloc parkingBloc;

    setUp(() {
      mockParkingRepository = MockParkingRepository();
      parkingBloc = ParkingBloc(parkingRepository: mockParkingRepository);
    });

    tearDown(() {
      parkingBloc.close();
    });

    test('initial state is ParkingInitial', () {
      expect(parkingBloc.state, isA<ParkingInitial>());
    });

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ParkingLoaded] when LoadParkings is added',
      build: () => parkingBloc,
      act: (bloc) => bloc.add(LoadParkings()),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingLoaded>(),
      ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ActiveParkingsLoaded] when LoadActiveParkings is added',
      build: () => parkingBloc,
      act: (bloc) => bloc.add(LoadActiveParkings()),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ActiveParkingsLoaded>(),
      ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ParkingOperationSuccess, ActiveParkingsLoaded] when StartParking is added',
      build: () => parkingBloc,
      act: (bloc) => bloc.add(const StartParking(
        vehicleId: '1',
        parkingPlaceId: '1',
        startTime: '10:00',
      )),
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingOperationSuccess>(),
        isA<ActiveParkingsLoaded>(),
      ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits [ParkingLoading, ParkingOperationSuccess, ActiveParkingsLoaded] when EndParking is added',
      build: () => parkingBloc,
      act: (bloc) async {
        // Add active parking first
        await mockParkingRepository.addParking('1', '1', '10:00', null);
        bloc.add(EndParking(
          parkingId: 1,
          endTime: '11:00',
        ));
      },
      expect: () => [
        isA<ParkingLoading>(),
        isA<ParkingOperationSuccess>(),
        isA<ActiveParkingsLoaded>(),
      ],
    );
  });
}