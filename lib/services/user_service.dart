import 'package:parking_app_flutter/models/person.dart';
import 'dart:async';

class UserService {
  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }
  
  UserService._internal();
  
  Person? _currentUser;
  final _userController = StreamController<Person?>.broadcast();
  
  // Getter for the current user
  Person? get currentUser => _currentUser;
  
  // Stream for listening to user changes
  Stream<Person?> get userStream => _userController.stream;
  
  // Set the current user and notify listeners
  void setCurrentUser(Person user) {
    _currentUser = user;
    _userController.add(_currentUser);
  }
  
  // Clear the current user (logout)
  void clearCurrentUser() {
    _currentUser = null;
    _userController.add(_currentUser);
  }
  
  // Dispose resources
  void dispose() {
    _userController.close();
  }
}