import 'package:flutter/material.dart';
import 'package:frontend/database_helper.dart';
import 'package:frontend/models/course.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  _CreateCoursePageState createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController(); // Nom de la matière
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialiteController = TextEditingController();
  final TextEditingController _volumeHoraireController = TextEditingController();

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      final newCourse = Course(
        id: _idController.text.trim(), // ici on met le nom de la matière comme identifiant
        nom: _nameController.text,
        specialite: _specialiteController.text,
        volumeHoraire: int.parse(_volumeHoraireController.text),
      );

      try {
        await DatabaseHelper.instance.insertCourse(newCourse);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours créé avec succès')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un cours')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Nom de la matière'),
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ obligatoire' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom du cours'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ obligatoire' : null,
              ),
              TextFormField(
                controller: _volumeHoraireController,
                decoration:
                    const InputDecoration(labelText: 'Volume horaire (heures)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ obligatoire';
                  if (int.tryParse(value) == null) return 'Doit être un nombre';
                  return null;
                },
              ),
              TextFormField(
                controller: _specialiteController,
                decoration: const InputDecoration(labelText: 'Spécialité'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCourse,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
