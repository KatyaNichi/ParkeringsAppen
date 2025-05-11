import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/repositories/http_person_repository.dart';

class MockPersonRepository implements HttpPersonRepository {
  final List<Person> _persons = [];
  int _nextId = 1;
  
  @override
  String get baseUrl => 'mock://localhost';
  
  // Add initial test data
  MockPersonRepository() {
    // Add a test user for login tests
    _persons.add(Person(
      id: _nextId++,
      name: 'TestUser',
      personnummer: 12345,
    ));
  }
  
  // Add a person
  @override
  Future<Person> addPerson(String name, int personnummer) async {
    final person = Person(
      id: _nextId++,
      name: name,
      personnummer: personnummer,
    );
    
    _persons.add(person);
    return person;
  }
  
  // Get all persons
  @override
  Future<List<Person>> getAllPersons() async {
    return List.from(_persons);
  }
  
  // Get a person by ID
  @override
  Future<Person?> getPersonById(int id) async {
    try {
      return _persons.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Update a person
  @override
  Future<bool> updatePerson(int id, {String? newName, int? newPersonnummer}) async {
    final index = _persons.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    
    final person = _persons[index];
    _persons[index] = Person(
      id: person.id,
      name: newName ?? person.name,
      personnummer: newPersonnummer ?? person.personnummer,
    );
    
    return true;
  }
  
  // Remove a person
  @override
  Future<bool> removePerson(int id) async {
    final initialLength = _persons.length;
    _persons.removeWhere((p) => p.id == id);
    return _persons.length < initialLength;
  }
}