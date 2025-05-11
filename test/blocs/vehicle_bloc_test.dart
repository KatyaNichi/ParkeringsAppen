import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_event.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_state.dart';
import 'package:parking_app_flutter/models/vehicle.dart';
import '../mocks/mock_vehicle_repository.dart';

void main() {
  group('VehicleBloc', () {
    late MockVehicleRepository mockVehicleRepository;
    late VehicleBloc vehicleBloc;

    setUp(() {
      mockVehicleRepository = MockVehicleRepository();
      vehicleBloc = VehicleBloc(vehicleRepository: mockVehicleRepository);
    });

    tearDown(() {
      vehicleBloc.close();
    });

    test('initial state is VehicleInitial', () {
      expect(vehicleBloc.state, isA<VehicleInitial>());
    });

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleLoaded] when LoadVehicles is added',
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleLoaded>(),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleLoaded] when LoadVehiclesByOwner is added',
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(const LoadVehiclesByOwner(1)),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleLoaded>(),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleOperationSuccess, VehicleLoaded] when AddVehicle is added',
      build: () => vehicleBloc,
      act: (bloc) => bloc.add(const AddVehicle(
        type: 'Test Car',
        registrationNumber: 12345,
        ownerId: 1,
      )),
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleOperationSuccess>(),
        isA<VehicleLoaded>(),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleOperationSuccess, VehicleLoaded] when DeleteVehicle is added',
      build: () => vehicleBloc,
      act: (bloc) async {
        // Add a vehicle first to delete it later
        await mockVehicleRepository.addVehicle('Test Car', 12345, 1);
        bloc.add(const DeleteVehicle(1));
      },
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleOperationSuccess>(),
        isA<VehicleLoaded>(),
      ],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleOperationSuccess, VehicleLoaded] when UpdateVehicle is added',
      build: () => vehicleBloc,
      act: (bloc) async {
        // Add a vehicle first to update it later
        await mockVehicleRepository.addVehicle('Test Car', 12345, 1);
        bloc.add(const UpdateVehicle(
          vehicleId: 1,
          newType: 'Updated Car',
        ));
      },
      expect: () => [
        isA<VehicleLoading>(),
        isA<VehicleOperationSuccess>(),
        isA<VehicleLoaded>(),
      ],
    );
  });
}