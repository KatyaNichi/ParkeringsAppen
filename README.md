# ParkeringsAppen - BLoC Implementation

## Overview
This project is a Flutter application for managing parking spaces, vehicles, and active parkings. It demonstrates the implementation of the BLoC (Business Logic Component) pattern for state management.

## Project Structure

The project follows a clean architecture approach with the following structure:

```
lib/
  ├── blocs/           # Business Logic Components 
  │   ├── auth/        # Authentication BLoC
  │   ├── parking/     # Parking BLoC
  │   ├── parking_space/ # Parking Space BLoC
  │   └── vehicle/     # Vehicle BLoC
  ├── models/          # Data models
  ├── repositories/    # HTTP repositories for API communication
  ├── screens/         # UI screens
  ├── services/        # Global services like UserService
  └── main.dart        # Entry point
```

## BLoC Implementation

The BLoC pattern is implemented using the following components:

### 1. Events
Events represent user actions or app events that change the state. They are implemented as Dart classes extending a base Event class.

Example from `vehicle_event.dart`:
```dart
abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {}

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
```

### 2. States
States represent the current condition of the application. They are immutable and can include data needed for the UI.

Example from `vehicle_state.dart`:
```dart
abstract class VehicleState extends Equatable {
  const VehicleState();
  
  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  final bool pendingChanges;

  const VehicleLoaded(this.vehicles, {this.pendingChanges = false});

  @override
  List<Object?> get props => [vehicles, pendingChanges];
}
```

### 3. BLoCs
BLoCs (Business Logic Components) handle the logic to transform Events into States.

Example from `vehicle_bloc.dart`:
```dart
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final HttpVehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    // More event handlers...
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
  
  // More methods...
}
```

## UI Integration with BLoC

The UI components use `BlocBuilder`, `BlocListener`, and other widgets from the `flutter_bloc` package to integrate with the BLoC pattern.

Example from `vehicles_screen.dart`:
```dart
BlocConsumer<VehicleBloc, VehicleState>(
  listener: (context, state) {
    if (state is VehicleOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    if (state is VehicleLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is VehicleLoaded) {
      // UI for vehicles
    }
    // More states...
  },
)
```

## Testing

The project includes tests for the BLoC components using the `bloc_test` package. Mock repositories are used to isolate the BLoC components during testing.

Example from `vehicle_bloc_test.dart`:
```dart
blocTest<VehicleBloc, VehicleState>(
  'emits [VehicleLoading, VehicleLoaded] when LoadVehicles is added',
  build: () => vehicleBloc,
  act: (bloc) => bloc.add(LoadVehicles()),
  expect: () => [
    isA<VehicleLoading>(),
    isA<VehicleLoaded>(),
  ],
)
```

### Mock Repositories

Mock repositories implement the same interface as the real repositories but use in-memory data for testing. They simulate server responses without making actual network calls.

Example from `mock_vehicle_repository.dart`:
```dart
class MockVehicleRepository implements HttpVehicleRepository {
  final List<Vehicle> _vehicles = [];
  int _nextId = 1;
  
  @override
  String get baseUrl => 'mock://localhost';
  
  @override
  Future<Vehicle> addVehicle(String type, int registrationNumber, int ownerId) async {
    // Create mock vehicle and add to in-memory list
    final vehicle = Vehicle(
      id: _nextId++,
      type: type,
      registrationNumber: registrationNumber,
      owner: Person(id: ownerId, name: 'Mock Owner', personnummer: 12345),
    );
    
    _vehicles.add(vehicle);
    return vehicle;
  }
  
  // More methods...
}
```

## Benefits of BLoC Pattern

1. **Separation of Concerns**: Business logic is separated from the UI, making the code more modular and easier to test.

2. **Testability**: Each component can be tested in isolation, improving test coverage and reliability.

3. **Reusability**: BLoCs can be reused across different screens or features.

4. **Predictable State Management**: The unidirectional data flow makes state changes predictable and easier to debug.

5. **Reactive Programming**: The BLoC pattern leverages reactive programming concepts, making it easier to handle asynchronous operations.

## Error Handling

Error handling is implemented consistently across all BLoCs using the error states. When an error occurs, the BLoC emits an error state with a message, and the UI can respond appropriately.

Example from UI:
```dart
if (state is VehicleError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(state.message),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Dependencies

The project uses the following dependencies for implementing the BLoC pattern:

- **flutter_bloc**: Provides the BLoC widgets for UI integration.
- **bloc**: Core package for the BLoC architecture.
- **equatable**: Makes state and event comparison more efficient.
- **bloc_test**: Facilitates testing of BLoCs.
- **mockito**: Used for creating mock objects in tests.

## Implementation Notes

1. **State Management**: Each feature (auth, vehicle, parking, parking space) has its own BLoC to handle specific business logic.

2. **UI Feedback**: Loading indicators and error messages are consistently implemented across the app.

3. **Optimistic Updates**: Some operations update the UI optimistically before the server confirms the change, indicated by the `pendingChanges` flag in states.

4. **Loading Indicators**: BLoC states include loading states to show progress indicators during asynchronous operations.

## Future Improvements

1. **State Persistence**: Save and restore BLoC states when the app is closed and reopened.

2. **Advanced Error Handling**: Implement more granular error states for different error scenarios.

3. **Pagination**: Add support for pagination in list views when dealing with large datasets.

4. **Hydrated BLoC**: Implement hydrated BLoC for automatic state persistence.

5. **Performance Optimizations**: Further optimize UI rebuilds using selective builders.

## How to Run Tests

```bash
flutter test test/blocs
```

This will run all the BLoC tests and verify that the business logic is functioning as expected.

## Credits

This project was developed as part of Uppgift 4: BLoC och Testing, to demonstrate the implementation of BLoC pattern for state management in Flutter applications.