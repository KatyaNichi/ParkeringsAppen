import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/screens/manage_parking_screen.dart';
import 'package:parking_app_flutter/screens/welcome_screen.dart';
import 'package:parking_app_flutter/screens/login_screen.dart';
import 'package:parking_app_flutter/screens/signup_screen.dart';
import 'package:parking_app_flutter/screens/main_navigation_screen.dart';

// Import repositories
import 'package:parking_app_flutter/repositories/http_person_repository.dart';
import 'package:parking_app_flutter/repositories/http_vehicle_repository.dart';
import 'package:parking_app_flutter/repositories/http_parking_repository.dart';
import 'package:parking_app_flutter/repositories/http_parking_space_repository.dart';

// Import blocs
import 'package:parking_app_flutter/blocs/auth/auth_bloc.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app_flutter/blocs/parking/parking_bloc.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String baseUrl = 'http://192.168.88.24:8080'; // server URL

    return MultiRepositoryProvider(
      providers: [
        // Provide all repositories
        RepositoryProvider<HttpPersonRepository>(
          create: (context) => HttpPersonRepository(baseUrl: baseUrl),
        ),
        RepositoryProvider<HttpVehicleRepository>(
          create: (context) => HttpVehicleRepository(baseUrl: baseUrl),
        ),
        RepositoryProvider<HttpParkingRepository>(
          create: (context) => HttpParkingRepository(baseUrl: baseUrl),
        ),
        RepositoryProvider<HttpParkingSpaceRepository>(
          create: (context) => HttpParkingSpaceRepository(baseUrl: baseUrl),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Provide all BLoCs
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              personRepository: context.read<HttpPersonRepository>(),
            ),
          ),
          BlocProvider<VehicleBloc>(
            create: (context) => VehicleBloc(
              vehicleRepository: context.read<HttpVehicleRepository>(),
            ),
          ),
          BlocProvider<ParkingBloc>(
            create: (context) => ParkingBloc(
              parkingRepository: context.read<HttpParkingRepository>(),
            ),
          ),
          BlocProvider<ParkingSpaceBloc>(
            create: (context) => ParkingSpaceBloc(
              parkingSpaceRepository: context.read<HttpParkingSpaceRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
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
          onGenerateRoute: (settings) {
            if (settings.name == '/main') {
              final Person user = settings.arguments as Person;
              return MaterialPageRoute(
                builder: (context) => MainNavigationScreen(user: user),
              );
            } else if (settings.name == '/manage_parking') {
              final ParkingSpace parkingSpace = settings.arguments as ParkingSpace;
              return MaterialPageRoute(
                builder: (context) => ManageParkingScreen(parkingSpace: parkingSpace),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}