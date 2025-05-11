import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person.dart';

class HttpPersonRepository {
  final String baseUrl;
  
  HttpPersonRepository({required this.baseUrl});
  
  // Add a person
  Future<Person> addPerson(String name, int personnummer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/persons'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'personnummer': personnummer,
        }),
      );
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Person.fromJson(responseData['person']);
      } else {
        throw Exception('Failed to create person: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating person: $e');
    }
  }
  
  // Get all persons
  Future<List<Person>> getAllPersons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/persons'));
      
      if (response.statusCode == 200) {
        final List<dynamic> personsJson = jsonDecode(response.body);
        return personsJson.map((personJson) => Person.fromJson(personJson)).toList();
      } else {
        throw Exception('Failed to load persons: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading persons: $e');
    }
  }
  
  // Get a person by ID
  Future<Person?> getPersonById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/persons/$id'));
      
      if (response.statusCode == 200) {
        final personJson = jsonDecode(response.body);
        return Person.fromJson(personJson);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load person: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading person: $e');
    }
  }
  
  // Update a person
  Future<bool> updatePerson(int id, {String? newName, int? newPersonnummer}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/persons/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (newName != null) 'name': newName,
          if (newPersonnummer != null) 'personnummer': newPersonnummer,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating person: $e');
    }
  }
  
  // Remove a person
  Future<bool> removePerson(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/persons/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting person: $e');
    }
  }
}