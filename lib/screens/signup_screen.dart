import 'package:flutter/material.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/services/api_service.dart';
import 'package:parking_app_flutter/services/user_service.dart';

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
  final _apiService = ApiService(baseUrl: 'http://192.168.88.39:8080');
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _personnummerController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Create user account
        final response = await _apiService.createItem('/api/persons', {
          'name': _nameController.text,
          'personnummer': int.parse(_personnummerController.text),
        });

        // Extract the user information from the response
        final personData = response['person']; // Adjust this based on your API response structure
        
        // Create a Person object
        final newUser = Person(
          id: personData['id'],
          name: personData['name'],
          personnummer: personData['personnummer'],
        );
        
        // Set the user in the UserService
        UserService().setCurrentUser(newUser);
        
        // Navigate to main screen with the Person object
        Navigator.pushReplacementNamed(
          context, 
          '/main',
          arguments: newUser, // Pass the Person object, not just the name
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Kunde inte skapa konto: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skapa Konto'),
        backgroundColor: const Color(0xFF0078D7),
        foregroundColor: Colors.white,
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
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Namn',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                      if (value == null || value.isEmpty) {
                        return 'Ange ditt personnummer';
                      }
                      if (int.tryParse(value) == null) {
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