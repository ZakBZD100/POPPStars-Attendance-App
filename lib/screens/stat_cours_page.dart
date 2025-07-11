import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/database_helper.dart';

class StatCoursPage extends StatefulWidget {
  const StatCoursPage({super.key});

  @override
  _StatCoursPageState createState() => _StatCoursPageState();
}

class _StatCoursPageState extends State<StatCoursPage> {
  Map<String, double> tauxPresenceParCours = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courses = await DatabaseHelper.instance.getCourses();
    Map<String, double> result = {};

    for (var course in courses) {
      String courseId = course['id'].toString();
      String courseName = course['nom'];
      double taux = await DatabaseHelper.instance.getTauxPresenceMoyenPourCours(courseId);
      result[courseName] = taux;
    }

    setState(() {
      tauxPresenceParCours = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final cours = tauxPresenceParCours.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques de présence par cours")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            maxY: 100,
            barGroups: List.generate(
              tauxPresenceParCours.length,
                  (index) {
                final courseName = cours[index];
                final value = tauxPresenceParCours[courseName]!;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: Colors.blue,
                      width: 22,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index < 0 || index >= cours.length) return Container();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        cours[index],
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  reservedSize: 42,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}%'),
                  reservedSize: 40,
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, horizontalInterval: 20),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}