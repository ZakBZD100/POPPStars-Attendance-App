import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:frontend/models/seance.dart';
import 'package:frontend/models/course.dart';
import 'package:frontend/models/eleves.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/sftp_upload.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Récupérer le dossier local pour stocker app.db
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final localDbPath = '${documentsDirectory.path}/app.db';

    final file = File(localDbPath);

    // Si app.db n'existe pas localement, on le télécharge depuis le serveur SSH
    if (!await file.exists()) {
      debugPrint("app.db non trouvé localement, téléchargement en cours...");
      await downloadFile(
        remotePath: '/data/data_test/app.db', // Chemin du fichier sur ton serveur SSH
        localPath: localDbPath,
      );
    } else {
      debugPrint("app.db trouvé localement.");
    }

    // Maintenant que le fichier app.db est local, on initialise la DB avec
    _database = await _initDB(localDbPath);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE presence (
            seanceId INTEGER NOT NULL,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            statut TEXT NOT NULL,
            PRIMARY KEY(seanceId, nom, prenom),
            FOREIGN KEY(seanceId) REFERENCES seance(id) ON DELETE CASCADE
          )
        ''');

          await db.execute('''
          CREATE TABLE eleves (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            statut TEXT NOT NULL
          )
        ''');
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE cours (
      id TEXT PRIMARY KEY,
      nom TEXT NOT NULL,
      volume_horaire INTEGER NOT NULL,
      specialite TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE seance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      courseId TEXT NOT NULL,
      dateHeure TEXT NOT NULL,
      FOREIGN KEY (courseId) REFERENCES cours(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE presence (
      seanceId INTEGER NOT NULL,
      nom TEXT NOT NULL,
      prenom TEXT NOT NULL,
      statut TEXT NOT NULL,
      PRIMARY KEY(seanceId, nom, prenom),
      FOREIGN KEY(seanceId) REFERENCES seance(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE eleves (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      prenom TEXT NOT NULL,
      statut TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    mdp TEXT NOT NULL,
    role TEXT NOT NULL
  )
''');
  }

  // Méthode IMPORT BASE depuis ASSETS (optionnelle pour dev)
  Future<void> importDBFromAssets(String assetPath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "app.db");

    if (await File(path).exists()) {
      await File(path).delete();
      print("Ancienne base supprimée.");
    }

    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
    print("Nouvelle base copiée.");
  }

  // --- INSERTS & GETTERS (tes méthodes d'origine) ---

  // Insert un cours
  Future<int> insertCourse(Course course) async {
    final db = await database;
    return await db.insert(
      'cours',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer tous les cours
  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await instance.database;
    return await db.query('cours');
  }

  // Insert une séance
  Future<int> insertSeance(Seance seance) async {
    final db = await instance.database;
    return await db.insert(
      'seance',
      {
        'courseId': seance.courseId,
        'dateHeure': seance.dateHeure.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> printAllSeances() async {
    final db = await instance.database;
    final result = await db.query('seance');
    print('Toutes les séances en base : $result');
  }

  Future<List<Map<String, dynamic>>> getSeancesForCourse(String courseId) async {
    final db = await instance.database;
    return await db.query(
      'seance',
      where: 'courseId = ?',
      whereArgs: [courseId],
      orderBy: 'dateHeure ASC',
    );
  }

  // Insert ou update une présence
  Future<int> insertPresence(int seanceId, Eleve eleve) async {
    final db = await database;
    return await db.insert(
      'presence',
      {
        'seanceId': seanceId,
        'nom': eleve.nom,
        'prenom': eleve.prenom,
        'statut': eleve.statut,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getPresencesBySeance(int seanceId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'presence',
      where: 'seanceId = ?',
      whereArgs: [seanceId],
    );

    Map<String, String> presences = {};
    for (var row in results) {
      String key = '${row['prenom']} ${row['nom']}';
      presences[key] = row['statut'];
    }
    return presences;
  }

  Future<List<Map<String, dynamic>>> getEleves() async {
    final db = await instance.database;
    final result = await db.query('eleves');
    return result;
  }

  Future<int> insertEleve(Eleve eleve) async {
    final db = await database;
    return await db.insert(
      'eleves',
      eleve.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Eleve>> getAllEleves() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('eleves');
    return List.generate(maps.length, (i) {
      return Eleve.fromMap(maps[i]);
    });
  }

  // --- Nouveauté : loginUser() ---
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND mdp = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // --- Fermer la DB ---
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<double> getTauxPresenceMoyenPourCours(String courseId) async {
    final db = await database;

    // Récupère toutes les séances pour ce cours
    final seances = await db.query(
      'seance',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );

    int totalPresences = 0;
    int totalEleves = 0;

    for (var seance in seances) {
      final seanceId = seance['id'];

      // Récupère les présences de cette séance
      final presences = await db.query(
        'presence',
        where: 'seanceId = ?',
        whereArgs: [seanceId],
      );

      totalEleves += presences.length;

      for (var p in presences) {
        if (p['statut'] == 'Présent') {
          totalPresences += 1;
        }
      }
    }

    if (totalEleves == 0) {
      return 0.0;
    } else {
      return (totalPresences / totalEleves) * 100;
    }
  }

  Future<double> getTauxPresencePourEleveCours(String courseId, String nom, String prenom) async {
    final db = await database;

    // Récupère toutes les séances pour ce cours
    final seances = await db.query(
      'seance',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );

    int totalSeances = seances.length;
    int seancesPresente = 0;

    for (var seance in seances) {
      final seanceId = seance['id'];

      // Cherche si l'élève a une ligne "Présent" pour cette séance
      final presence = await db.query(
        'presence',
        where: 'seanceId = ? AND nom = ? AND prenom = ?',
        whereArgs: [seanceId, nom, prenom],
      );

      if (presence.isNotEmpty && presence.first['statut'] == 'Présent') {
        seancesPresente += 1;
      }
    }

    if (totalSeances == 0) {
      return 0.0;
    } else {
      return (seancesPresente / totalSeances) * 100;
    }
  }

  Future<List<Map<String, dynamic>>> getPresences() async {
    final db = await database;

    // 1. Récupère tous les cours
    final courses = await db.query('cours');

    List<Map<String, dynamic>> result = [];

    for (var course in courses) {
      final courseId = course['id'];
      final courseName = course['nom'];

      // 2. Récupère toutes les séances pour ce cours
      final seances = await db.query(
        'seance',
        where: 'courseId = ?',
        whereArgs: [courseId],
      );

      int totalPresences = 0;
      int totalEleves = 0;

      for (var seance in seances) {
        final seanceId = seance['id'];

        // 3. Récupère les présences de cette séance
        final presences = await db.query(
          'presence',
          where: 'seanceId = ?',
          whereArgs: [seanceId],
        );

        totalEleves += presences.length;

        for (var p in presences) {
          if (p['statut'] == 'Présent') {
            totalPresences += 1;
          }
        }
      }

      // 4. Calcule le taux
      double taux = 0;
      if (totalEleves > 0) {
        taux = (totalPresences / totalEleves) * 100;
      }

      // 5. Ajoute au résultat
      result.add({
        'cours': courseName,
        'taux': '${taux.toStringAsFixed(1)}%',
      });
    }

    return result;
  }
}