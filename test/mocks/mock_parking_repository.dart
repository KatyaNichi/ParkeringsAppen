import 'package:parking_app_flutter/models/parking.dart';
import 'package:parking_app_flutter/repositories/http_parking_repository.dart';

class MockParkingRepository implements HttpParkingRepository {
  final List<Parking> _parkings = [];
  int _nextId = 1;
  
  @override
  String get baseUrl => 'mock://localhost';
  
  // Add a parking
  @override
  Future<Parking> addParking(String fordon, String parkingPlace, String startTime, String? endTime) async {
    final parking = Parking(
      id: _nextId++,
      fordon: fordon,
      parkingPlace: parkingPlace,
      startTime: startTime,
      endTime: endTime,
    );
    
    _parkings.add(parking);
    return parking;
  }
  
  // Get all parkings
  @override
  Future<List<Parking>> getAllParkings() async {
    return List.from(_parkings);
  }
  
  // Get active parkings (no end time)
  @override
  Future<List<Parking>> getActiveParkings() async {
    return _parkings.where((p) => p.endTime == null).toList();
  }
  
  // Get a parking by ID
  @override
  Future<Parking?> getParkingById(int id) async {
    try {
      return _parkings.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get parkings by vehicle
  @override
  Future<List<Parking>> getParkingsByVehicle(String fordon) async {
    return _parkings.where((p) => p.fordon == fordon).toList();
  }
  
  // End a parking (set end time)
  @override
  Future<bool> endParking(int id, String endTime) async {
    final index = _parkings.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    
    final parking = _parkings[index];
    _parkings[index] = Parking(
      id: parking.id,
      fordon: parking.fordon,
      parkingPlace: parking.parkingPlace,
      startTime: parking.startTime,
      endTime: endTime,
    );
    
    return true;
  }
  
  // Remove a parking
  @override
  Future<bool> removeParking(int id) async {
    final initialLength = _parkings.length;
    _parkings.removeWhere((p) => p.id == id);
    return _parkings.length < initialLength;
  }
  
  // Update a parking
  @override
  Future<bool> updateParking(int id, {String? newFordon, String? newParkingPlace, String? newStartTime, String? newEndTime}) async {
    final index = _parkings.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    
    final parking = _parkings[index];
    _parkings[index] = Parking(
      id: parking.id,
      fordon: newFordon ?? parking.fordon,
      parkingPlace: newParkingPlace ?? parking.parkingPlace,
      startTime: newStartTime ?? parking.startTime,
      endTime: newEndTime ?? parking.endTime,
    );
    
    return true;
  }
  
  // Get parkings by parking place
  @override
  Future<List<Parking>> getParkingsByPlace(String parkingPlace) async {
    return _parkings.where((p) => p.parkingPlace == parkingPlace).toList();
  }
}