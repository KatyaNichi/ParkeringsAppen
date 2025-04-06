import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  
  ApiService({required this.baseUrl});
  
  // Check if the server is running
  Future<bool> pingServer() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ping'));
      return response.statusCode == 200 && response.body == 'pong';
    } catch (e) {
      print('Error pinging server: $e');
      return false;
    }
  }
  
  // Generic GET method for lists
  Future<List<dynamic>> getList(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data from $endpoint');
    }
  }
  
  // Generic GET method for single item
  Future<Map<String, dynamic>> getItem(String endpoint, int id) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint/$id'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Item not found');
    } else {
      throw Exception('Failed to load item from $endpoint/$id');
    }
  }
  
  // Generic POST method
  Future<Map<String, dynamic>> createItem(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create item: ${response.body}');
    }
  }
  
  // Generic PUT method
  Future<bool> updateItem(String endpoint, int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    return response.statusCode == 200;
  }
  
  // Basic HTTP methods for direct use
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) {
    return http.post(url, headers: headers, body: body);
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) {
    return http.put(url, headers: headers, body: body);
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) {
    return http.delete(url, headers: headers);
  }
  
  // Generic DELETE method
  Future<bool> deleteItem(String endpoint, int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint/$id'));
    return response.statusCode == 200;
  }
}