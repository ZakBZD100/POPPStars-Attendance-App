class Course {
  final String id; // Changement ici
  final String nom;
  final String specialite;
  final int volumeHoraire;

  Course({
    required this.id,
    required this.nom,
    required this.specialite,
    required this.volumeHoraire,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,               // snake_case ici aussi
      'volume_horaire': volumeHoraire,
      'specialite': specialite,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'].toString(), // Assure que c'est un String
      nom: map['nom'],
      specialite: map['specialite'],
      volumeHoraire: map['volumeHoraire'],
    );
  }
}