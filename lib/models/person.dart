class Person {
  final int id;
  final String name;
  final String? biography;
  final String? birthday;
  final String? placeOfBirth;
  final String? profilePath;

  Person({
    required this.id,
    required this.name,
    this.biography,
    this.birthday,
    this.placeOfBirth,
    this.profilePath,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      biography: json['biography'] ?? 'No biography available.',
      birthday: json['birthday'],
      placeOfBirth: json['place_of_birth'],
      profilePath: json['profile_path'],
    );
  }
}
