import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:parking_app_flutter/blocs/auth/auth_bloc.dart';
import 'package:parking_app_flutter/blocs/auth/auth_event.dart';
import 'package:parking_app_flutter/blocs/auth/auth_state.dart';
import 'package:parking_app_flutter/models/person.dart';
import '../mocks/mock_person_repository.dart';

void main() {
  group('AuthBloc', () {
    late MockPersonRepository mockPersonRepository;
    late AuthBloc authBloc;

    setUp(() {
      mockPersonRepository = MockPersonRepository();
      authBloc = AuthBloc(personRepository: mockPersonRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when LoginRequested is added with valid credentials',
      build: () => authBloc,
      act: (bloc) => bloc.add(const LoginRequested(
        username: 'TestUser',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested is added with invalid credentials',
      build: () => authBloc,
      act: (bloc) => bloc.add(const LoginRequested(
        username: 'NonExistentUser',
        password: 'wrongPassword',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthRegistered, AuthAuthenticated] when RegisterRequested is added',
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
      build: () => authBloc,
      seed: () => AuthAuthenticated(Person(id: 1, name: 'TestUser', personnummer: 12345)),
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}