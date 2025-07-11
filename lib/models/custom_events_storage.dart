import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class CustomEventsStorage {
  static const _fileName = 'custom_events.json';

  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<List<Map<String, dynamic>>> loadCustomEvents() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      return jsonList.map<Map<String, dynamic>>((e) {
        return {
          ...e,
          'start': DateTime.parse(e['start']),
          'end': DateTime.parse(e['end']),
        };
      }).toList();
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      return [];
    }
  }

  static Future<void> saveCustomEvents(List<Map<String, dynamic>> events) async {
    try {
      final file = await _getLocalFile();
      final List<Map<String, dynamic>> serializable = events.map((e) {
        return {
          ...e,
          'start': (e['start'] as DateTime).toIso8601String(),
          'end': (e['end'] as DateTime).toIso8601String(),
        };
      }).toList();

      await file.writeAsString(jsonEncode(serializable));
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
    }
  }
}