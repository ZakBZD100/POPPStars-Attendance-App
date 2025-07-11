class Eleve {
  final int? id;
  final String nom;
  final String prenom;
  final String classe;
  final String matricule;
  String statut;

  Eleve({
    this.id,
    required this.nom,
    required this.prenom,
    required this.classe,
    required this.matricule,
    this.statut = 'Non vérifié',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'classe': classe,
      'matricule': matricule,
      'statut': statut,
    };
  }

  factory Eleve.fromMap(Map<String, dynamic> map) {
    return Eleve(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      classe: map['classe'],
      matricule: map['matricule'],
      statut: map['statut'] ?? 'Non vérifié',
    );
  }
}