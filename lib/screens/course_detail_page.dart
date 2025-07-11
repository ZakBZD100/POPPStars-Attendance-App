import 'package:flutter/material.dart';
import 'package:frontend/database_helper.dart';
import 'package:frontend/models/seance.dart';
import 'package:frontend/screens/seance_page.dart';
import 'package:intl/intl.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Future<List<Seance>> _seancesFuture;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  Future<void> _loadSeances() async {
    setState(() {
      _seancesFuture = _fetchSeances();
    });
  }

  Future<List<Seance>> _fetchSeances() async {
    final maps = await DatabaseHelper.instance.getSeancesForCourse(widget.courseId);
    return maps.map((map) => Seance.fromMap(map)).toList();
  }

  Future<void> _createSeance() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final newSeance = Seance(
      courseId: widget.courseId,
      dateHeure: newDateTime,
    );

    await DatabaseHelper.instance.insertSeance(newSeance);
    _loadSeances();
  }

  void _navigateToSeancePage(Seance seance) {
    if (seance.id == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeancePage(seanceId: seance.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Séances pour ce cours',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Seance>>(
              future: _seancesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Erreur de chargement'));
                }

                final seances = snapshot.data!;
                if (seances.isEmpty) {
                  return const Center(child: Text('Aucune séance programmée'));
                }

                return ListView.builder(
                  itemCount: seances.length,
                  itemBuilder: (context, index) {
                    final seance = seances[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(_dateFormat.format(seance.dateHeure)),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _navigateToSeancePage(seance),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createSeance,
        tooltip: 'Ajouter une séance',
        child: const Icon(Icons.add),
      ),
    );
  }
}