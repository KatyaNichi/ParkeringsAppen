import 'package:equatable/equatable.dart';
import '../../models/person.dart';

// Base state class
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {}

// Loading state
class AuthLoading extends AuthState {}

// Authenticated state
class AuthAuthenticated extends AuthState {
  final Person user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

// Unauthenticated state
class AuthUnauthenticated extends AuthState {}

// Registration state
class AuthRegistered extends AuthState {
  final Person user;

  const AuthRegistered(this.user);

  @override
  List<Object?> get props => [user];
}

// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}