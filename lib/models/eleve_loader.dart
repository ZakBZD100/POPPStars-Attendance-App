import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:frontend/database_helper.dart';
import 'eleves.dart';

Future<List<Eleve>> loadElevesFromCSV() async {
  final rawData = await rootBundle.loadString('assets/eleves.csv');
  final csvTable = const CsvToListConverter(fieldDelimiter: ';').convert(rawData, eol: '\n');
  csvTable.removeAt(0); // supprime l'en-tête

  final prefs = await SharedPreferences.getInstance();
  final String? savedData = prefs.getString('presences');

  Map<String, dynamic> presences = {};
  if (savedData != null) {
    presences = jsonDecode(savedData);
  }

  return csvTable.map((line) {
    final prenom = line[0].toString().trim();
    final nom = line[1].toString().trim();
    final classe = line.length > 2 ? line[2].toString().trim() : 'Non spécifiée';
    final matricule = line.length > 3 ? line[3].toString().trim() : 'N/A';
    final key = '$prenom $nom';
    final statut = presences[key]?.toString() ?? 'Présent';

    return Eleve(
      nom: nom,
      prenom: prenom,
      classe: classe,
      matricule: matricule,
      statut: statut,
    );
  }).toList().cast<Eleve>();
}

Future<List<Eleve>> loadElevesFromDB(int seanceId) async {
  final rawData = await rootBundle.loadString('assets/eleves.csv');
  final csvTable = const CsvToListConverter(fieldDelimiter: ';').convert(rawData, eol: '\n');
  csvTable.removeAt(0); // supprime l'en-tête

  final db = DatabaseHelper.instance;
  final Map<String, String> presences = await db.getPresencesBySeance(seanceId);

  return csvTable.map((line) {
    final prenom = line[0].toString().trim();
    final nom = line[1].toString().trim();
    final classe = line.length > 2 ? line[2].toString().trim() : 'Non spécifiée';
    final matricule = line.length > 3 ? line[3].toString().trim() : 'N/A';
    final key = '$prenom $nom';
    final statut = presences[key] ?? 'Présent';

    return Eleve(
      nom: nom,
      prenom: prenom,
      classe: classe,
      matricule: matricule,
      statut: statut,
    );
  }).toList().cast<Eleve>();
}