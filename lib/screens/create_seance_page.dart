import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/database_helper.dart';
import 'package:frontend/models/seance.dart';

class CreateSeancePage extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CreateSeancePage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CreateSeancePage> createState() => _CreateSeancePageState();
}

class _CreateSeancePageState extends State<CreateSeancePage> {
  DateTime? _selectedDateTime;

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveSeance() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date et une heure.')),
      );
      return;
    }

    final newSeance = Seance(
      courseId: widget.courseId,
      dateHeure: _selectedDateTime!,
    );

    int result = await DatabaseHelper.instance.insertSeance(newSeance);

    if (result != 0) {
      Navigator.pop(context, true);  // envoie "true" en retournant
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une séance pour ${widget.courseName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectDateTime,
              child: const Text('Choisir date et heure'),
            ),
            const SizedBox(height: 16),
            if (_selectedDateTime != null)
              Text(
                'Séance prévue le : ${dateFormat.format(_selectedDateTime!)}',
                style: const TextStyle(fontSize: 16),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _saveSeance,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la séance'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}