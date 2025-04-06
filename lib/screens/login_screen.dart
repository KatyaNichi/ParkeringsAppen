import 'package:flutter/material.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/services/api_service.dart';
import 'package:parking_app_flutter/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService(baseUrl: 'http://192.168.88.39:8080');
  
  bool _isLoading = false;
  String _errorMessage = '';

  // In login_screen.dart
Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get all persons from the server
      final List<dynamic> persons = await _apiService.getList('/api/persons');
      
      // Find person with matching credentials
      final personData = persons.firstWhere(
        (p) => p['name'] == _emailController.text, 
        orElse: () => null
      );
      
      if (personData != null) {
        // Create a Person object from the data
        final loggedInUser = Person.fromJson(personData);
        
        // Save the current user
        UserService().setCurrentUser(loggedInUser);
        
        // Successfully logged in - pass the entire user object
        Navigator.pushReplacementNamed(
          context, 
          '/main',
          arguments: loggedInUser, // Pass complete user object
        );
      } else {
        setState(() {
          _errorMessage = 'Felaktigt användarnamn eller lösenord';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ansluta till servern: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: const Text('Logga In'),
    backgroundColor: Color(0xFF0078D7),
    foregroundColor: Colors.white,
  ),
  body: Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 450), // Constrain width on larger screens
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Användarnamn',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ange ditt användarnamn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
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
                        return 'Ange ditt lösenord';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24.0),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0078D7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                              vertical: 16.0,
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Logga In',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    )));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}