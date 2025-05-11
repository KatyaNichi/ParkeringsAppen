import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_event.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_state.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import '../mocks/mock_parking_space_repository.dart';

void main() {
  group('ParkingSpaceBloc', () {
    late MockParkingSpaceRepository mockParkingSpaceRepository;
    late ParkingSpaceBloc parkingSpaceBloc;

    setUp(() {
      mockParkingSpaceRepository = MockParkingSpaceRepository();
      parkingSpaceBloc = ParkingSpaceBloc(parkingSpaceRepository: mockParkingSpaceRepository);
    });

    tearDown(() {
      parkingSpaceBloc.close();
    });

    test('initial state is ParkingSpaceInitial', () {
      expect(parkingSpaceBloc.state, isA<ParkingSpaceInitial>());
    });

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceLoaded] when LoadParkingSpaces is added',
      build: () => parkingSpaceBloc,
      act: (bloc) => bloc.add(LoadParkingSpaces()),
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpaceLoaded>(),
      ],
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceOperationSuccess, ParkingSpaceLoaded] when AddParkingSpace is added',
      build: () => parkingSpaceBloc,
      act: (bloc) => bloc.add(const AddParkingSpace(
        adress: 'Test Address',
        pricePerHour: 100,
      )),
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpaceOperationSuccess>(),
        isA<ParkingSpaceLoaded>(),
      ],
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, SingleParkingSpaceLoaded] when LoadParkingSpaceById is added for existing space',
      build: () => parkingSpaceBloc,
      act: (bloc) async {
        // Add a parking space first then load it by ID
        await mockParkingSpaceRepository.addParkingSpace('Test Address', 100);
        bloc.add(const LoadParkingSpaceById(1));
      },
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<SingleParkingSpaceLoaded>(),
      ],
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceOperationSuccess, ParkingSpaceLoaded] when UpdateParkingSpace is added',
      build: () => parkingSpaceBloc,
      act: (bloc) async {
        // Add a parking space first to update it later
        await mockParkingSpaceRepository.addParkingSpace('Test Address', 100);
        bloc.add(const UpdateParkingSpace(
          id: 1,
          newAdress: 'Updated Address',
          newPricePerHour: 150,
        ));
      },
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpaceOperationSuccess>(),
        isA<ParkingSpaceLoaded>(),
      ],
    );

    blocTest<ParkingSpaceBloc, ParkingSpaceState>(
      'emits [ParkingSpaceLoading, ParkingSpaceOperationSuccess, ParkingSpaceLoaded] when DeleteParkingSpace is added',
      build: () => parkingSpaceBloc,
      act: (bloc) async {
        // Add a parking space first to delete it later
        await mockParkingSpaceRepository.addParkingSpace('Test Address', 100);
        bloc.add(const DeleteParkingSpace(1));
      },
      expect: () => [
        isA<ParkingSpaceLoading>(),
        isA<ParkingSpaceOperationSuccess>(),
        isA<ParkingSpaceLoaded>(),
      ],
    );
  });
}