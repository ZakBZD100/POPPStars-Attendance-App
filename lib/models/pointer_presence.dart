import 'package:flutter/material.dart';
import 'package:frontend/database_helper.dart';
import 'package:frontend/screens/course_detail_page.dart';

class PointerPresencePage extends StatefulWidget {
  const PointerPresencePage({super.key});

  @override
  _PointerPresencePageState createState() => _PointerPresencePageState();
}

class _PointerPresencePageState extends State<PointerPresencePage> {
  late Future<List<Map<String, dynamic>>> _coursesFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _coursesFuture = _dbHelper.getCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Présences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(child: Text('Aucun cours disponible'));
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    course['nom']?.toString() ?? 'Cours sans nom',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'ID: ${course['id']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _navigateToCourseDetail(context, course),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToCourseDetail(BuildContext context, Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(
          courseId: course['id'].toString(),
          courseName: course['nom']?.toString() ?? 'Cours sans nom',
        ),
      ),
    );
  }
}