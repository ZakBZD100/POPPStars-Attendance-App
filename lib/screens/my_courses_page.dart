import 'package:flutter/material.dart';
import 'create_seance_page.dart';
import 'package:frontend/database_helper.dart';
import 'course_detail_page.dart';
import 'create_course_page.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  late Future<List<Map<String, dynamic>>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    _coursesFuture = DatabaseHelper.instance.getCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Cours'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun cours trouvé.'));
          } else {
            final courses = snapshot.data!;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text('${course['id']}'), // Nom de la matière
                    subtitle: Text(
                        'Nom du cours : ${course['nom']}\nSpécialité : ${course['specialite']}\nVolume horaire : ${course['volume_horaire']}h'),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      child: const Text('Créer séance'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateSeancePage(
                              courseId: course['id'],
                              courseName: course['nom'],
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(
                            courseId: course['id'],
                            courseName: course['nom'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCoursePage()),
          );

          if (result == true) {
            setState(() {
              _loadCourses();
            });
          }
        },
        tooltip: 'Créer un nouveau cours',
        child: const Icon(Icons.add),
      ),
    );
  }
}
