// Update your lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app_flutter/blocs/auth/auth_bloc.dart';
import 'package:parking_app_flutter/blocs/auth/auth_event.dart';
import 'package:parking_app_flutter/blocs/auth/auth_state.dart';
import 'package:parking_app_flutter/services/api_service.dart';
import 'package:parking_app_flutter/services/user_service.dart';
// Add this import for the debug widget
// import 'package:parking_app_flutter/widgets/network_debug_widget.dart';
import 'dart:io';
import 'dart:async';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _personnummerController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Dynamic server URL based on platform
  late final ApiService _apiService;
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  void _initializeApiService() {
    String serverUrl;
    
    if (kIsWeb) {
      serverUrl = 'http://localhost:8080';
    } else {
      try {
        if (Platform.isAndroid) {
          serverUrl = 'http://10.0.2.2:8080'; // Android emulator
        } else if (Platform.isIOS) {
          serverUrl = 'http://localhost:8080'; // iOS simulator
        } else {
          serverUrl = 'http://192.168.88.24:8080'; // Real device
        }
      } catch (e) {
        serverUrl = 'http://localhost:8080'; // Fallback
      }
    }
    
    _apiService = ApiService(baseUrl: serverUrl);
    print('🔗 Signup screen using server: $serverUrl');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personnummerController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🏓 Testing server connection...');
      final isConnected = await _apiService.pingServer();
      
      if (isConnected) {
        setState(() {
          _errorMessage = '✅ Server connection successful!';
        });
        
      
      } else {
        setState(() {
          _errorMessage = '❌ Cannot connect to server at ${_apiService.baseUrl}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Connection test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 Future<void> _signup() async {
  if (_formKey.currentState!.validate()) {
    // Use BLoC for registration instead of direct API calls
    context.read<AuthBloc>().add(RegisterRequested(
      name: _nameController.text.trim(),
      personnummer: int.parse(_personnummerController.text.trim()),
      password: _passwordController.text,
    ));
  }
}
  void _openNetworkDebug() {
    // Uncomment when you add the NetworkDebugWidget
    /*
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NetworkDebugWidget()),
    );
    */
    
    // Temporary debug info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Server URL: ${_apiService.baseUrl}'),
            Text('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}'),
            if (!kIsWeb && Platform.isAndroid) 
              const Text('Emulator should use: 10.0.2.2:8080'),
            if (!kIsWeb && Platform.isIOS) 
              const Text('Simulator should use: localhost:8080'),
            const SizedBox(height: 16),
            const Text('Try these URLs manually:'),
            SelectableText('curl ${_apiService.baseUrl}/ping'),
            SelectableText('curl ${_apiService.baseUrl}/health'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skapa Konto'),
        backgroundColor: const Color(0xFF0078D7),
        foregroundColor: Colors.white,
        actions: [
          // Debug button (only show in debug mode)
          if (kDebugMode)
            IconButton(
              onPressed: _openNetworkDebug,
              icon: const Icon(Icons.bug_report),
              tooltip: 'Network Debug',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Server connection info (debug mode only)
                  if (kDebugMode)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Debug: Server URL\n${_apiService.baseUrl}',
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testConnection,
                            icon: const Icon(Icons.network_check, size: 16),
                            label: const Text('Test Connection'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Namn',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ange ditt namn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Personnummer field
                  TextFormField(
                    controller: _personnummerController,
                    decoration: const InputDecoration(
                      labelText: 'Personnummer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment_ind),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ange ditt personnummer';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Personnummer måste vara ett tal';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Lösenord',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ange ett lösenord';
                      }
                      if (value.length < 6) {
                        return 'Lösenordet måste vara minst 6 tecken';
                      }
                      return null;
                    },
                  ),
                  
                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _errorMessage.startsWith('✅') 
                          ? Colors.green[50] 
                          : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _errorMessage.startsWith('✅') 
                            ? Colors.green[300]! 
                            : Colors.red[300]!,
                        ),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: _errorMessage.startsWith('✅') 
                            ? Colors.green[700] 
                            : Colors.red[700],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24.0),
                  
                  // Signup button
                  _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0078D7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 16.0,
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _signup,
                        child: const Text(
                          'Skapa Konto',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Login link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Har du redan ett konto? Logga in',
                      style: TextStyle(color: Color(0xFF0078D7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}