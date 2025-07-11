import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/database_helper.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class StatElevePage extends StatefulWidget {
  @override
  _StatElevePageState createState() => _StatElevePageState();
}

class _StatElevePageState extends State<StatElevePage> {
  List<Map<String, dynamic>> eleves = [];
  Map<String, dynamic>? selectedEleve;

  // Liste des cours (id + nom)
  List<Map<String, String>> cours = [];

  // Map coursNom -> taux de présence
  Map<String, double> tauxParCours = {};

  @override
  void initState() {
    super.initState();
    loadElevesFromCsv();
    loadCours();
  }

  Future<void> loadElevesFromCsv() async {
    final rawData = await rootBundle.loadString('assets/eleves.csv');

    List<List<dynamic>> csvTable = CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
    ).convert(rawData);

    List<Map<String, dynamic>> listEleves = [];

    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      final prenom = row[0].toString().trim();
      final nom = row[1].toString().trim();

      listEleves.add({'prenom': prenom, 'nom': nom});
    }

    setState(() {
      eleves = listEleves;
    });
  }

  Future<void> loadCours() async {
    final helper = DatabaseHelper.instance;
    final coursList = await helper.getCourses();

    setState(() {
      cours = coursList.map((c) => {
        'id': c['id'] as String,
        'nom': c['nom'] as String,
      }).toList();
    });
  }

  Future<double> getTauxPresencePourEleveCours(String courseId, String nom, String prenom) async {
    final helper = DatabaseHelper.instance;
    return await helper.getTauxPresencePourEleveCours(courseId, nom, prenom);
  }

  void onEleveSelected(Map<String, dynamic> eleve) async {
    setState(() {
      selectedEleve = eleve;
      tauxParCours.clear();
    });

    for (var c in cours) {
      final taux = await getTauxPresencePourEleveCours(
        c['id']!,
        eleve['nom'],
        eleve['prenom'],
      );
      setState(() {
        tauxParCours[c['nom']!] = taux;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques élève')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<Map<String, dynamic>>(
              hint: const Text('Sélectionner un élève'),
              value: selectedEleve,
              isExpanded: true,
              items: eleves.map((eleve) {
                return DropdownMenuItem(
                  value: eleve,
                  child: Text('${eleve['prenom']} ${eleve['nom']}'),
                );
              }).toList(),
              onChanged: (eleve) {
                if (eleve != null) onEleveSelected(eleve);
              },
            ),
            const SizedBox(height: 30),
            selectedEleve == null
                ? const Text('Aucun élève sélectionné')
                : Expanded(
              child: tauxParCours.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : BarChart(
                BarChartData(
                  maxY: 100,
                  barGroups: tauxParCours.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final nomCours = entry.value.key;
                    final taux = entry.value.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: taux,
                          color: Colors.blue,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%',
                              style: const TextStyle(fontSize: 12));
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= tauxParCours.length)
                            return const SizedBox();
                          final nomCours = tauxParCours.keys.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              nomCours,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 60,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, horizontalInterval: 20),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
