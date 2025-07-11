import 'package:flutter/material.dart';
import 'package:frontend/database_helper.dart';
import 'package:frontend/models/eleves.dart';
import 'package:frontend/models/eleve_loader.dart';

class AppelPage extends StatefulWidget {
  final String seanceId;
  const AppelPage({super.key, required this.seanceId});

  @override
  State<AppelPage> createState() => _AppelPageState();
}

class _AppelPageState extends State<AppelPage> {
  late Future<List<Eleve>> futureEleves;
  List<Eleve> eleves = [];

  @override
  void initState() {
    super.initState();
    futureEleves = loadElevesFromDB(int.parse(widget.seanceId));
    futureEleves.then((loadedEleves) {
      setState(() {
        eleves = loadedEleves;
      });
    });
  }

  Future<void> savePresences() async {
    final db = DatabaseHelper.instance;
    for (var eleve in eleves) {
      await db.insertPresence(int.parse(widget.seanceId), eleve);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Présences enregistrées dans la base !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appel séance ${widget.seanceId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureEleves = loadElevesFromDB(int.parse(widget.seanceId));
                futureEleves.then((loadedEleves) {
                  setState(() {
                    eleves = loadedEleves;
                  });
                });
              });
            },
          ),
        ],
      ),
      body: eleves.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: eleves.length,
              itemBuilder: (context, index) {
                Eleve eleve = eleves[index];
                return ListTile(
                  title: Text('${eleve.nom} ${eleve.prenom}'),
                  subtitle: Text('Classe: ${eleve.classe} | ${eleve.matricule}'),
                  trailing: DropdownButton<String>(
                    value: eleve.statut,
                    items: const [
                      DropdownMenuItem(value: 'Présent', child: Text('Présent')),
                      DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                      DropdownMenuItem(value: 'En retard', child: Text('En retard')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          eleves[index].statut = val;
                        });
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: savePresences,
        child: const Icon(Icons.save),
      ),
    );
  }
}
