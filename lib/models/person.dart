class Person {
  final int id;
  final String name;
  final int personnummer;

  Person({
    required this.id,
    required this.name,
    required this.personnummer,
  });

  // Create a Person from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      personnummer: json['personnummer'],
    );
  }

  // Convert Person to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personnummer': personnummer,
    };
  }

  // Create a copy of the Person with possible updates
  Person copyWith({
    int? id,
    String? name,
    int? personnummer,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      personnummer: personnummer ?? this.personnummer,
    );
  }
}