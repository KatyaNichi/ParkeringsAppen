import 'package:flutter/material.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/services/user_service.dart';

class UserScreen extends StatelessWidget {
  final Person user;
  
  const UserScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Color(0xFF0078D7),
          ),
          const SizedBox(height: 24),
          Text(
            'Hej, ${user.name}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Användar-ID: ${user.id}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Personnummer: ${user.personnummer}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          const Text(
            'Du är inloggad',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logga ut'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0078D7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            onPressed: () {
              // Clear the current user before logging out
              UserService().clearCurrentUser();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}