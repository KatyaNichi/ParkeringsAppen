import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import '../models/person.dart';

class HttpVehicleRepository {
  final String baseUrl;
  
  HttpVehicleRepository({required this.baseUrl});
  
  // Add a new vehicle
  Future<Vehicle> addVehicle(String type, int registrationNumber, int ownerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': type,
          'registrationNumber': registrationNumber,
          'ownerId': ownerId,
        }),
      );
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final vehicleData = responseData['vehicle'];
        
        // Create owner from the response
        final ownerData = vehicleData['owner'];
        final owner = Person.fromJson(ownerData);
        
        // Create vehicle using fromJson factory
        return Vehicle.fromJson(vehicleData, owner);
      } else {
        throw Exception('Failed to create vehicle: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating vehicle: $e');
    }
  }
  
  // Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/vehicles'));
      
      if (response.statusCode == 200) {
        final List<dynamic> vehiclesJson = jsonDecode(response.body);
        return vehiclesJson.map((vehicleJson) {
          final owner = Person.fromJson(vehicleJson['owner']);
          return Vehicle.fromJson(vehicleJson, owner);
        }).toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading vehicles: $e');
    }
  }
  
  // Get vehicles by owner ID
  Future<List<Vehicle>> getVehiclesByOwnerId(int ownerId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/vehicles/owner/$ownerId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> vehiclesJson = jsonDecode(response.body);
        return vehiclesJson.map((vehicleJson) {
          final owner = Person.fromJson(vehicleJson['owner']);
          return Vehicle.fromJson(vehicleJson, owner);
        }).toList();
      } else {
        throw Exception('Failed to load vehicles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading vehicles: $e');
    }
  }
  
  // Get a vehicle by ID
  Future<Vehicle?> getVehicleById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/vehicles/$id'));
      
      if (response.statusCode == 200) {
        final vehicleJson = jsonDecode(response.body);
        final owner = Person.fromJson(vehicleJson['owner']);
        return Vehicle.fromJson(vehicleJson, owner);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load vehicle: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading vehicle: $e');
    }
  }
  
  // Update a vehicle
  Future<bool> updateVehicle(int id, {String? newType, int? newRegistrationNumber}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/vehicles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (newType != null) 'type': newType,
          if (newRegistrationNumber != null) 'registrationNumber': newRegistrationNumber,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating vehicle: $e');
    }
  }
  
  // Remove a vehicle
  Future<bool> removeVehicle(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/vehicles/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting vehicle: $e');
    }
  }
}