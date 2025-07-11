import 'package:flutter/material.dart';
import 'package:frontend/models/eleves.dart';
import 'package:frontend/database_helper.dart';
import 'package:frontend/models/eleve_loader.dart';

class SeancePage extends StatefulWidget {
  final int seanceId;

  const SeancePage({super.key, required this.seanceId});

  @override
  _SeancePageState createState() => _SeancePageState();
}

class _SeancePageState extends State<SeancePage> {
  late Future<List<Eleve>> _elevesFuture;
  final Map<String, String> _presences = {};

  @override
  void initState() {
    super.initState();
    _loadEleves();
  }

  Future<void> _loadEleves() async {
    setState(() {
      _elevesFuture = _fetchElevesWithPresences();
    });
  }

  Future<List<Eleve>> _fetchElevesWithPresences() async {
    try {
      final eleves = await loadElevesFromCSV();
      final presences = await DatabaseHelper.instance.getPresencesBySeance(widget.seanceId);

      for (final eleve in eleves) {
        final key = '${eleve.prenom} ${eleve.nom}';
        eleve.statut = presences[key] ?? 'Absent';
        _presences[key] = eleve.statut;
      }

      return eleves;
    } catch (e) {
      print('Erreur de chargement: $e');
      return [];
    }
  }

  Future<void> _savePresences() async {
    try {
      final eleves = await _elevesFuture;

      for (var eleve in eleves) {
        final key = '${eleve.prenom} ${eleve.nom}';
        final statut = _presences[key] ?? 'Absent';
        eleve.statut = statut;

        await DatabaseHelper.instance.insertPresence(widget.seanceId, eleve);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Présences enregistrées!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Séance #${widget.seanceId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEleves,
          ),
        ],
      ),
      body: FutureBuilder<List<Eleve>>(
        future: _elevesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final eleves = snapshot.data ?? [];
          if (eleves.isEmpty) {
            return const Center(child: Text('Aucun élève trouvé'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: eleves.length,
                  itemBuilder: (context, index) {
                    final eleve = eleves[index];
                    final key = '${eleve.prenom} ${eleve.nom}';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text('${eleve.prenom} ${eleve.nom}'),
                        subtitle: Text('Classe: ${eleve.classe} | ${eleve.matricule}'),
                        trailing: DropdownButton<String>(
                          value: _presences[key],
                          items: ['Présent', 'Absent', 'En retard'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _presences[key] = newValue!;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  onPressed: _savePresences,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}