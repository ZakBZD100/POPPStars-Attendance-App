class Cours {
  final String nom;
  final int presentes;
  final int total;

  Cours({required this.nom, required this.presentes, required this.total});

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'presentes': presentes,
      'total': total,
    };
  }

  factory Cours.fromMap(Map<String, dynamic> map) {
    return Cours(
      nom: map['nom'],
      presentes: map['presentes'],
      total: map['total'],
    );
  }
}