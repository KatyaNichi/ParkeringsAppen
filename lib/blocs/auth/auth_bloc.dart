// lib/blocs/auth/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/person.dart';
import '../../repositories/firebase_auth_repository.dart';
import '../../repositories/firestore_person_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthRepository authRepository;
  final FirestorePersonRepository personRepository;

  AuthBloc({
    required this.authRepository,
    required this.personRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
    
    // Listen to Firebase Auth state changes
    authRepository.authStateChanges.listen((User? user) {
      if (user != null) {
        // User is signed in, but we need to get the Person model from Firestore
        _loadUserProfile(user.uid);
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final person = await personRepository.getPersonById(uid);
      if (person != null) {
        emit(AuthAuthenticated(person));
      } else {
        // User exists in Firebase Auth but not in Firestore
        print('⚠️ User exists in Firebase Auth but not in Firestore: $uid');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Failed to load user profile: $e');
      emit(AuthError('Failed to load user profile: $e'));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      print('🔐 Attempting login for: ${event.username}');
      
      // Login with Firebase Auth
      final userCredential = await authRepository.signIn(
        event.username, 
        event.password
      );
      
      // Get user profile from Firestore
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final person = await personRepository.getPersonById(uid);
        
        if (person != null) {
          print('✅ Login successful for: ${person.name}');
          emit(AuthAuthenticated(person));
        } else {
          print('⚠️ User authenticated but profile not found. Creating profile...');
          
          // If user exists in Auth but not in Firestore, create a profile
          final newPerson = await personRepository.addPerson(
            uid,
            userCredential.user!.displayName ?? 'User',
            0 // Default personnummer, should be updated later
          );
          
          emit(AuthAuthenticated(newPerson));
        }
      } else {
        print('❌ Login failed: No user returned from Firebase');
        emit(const AuthError('Login failed'));
      }
    } catch (e) {
      print('❌ Login failed: $e');
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      print('🚪 Logging out user');
      await authRepository.signOut();
      print('✅ Logout successful');
      emit(AuthUnauthenticated());
    } catch (e) {
      print('❌ Logout failed: $e');
      emit(AuthError('Logout failed: $e'));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      print('📝 Registering new user: ${event.email}');
      
      // Register with Firebase Auth
      final userCredential = await authRepository.register(
        event.email, 
        event.password
      );
      
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        
        // Update display name in Firebase Auth
        await authRepository.updateUserProfile(displayName: event.name);
        print('✅ Updated Firebase Auth display name: ${event.name}');
        
        // Create person profile in Firestore with the same UID
        final person = await personRepository.addPerson(
          uid,  // Use Firebase Auth UID as Firestore document ID
          event.name,
          event.personnummer
        );
        
        print('✅ Registration successful for: ${person.name}');
        emit(AuthRegistered(person));
        emit(AuthAuthenticated(person));
      } else {
        print('❌ Registration failed: No user returned from Firebase');
        emit(const AuthError('Registration failed'));
      }
    } catch (e) {
      print('❌ Registration failed: $e');
      emit(AuthError(e.toString()));
    }
  }
}