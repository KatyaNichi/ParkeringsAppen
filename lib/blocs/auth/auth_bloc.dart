import 'package:bloc/bloc.dart';
import '../../repositories/http_person_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final HttpPersonRepository personRepository;

  AuthBloc({required this.personRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Fetch all persons from the repository
      final persons = await personRepository.getAllPersons();
      
      // Find user by name (simple login for demonstration)
      final user = persons.firstWhere(
        (p) => p.name == event.username, 
        orElse: () => throw Exception('User not found')
      );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthUnauthenticated());
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Create a new person in the repository
      final newUser = await personRepository.addPerson(
        event.name, 
        event.personnummer
      );
      
      emit(AuthRegistered(newUser));
      // Automatically authenticate after registration
      emit(AuthAuthenticated(newUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}