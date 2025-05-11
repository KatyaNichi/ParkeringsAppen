import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/models/vehicle.dart';
import 'package:parking_app_flutter/repositories/http_vehicle_repository.dart';

class MockVehicleRepository implements HttpVehicleRepository {
  final List<Vehicle> _vehicles = [];
  int _nextId = 1;
  
  @override
  String get baseUrl => 'mock://localhost';
  
  // Add a vehicle
  @override
  Future<Vehicle> addVehicle(String type, int registrationNumber, int ownerId) async {
    // Create a mock owner
    final owner = Person(id: ownerId, name: 'Mock Owner', personnummer: 12345);
    
    final vehicle = Vehicle(
      id: _nextId++,
      type: type,
      registrationNumber: registrationNumber,
      owner: owner,
    );
    
    _vehicles.add(vehicle);
    return vehicle;
  }
  
  // Get all vehicles
  @override
  Future<List<Vehicle>> getAllVehicles() async {
    return List.from(_vehicles);
  }
  
  // Get a vehicle by ID
  @override
  Future<Vehicle?> getVehicleById(int id) async {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get vehicles by owner ID
  @override
  Future<List<Vehicle>> getVehiclesByOwnerId(int ownerId) async {
    return _vehicles.where((v) => v.owner.id == ownerId).toList();
  }
  
  // Remove a vehicle
  @override
  Future<bool> removeVehicle(int id) async {
    final initialLength = _vehicles.length;
    _vehicles.removeWhere((v) => v.id == id);
    return _vehicles.length < initialLength;
  }
  
  // Update a vehicle
  @override
  Future<bool> updateVehicle(int id, {String? newType, int? newRegistrationNumber}) async {
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index == -1) return false;
    
    final vehicle = _vehicles[index];
    _vehicles[index] = Vehicle(
      id: vehicle.id,
      type: newType ?? vehicle.type,
      registrationNumber: newRegistrationNumber ?? vehicle.registrationNumber,
      owner: vehicle.owner,
    );
    
    return true;
  }
}