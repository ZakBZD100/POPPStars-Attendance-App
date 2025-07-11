import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/database_helper.dart';

class RapportAbsencesPage extends StatefulWidget {
  const RapportAbsencesPage({super.key});

  @override
  State<RapportAbsencesPage> createState() => _RapportAbsencesPageState();
}

class _RapportAbsencesPageState extends State<RapportAbsencesPage> {
  final dbHelper = DatabaseHelper.instance;
  Map<String, List<Map<String, dynamic>>> rapportData = {}; // courseName: [seance + absents]

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final cours = await dbHelper.getCourses();
    Map<String, List<Map<String, dynamic>>> data = {};

    for (var course in cours) {
      final courseId = course['id'];
      final courseName = course['nom'];
      final seances = await dbHelper.getSeancesForCourse(courseId);
      List<Map<String, dynamic>> infos = [];

      for (var seance in seances) {
        final date = seance['dateHeure'];
        final seanceId = seance['id'];
        final presences = await dbHelper.getPresencesBySeance(seanceId);

        final absents = presences.entries
            .where((entry) => entry.value != 'Présent')
            .map((entry) => '${entry.key} (${entry.value})')
            .toList();

        infos.add({
          'date': date,
          'absents': absents,
        });
      }

      data[courseName] = infos;
    }

    setState(() {
      rapportData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports d\'Absence'),
        centerTitle: true,
      ),
      body: rapportData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rapportData.length,
              itemBuilder: (context, index) {
                String courseName = rapportData.keys.elementAt(index);
                List<Map<String, dynamic>> seances = rapportData[courseName]!;

                return ExpansionTile(
                  title: Text(courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: seances.map((seance) {
                    final date = DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.parse(seance['date']));
                    final absents = seance['absents'] as List<String>;

                    return ListTile(
                      title: Text("Séance du $date"),
                      subtitle: absents.isEmpty
                          ? const Text("Aucun absent")
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: absents.map((e) => Text('- $e')).toList(),
                            ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}