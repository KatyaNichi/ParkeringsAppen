// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'dart:io' show Platform;

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:parking_app_flutter/repositories/firestore_parking_repository.dart';
import 'package:parking_app_flutter/repositories/firestore_parking_space_repository.dart';
import 'package:parking_app_flutter/repositories/firestore_vehicle_repository.dart';
import 'firebase_options.dart';

// Repository imports
import 'package:parking_app_flutter/repositories/firebase_auth_repository.dart';
import 'package:parking_app_flutter/repositories/firestore_person_repository.dart';
import 'package:parking_app_flutter/repositories/http_vehicle_repository.dart';
import 'package:parking_app_flutter/repositories/http_parking_repository.dart';
import 'package:parking_app_flutter/repositories/http_parking_space_repository.dart';

// Model imports
import 'package:parking_app_flutter/models/parking_space.dart';
import 'package:parking_app_flutter/models/person.dart';

// Screen imports
import 'package:parking_app_flutter/screens/manage_parking_screen.dart';
import 'package:parking_app_flutter/screens/welcome_screen.dart';
import 'package:parking_app_flutter/screens/login_screen.dart';
import 'package:parking_app_flutter/screens/signup_screen.dart';
import 'package:parking_app_flutter/screens/main_navigation_screen.dart';

// BLoC imports
import 'package:parking_app_flutter/blocs/auth/auth_bloc.dart';
import 'package:parking_app_flutter/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_app_flutter/blocs/parking/parking_bloc.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_app_flutter/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 try {
    await NotificationService().initialize();
    print('✅ Notification service initialized successfully');
  } catch (e) {
    print('❌ Notification service initialization error: $e');
    // Continue even if notifications fail - the app can still work without them
  }
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    if (e is FirebaseException) {
      print('   Firebase Error Code: ${e.code}');
      print('   Firebase Error Message: ${e.message}');
    }
    // Continue even if Firebase fails - the app can still work with HTTP backend
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dynamic server URL configuration based on platform
    String getServerUrl() {
      if (kIsWeb) {
        // For web, use localhost
        return 'http://localhost:8080';
      } else {
        try {
          if (Platform.isAndroid) {
            // Android emulator uses 10.0.2.2 to reach host machine
            return 'http://10.0.2.2:8080';
          } else if (Platform.isIOS) {
            // iOS simulator can use localhost
            return 'http://localhost:8080';
          } else {
            // For real devices or other platforms, use your actual IP
            return 'http://192.168.88.24:8080';
          }
        } catch (e) {
          print('⚠️ Platform detection failed, using localhost: $e');
          return 'http://localhost:8080';
        }
      }
    }

    final String baseUrl = getServerUrl();
    print('🔗 Flutter app connecting to: $baseUrl');
    print(
      '📱 Platform: ${kIsWeb ? 'Web' : (Platform.isAndroid
              ? 'Android'
              : Platform.isIOS
              ? 'iOS'
              : 'Other')}',
    );

    return MultiRepositoryProvider(
      providers: [
        // Firebase Auth Repository
        RepositoryProvider<FirebaseAuthRepository>(
          create: (context) => FirebaseAuthRepository(),
        ),
        RepositoryProvider<FirestoreParkingSpaceRepository>(
          create: (context) => FirestoreParkingSpaceRepository(),
        ),
        RepositoryProvider<FirebaseAuthRepository>(
          create: (context) => FirebaseAuthRepository(),
        ),
        RepositoryProvider<FirestorePersonRepository>(
          create: (context) => FirestorePersonRepository(),
        ),
        RepositoryProvider<FirestoreParkingSpaceRepository>(
          create: (context) => FirestoreParkingSpaceRepository(),
        ),
        RepositoryProvider<FirestoreParkingRepository>(
          create: (context) => FirestoreParkingRepository(),
        ),
        RepositoryProvider<FirestoreVehicleRepository>(
          create:
              (context) => FirestoreVehicleRepository(
                personRepository: context.read<FirestorePersonRepository>(),
              ),
        ),
        // Firestore Person Repository
        RepositoryProvider<FirestorePersonRepository>(
          create: (context) => FirestorePersonRepository(),
        ),
        RepositoryProvider<FirestoreVehicleRepository>(
          create:
              (context) => FirestoreVehicleRepository(
                personRepository: context.read<FirestorePersonRepository>(),
              ),
        ),
        // HTTP Repositories (will be migrated to Firestore later)
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
          // Auth BLoC using Firebase
          BlocProvider<AuthBloc>(
            create:
                (context) => AuthBloc(
                  authRepository: context.read<FirebaseAuthRepository>(),
                  personRepository: context.read<FirestorePersonRepository>(),
                ),
          ),
          BlocProvider<VehicleBloc>(
            create:
                (context) => VehicleBloc(
                  vehicleRepository: context.read<FirestoreVehicleRepository>(),
                ),
          ),
          BlocProvider<ParkingBloc>(
            create:
                (context) => ParkingBloc(
                  parkingRepository: context.read<FirestoreParkingRepository>(),
                ),
          ),
          BlocProvider<ParkingSpaceBloc>(
            create:
                (context) => ParkingSpaceBloc(
                  parkingSpaceRepository:
                      context.read<FirestoreParkingSpaceRepository>(),
                ),
          ),
        ],
        child: MaterialApp(
          title: 'ParkeringsAppen',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFF0078D7), // Azure blue
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0078D7),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
          },
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/main':
                if (settings.arguments is Person) {
                  final Person user = settings.arguments as Person;
                  return MaterialPageRoute(
                    builder: (context) => MainNavigationScreen(user: user),
                    settings: settings,
                  );
                }
                break;

              case '/manage_parking':
                if (settings.arguments is ParkingSpace) {
                  final ParkingSpace parkingSpace =
                      settings.arguments as ParkingSpace;
                  return MaterialPageRoute(
                    builder:
                        (context) =>
                            ManageParkingScreen(parkingSpace: parkingSpace),
                    settings: settings,
                  );
                }
                break;
            }

            // Fallback to home if route not found
            return MaterialPageRoute(
              builder: (context) => const WelcomeScreen(),
            );
          },

          // Global error handling
          builder: (context, child) {
            return Builder(
              builder: (context) {
                // Handle global app errors here if needed
                return child ??
                    const Scaffold(
                      body: Center(child: Text('App Loading Error')),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}


