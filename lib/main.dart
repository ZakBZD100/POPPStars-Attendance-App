import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/login_screen.dart';
import 'screens/scolarite_home.dart';
import 'screens/teacher_home.dart';
import 'screens/student_home.dart';
import 'screens/schedule_screen.dart';
import 'screens/stat_cours_page.dart';
import 'screens/stat_eleves_page.dart';
import 'screens/my_courses_page.dart';
import 'screens/create_course_page.dart';
import 'screens/seances_list_page.dart';

import 'screens/placeholder_screen.dart';
import 'models/scolarite_create_user.dart';
import 'models/edt_scolarite.dart';

import 'models/presences.dart';

import 'utils/theme.dart'; // ✅ ajout pour utiliser ton fichier theme.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = (_themeMode == ThemeMode.light)
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POPP',
      theme: AppTheme.lightTheme, // ✅ ton theme clair
      darkTheme: AppTheme.darkTheme, // ✅ ton theme sombre
      themeMode: _themeMode,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(onToggleTheme: _toggleTheme),
        '/scolarite_home': (context) => HomeScolarite(onToggleTheme: _toggleTheme),
        '/teacher_home': (context) => HomeEnseignant(onToggleTheme: _toggleTheme),
        '/student_home': (context) => StudentHome(onToggleTheme: _toggleTheme),
        '/edt': (context) => const ScheduleScreen(),
        '/view_stats': (context) => const StatCoursPage(),
        '/view_stats_eleves': (context) => StatElevePage(),
        '/my_courses': (context) => const MyCoursesPage(),
        '/create_course': (context) => const CreateCoursePage(),
        '/mark_presence': (context) => const SeancesListPage(),

        // --- Routes manquantes pour scolarité :
        '/manage_students': (context) => const PlaceholderScreen(title: 'Gérer les Étudiants'),
        '/manage_classes': (context) => const PlaceholderScreen(title: 'Gérer les Classes'),
        '/generate_reports': (context) => const PlaceholderScreen(title: 'Générer des Rapports'),
        '/school_stats': (context) => const PlaceholderScreen(title: 'Statistiques École'),
        '/edt_scolarite': (context) => const EdtScolariteScreen(),
        '/create_credentials': (context) => const ScolariteCreateUser(),
        '/create_user': (context) => const ScolariteCreateUser(),
        '/settings': (context) => const PlaceholderScreen(title: 'Paramètres'),

        '/presences': (context) => const Presences(),
      },
    );
  }
}
