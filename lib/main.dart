import 'package:flutter/material.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/screens/manage_parking_screen.dart';
import 'package:parking_app_flutter/screens/welcome_screen.dart';
import 'package:parking_app_flutter/screens/login_screen.dart';
import 'package:parking_app_flutter/screens/signup_screen.dart';
import 'package:parking_app_flutter/screens/main_navigation_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkeringsAppen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF0078D7), // Azure blue
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
      // In main.dart
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final Person user = settings.arguments as Person;
          return MaterialPageRoute(
            builder: (context) => MainNavigationScreen(user: user),
          );
        } else if (settings.name == '/manage_parking') {
          final ParkingSpace parkingSpace = settings.arguments as ParkingSpace;
          return MaterialPageRoute(
            builder:
                (context) => ManageParkingScreen(parkingSpace: parkingSpace),
          );
        }
        return null;
      },
    );
  }
}
