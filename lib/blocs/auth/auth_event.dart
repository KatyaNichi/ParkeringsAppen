import 'package:equatable/equatable.dart';
import '../../models/person.dart';

// Base event class
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Login event
class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

// Logout event
class LogoutRequested extends AuthEvent {}

// Registration event
class RegisterRequested extends AuthEvent {
  final String name;
  final int personnummer;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.personnummer,
    required this.password,
  });

  @override
  List<Object?> get props => [name, personnummer, password];
}