import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking_space.dart';

class HttpParkingSpaceRepository {
  final String baseUrl;
  
  HttpParkingSpaceRepository({required this.baseUrl});
  
  // Add a new parking space
  Future<ParkingSpace> addParkingSpace(String adress, int pricePerHour) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/parkingSpaces'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'adress': adress,
          'pricePerHour': pricePerHour,
        }),
      );
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return ParkingSpace.fromJson(responseData['parkingSpace']);
      } else {
        throw Exception('Failed to create parking space: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating parking space: $e');
    }
  }
  
  // Get all parking spaces
  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/parkingSpaces'));
      
      if (response.statusCode == 200) {
        final List<dynamic> spacesJson = jsonDecode(response.body);
        return spacesJson.map((spaceJson) => ParkingSpace.fromJson(spaceJson)).toList();
      } else {
        throw Exception('Failed to load parking spaces: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading parking spaces: $e');
    }
  }
  
  // Get a parking space by ID
  Future<ParkingSpace?> getParkingSpaceById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/parkingSpaces/$id'));
      
      if (response.statusCode == 200) {
        final spaceJson = jsonDecode(response.body);
        return ParkingSpace.fromJson(spaceJson);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load parking space: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading parking space: $e');
    }
  }
  
  // Update a parking space
  Future<bool> updateParkingSpace(int id, {String? newAdress, int? newPricePerHour}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/parkingSpaces/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (newAdress != null) 'adress': newAdress,
          if (newPricePerHour != null) 'pricePerHour': newPricePerHour,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating parking space: $e');
    }
  }
  
  // Remove a parking space
  Future<bool> removeParkingSpace(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/parkingSpaces/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting parking space: $e');
    }
  }
}