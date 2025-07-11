import 'package:intl/intl.dart';

class ICSParser {
  static List<Map<String, dynamic>> parseICS(String icsContent) {
    final events = <Map<String, dynamic>>[];
    final lines = icsContent.split('\n');
    Map<String, String> currentEvent = {};
    bool inEvent = false;

    for (var line in lines) {
      line = line.trim();

      if (line == 'BEGIN:VEVENT') {
        inEvent = true;
        currentEvent = {};
      } else if (line == 'END:VEVENT') {
        inEvent = false;

        if (currentEvent.containsKey('SUMMARY') &&
            currentEvent.containsKey('DTSTART') &&
            currentEvent.containsKey('DTEND')) {

          DateTime start = _parseICalDate(currentEvent['DTSTART']!);
          DateTime end = _parseICalDate(currentEvent['DTEND']!);

          String? description = currentEvent['DESCRIPTION'];
          String? groupTDTP;
          String? prof;

          if (description != null) {
            String normalized = description.replaceAll(r'\n', '\n').trim();
            List<String> descLines = normalized.split('\n');
            descLines = descLines.where((line) => line.trim().isNotEmpty).toList();

            // Recherche TD ou TP
            for (String line in descLines) {
              if (line.startsWith("TD") || line.startsWith("TP")) {
                groupTDTP = line.trim();
                break;
              }
            }

            // Extraction du nom du prof
            if (descLines.length > 1) {
              prof = descLines[1].trim();
            }
          }

          events.add({
            'summary': currentEvent['SUMMARY']!,
            'start': start,
            'end': end,
            'location': currentEvent['LOCATION'] ?? '',
            'description': description ?? '',
            'group': groupTDTP ?? '',
            'prof': prof ?? '',
          });
        }
      } else if (inEvent && line.contains(':')) {
        final parts = line.split(':');
        final key = parts.first.trim();
        final value = parts.sublist(1).join(':').trim();
        currentEvent[key] = value;
      }
    }

    return events;
  }

  static DateTime _parseICalDate(String raw) {
    try {
      if (raw.endsWith('Z')) {
        raw = raw.substring(0, raw.length - 1);
      }
      if (raw.length == 8) {
        raw += "T000000";
      }
      return DateTime.parse(raw).add(Duration(hours: 2));
    } catch (e) {
      return DateTime.now();
    }
  }

  static String formatEventTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}