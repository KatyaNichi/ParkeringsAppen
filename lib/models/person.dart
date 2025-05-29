
class Person {
  final String id; // Changed from int to String for Firestore
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
      id: json['id'] as String, // Handle both String and int for compatibility
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

  // For Firestore document data (without ID)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'personnummer': personnummer,
    };
  }

  // Create from Firestore document
  factory Person.fromFirestore(String docId, Map<String, dynamic> data) {
    return Person(
      id: docId,
      name: data['name'] as String,
      personnummer: data['personnummer'] as int,
    );
  }

  // Copy with method for updates
  Person copyWith({
    String? id,
    String? name,
    int? personnummer,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      personnummer: personnummer ?? this.personnummer,
    );
  }

  @override
  String toString() {
    return 'Person(id: $id, name: $name, personnummer: $personnummer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person &&
        other.id == id &&
        other.name == name &&
        other.personnummer == personnummer;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ personnummer.hashCode;
}