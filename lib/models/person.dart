// lib/models/person.dart
class Person {
  final int id;
  final String name;
  final int personnummer;

  Person({
    required this.id,
    required this.name,
    required this.personnummer,
  });

  // Factory constructor to create a Person from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: json['name'] as String,
      personnummer: json['personnummer'] as int,
    );
  }

  // Convert a Person to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personnummer': personnummer,
    };
  }
}