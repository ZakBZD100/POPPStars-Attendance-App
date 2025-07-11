import 'package:flutter/material.dart';
import 'package:frontend/database_helper.dart';
import 'package:frontend/models/seance.dart';
import 'appel_page.dart';  // La page où tu feras l’appel

class SeancesListPage extends StatefulWidget {
  const SeancesListPage({super.key});

  @override
  State<SeancesListPage> createState() => _SeancesListPageState();
}

class _SeancesListPageState extends State<SeancesListPage> {
  List<Seance> seances = [];

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  Future<void> _loadSeances() async {
    final data = await DatabaseHelper.instance.getSeancesForCourse('9');  // adapte '9' selon ton contexte
    setState(() {
      seances = data.map((e) => Seance.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des séances')),
      body: ListView.builder(
        itemCount: seances.length,
        itemBuilder: (context, index) {
          final seance = seances[index];
          return ListTile(
            title: Text('Séance ID: ${seance.id}'),
            subtitle: Text('Date: ${seance.dateHeure}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppelPage(seanceId: seance.id.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}