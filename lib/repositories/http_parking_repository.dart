import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking.dart';

class HttpParkingRepository {
  final String baseUrl;
  
  HttpParkingRepository({required this.baseUrl});
  
  // Add a new parking
  Future<Parking> addParking(String fordon, String parkingPlace, String startTime, String? endTime) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/parkings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fordon': fordon,
          'parkingPlace': parkingPlace,
          'startTime': startTime,
          if (endTime != null) 'endTime': endTime,
        }),
      );
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Parking.fromJson(responseData['parking']);
      } else {
        throw Exception('Failed to create parking: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating parking: $e');
    }
  }
  
  // Get all parkings
  Future<List<Parking>> getAllParkings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/parkings'));
      
      if (response.statusCode == 200) {
        final List<dynamic> parkingsJson = jsonDecode(response.body);
        return parkingsJson.map((parkingJson) => Parking.fromJson(parkingJson)).toList();
      } else {
        throw Exception('Failed to load parkings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading parkings: $e');
    }
  }
  
  // Get active parkings (no end time)
  Future<List<Parking>> getActiveParkings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/parkings/active'));
      
      if (response.statusCode == 200) {
        final List<dynamic> parkingsJson = jsonDecode(response.body);
        return parkingsJson.map((parkingJson) => Parking.fromJson(parkingJson)).toList();
      } else {
        throw Exception('Failed to load active parkings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading active parkings: $e');
    }
  }
  
  // Get parkings by vehicle
  Future<List<Parking>> getParkingsByVehicle(String fordon) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/parkings/vehicle/$fordon'));
      
      if (response.statusCode == 200) {
        final List<dynamic> parkingsJson = jsonDecode(response.body);
        return parkingsJson.map((parkingJson) => Parking.fromJson(parkingJson)).toList();
      } else {
        throw Exception('Failed to load parkings for vehicle: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading parkings for vehicle: $e');
    }
  }
  
  // Get a parking by ID
  Future<Parking?> getParkingById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/parkings/$id'));
      
      if (response.statusCode == 200) {
        final parkingJson = jsonDecode(response.body);
        return Parking.fromJson(parkingJson);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load parking: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading parking: $e');
    }
  }
  
  // Update a parking
  Future<bool> updateParking(int id, {String? newFordon, String? newParkingPlace, String? newStartTime, String? newEndTime}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/parkings/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (newFordon != null) 'fordon': newFordon,
          if (newParkingPlace != null) 'parkingPlace': newParkingPlace,
          if (newStartTime != null) 'startTime': newStartTime,
          if (newEndTime != null) 'endTime': newEndTime,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating parking: $e');
    }
  }
  
  // End a parking (set end time)
  Future<bool> endParking(int id, String endTime) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/parkings/$id/end'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'endTime': endTime,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error ending parking: $e');
    }
  }
  
  // Remove a parking
  Future<bool> removeParking(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/parkings/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting parking: $e');
    }
  }
}