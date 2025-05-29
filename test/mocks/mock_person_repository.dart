import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:parking_app_flutter/blocs/auth/auth_bloc.dart';
import 'package:parking_app_flutter/blocs/auth/auth_event.dart';
import 'package:parking_app_flutter/blocs/auth/auth_state.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/repositories/firebase_auth_repository.dart';
import 'package:mocktail/mocktail.dart';

// Create a mock for FirebaseAuthRepository
class MockFirebaseAuthRepository extends Mock implements FirebaseAuthRepository {}

void main() {
  group('AuthBloc', () {
    late MockFirebaseAuthRepository mockAuthRepository;
    late AuthBloc authBloc;

    // Register fallback value for Person
    setUpAll(() {
      registerFallbackValue(Person(id: 0, name: 'Fallback', personnummer: 0));
    });

    setUp(() {
      mockAuthRepository = MockFirebaseAuthRepository();
      authBloc = AuthBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when LoginRequested is added with valid credentials',
      setUp: () {
        // Mock successful login
        when(() => mockAuthRepository.signInWithEmailAndPassword(
              any(),
              any(),
            )).thenAnswer((_) async => Person(
              id: 1,
              name: 'TestUser',
              personnummer: 12345,
            ));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const LoginRequested(
        username: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested is added with invalid credentials',
      setUp: () {
        // Mock failed login
        when(() => mockAuthRepository.signInWithEmailAndPassword(
              any(),
              any(),
            )).thenThrow(Exception('Invalid credentials'));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const LoginRequested(
        username: 'invalid@example.com',
        password: 'wrongPassword',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthRegistered, AuthAuthenticated] when RegisterRequested is added',
      setUp: () {
        // Mock successful registration
        when(() => mockAuthRepository.registerWithEmailAndPassword(
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => Person(
              id: 2,
              name: 'NewUser',
              personnummer: 54321,
            ));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const RegisterRequested(
        name: 'NewUser',
        personnummer: 54321,
        password: 'newPassword123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthRegistered>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when LogoutRequested is added',
      setUp: () {
        // Mock logout
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
      },
      build: () => authBloc,
      seed: () => AuthAuthenticated(Person(id: 1, name: 'TestUser', personnummer: 12345)),
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}