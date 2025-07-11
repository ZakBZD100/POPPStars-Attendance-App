// lib/screens/seance.dart

class Seance {
  final int? id;         // id généré par la BD (nullable au moment de l'insertion)
  final String courseId; // identifiant du cours, tel que stocké en String
  final DateTime dateHeure;

  Seance({this.id, required this.courseId, required this.dateHeure});

  factory Seance.fromMap(Map<String, dynamic> map) {
    return Seance(
      id: map['id'] as int?,
      courseId: map['courseId'] as String,
      dateHeure: DateTime.parse(map['dateHeure'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'dateHeure': dateHeure.toIso8601String(),
    };
  }
}