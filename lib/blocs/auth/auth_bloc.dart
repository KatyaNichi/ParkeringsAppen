// REPLACE ENTIRE FILE: lib/blocs/auth/auth_bloc.dart
import 'package:bloc/bloc.dart';
import '../../repositories/firestore_person_repository.dart';
import '../../repositories/firebase_auth_repository.dart';
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
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      print('🔐 Attempting login for: ${event.username}');
      
      // Use Firebase Auth for authentication
      final userCredential = await authRepository.signIn(event.username, event.password);
      
      if (userCredential.user != null) {
        // Try to find existing person profile in Firestore
        final persons = await personRepository.getAllPersons();
        final person = persons.firstWhere(
          (p) => p.name == event.username, // You might want to use email instead
          orElse: () => throw Exception('User profile not found'),
        );
        
        print('✅ Login successful for: ${person.name}');
        emit(AuthAuthenticated(person));
      } else {
        emit(const AuthError('Login failed'));
      }
    } catch (e) {
      print('❌ Login failed: $e');
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      print('📝 Attempting registration for: ${event.name}');
      
      // Create Firebase Auth user
      final userCredential = await authRepository.register(event.name, event.password);
      
      if (userCredential.user != null) {
        // Create person profile in Firestore
        final newUser = await personRepository.addPerson(
          event.name, 
          event.personnummer
        );
        
        print('✅ Registration successful for: ${newUser.name}');
        emit(AuthRegistered(newUser));
        // Automatically authenticate after registration
        emit(AuthAuthenticated(newUser));
      } else {
        emit(const AuthError('Registration failed'));
      }
    } catch (e) {
      print('❌ Registration failed: $e');
      emit(AuthError(e.toString()));
    }
  }
}