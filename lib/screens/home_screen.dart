import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking App'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFeatureCard(
            context,
            'Inlogning',
            Icons.people,
            () => Navigator.pushNamed(context, '/persons'),
          ),
          _buildFeatureCard(
            context,
            'Fordons',
            Icons.directions_car,
            () => Navigator.pushNamed(context, '/vehicles'),
          ),
          _buildFeatureCard(
            context,
            'Parkeringsplats',
            Icons.local_parking,
            () => Navigator.pushNamed(context, '/spaces'),
          ),
          _buildFeatureCard(
            context,
            'Aktiva parkeringar',
            Icons.access_time,
            () => Navigator.pushNamed(context, '/parkings'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}