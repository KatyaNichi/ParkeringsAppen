import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/repositories/http_parking_space_repository.dart';

class MockParkingSpaceRepository implements HttpParkingSpaceRepository {
  final List<ParkingSpace> _parkingSpaces = [];
  int _nextId = 1;
  
  @override
  String get baseUrl => 'mock://localhost';
  
  // Add a parking space
  @override
  Future<ParkingSpace> addParkingSpace(String adress, int pricePerHour) async {
    final parkingSpace = ParkingSpace(
      id: _nextId++,
      adress: adress,
      pricePerHour: pricePerHour,
    );
    
    _parkingSpaces.add(parkingSpace);
    return parkingSpace;
  }
  
  // Get all parking spaces
  @override
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    return List.from(_parkingSpaces);
  }
  
  // Get a parking space by ID
  @override
  Future<ParkingSpace?> getParkingSpaceById(int id) async {
    try {
      return _parkingSpaces.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Remove a parking space
  @override
  Future<bool> removeParkingSpace(int id) async {
    final initialLength = _parkingSpaces.length;
    _parkingSpaces.removeWhere((p) => p.id == id);
    return _parkingSpaces.length < initialLength;
  }
  
  // Update a parking space
  @override
  Future<bool> updateParkingSpace(int id, {String? newAdress, int? newPricePerHour}) async {
    final index = _parkingSpaces.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    
    final parkingSpace = _parkingSpaces[index];
    _parkingSpaces[index] = ParkingSpace(
      id: parkingSpace.id,
      adress: newAdress ?? parkingSpace.adress,
      pricePerHour: newPricePerHour ?? parkingSpace.pricePerHour,
    );
    
    return true;
  }
}