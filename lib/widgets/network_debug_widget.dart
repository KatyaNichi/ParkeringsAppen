// Create this as lib/widgets/network_debug_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class NetworkDebugWidget extends StatefulWidget {
  const NetworkDebugWidget({Key? key}) : super(key: key);

  @override
  _NetworkDebugWidgetState createState() => _NetworkDebugWidgetState();
}

class _NetworkDebugWidgetState extends State<NetworkDebugWidget> {
  String _results = '';
  bool _testing = false;

  List<String> get _testUrls => [
    'http://192.168.88.24:8080',
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://10.0.2.2:8080', // Android emulator
  ];

  Future<void> _runNetworkTests() async {
    setState(() {
      _testing = true;
      _results = 'Starting network tests...\n\n';
    });

    // Test basic connectivity
    for (String baseUrl in _testUrls) {
      await _testUrl('$baseUrl/ping', 'Ping Test');
      await _testUrl('$baseUrl/health', 'Health Check');
      await _testUrl('$baseUrl/api/persons', 'API Test');
      
      setState(() {
        _results += '\n';
      });
    }

    // Test creating a person
    await _testCreatePerson();

    setState(() {
      _testing = false;
      _results += '\n✅ Tests completed!';
    });
  }

  Future<void> _testUrl(String url, String testName) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _results += '$testName - $url\n';
        _results += '  Status: ${response.statusCode}\n';
        _results += '  Response: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}\n';
      });
    } on SocketException catch (e) {
      setState(() {
        _results += '$testName - $url\n';
        _results += '  ❌ Network Error: ${e.message}\n';
      });
    } on TimeoutException catch (e) {
      setState(() {
        _results += '$testName - $url\n';
        _results += '  ⏰ Timeout: ${e.message}\n';
      });
    } catch (e) {
      setState(() {
        _results += '$testName - $url\n';
        _results += '  ❌ Error: $e\n';
      });
    }
  }

  Future<void> _testCreatePerson() async {
    const String testUrl = 'http://192.168.88.24:8080/api/persons';
    
    try {
      final response = await http.post(
        Uri.parse(testUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Test User ${DateTime.now().millisecondsSinceEpoch}',
          'personnummer': 123456789,
        }),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _results += 'Create Person Test - $testUrl\n';
        _results += '  Status: ${response.statusCode}\n';
        _results += '  Response: ${response.body}\n';
      });
    } catch (e) {
      setState(() {
        _results += 'Create Person Test - $testUrl\n';
        _results += '  ❌ Error: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Debug'),
        backgroundColor: const Color(0xFF0078D7),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _testing ? null : _runNetworkTests,
              icon: _testing 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.network_check),
              label: Text(_testing ? 'Testing...' : 'Run Network Tests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Test Results:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _results.isEmpty 
                      ? 'Click "Run Network Tests" to test server connectivity'
                      : _results,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Network Information:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expected Server IP: 192.168.88.24:8080'),
                  Text('Platform: ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Other'}'),
                  if (Platform.isAndroid) 
                    const Text('Android Emulator should use: 10.0.2.2:8080'),
                  if (Platform.isIOS) 
                    const Text('iOS Simulator should use: localhost:8080'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}