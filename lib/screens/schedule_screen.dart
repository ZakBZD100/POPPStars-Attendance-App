import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  DateTime selectedDate = DateTime(2025, 6, 2);

  DateTime startDateRange = DateTime(2025, 6, 2);
  DateTime endDateRange = DateTime(2025, 6, 7);

  @override
  void initState() {
    super.initState();
    loadEventsFromICS().then((loadedEvents) {
      setState(() {
        allEvents = loadedEvents;
        filterEventsByDate();
      });
    });
  }

  Future<List<Map<String, dynamic>>> loadEventsFromICS() async {
    try {
      final content = await DefaultAssetBundle.of(context).loadString('assets/edt2.ics');

      final events = <Map<String, dynamic>>[];
      final lines = content.split('\n');
      Map<String, String> currentEvent = {};
      bool inEvent = false;

      DateTime? earliestDate;
      DateTime? latestDate;

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
            DateTime start = parseICalDate(currentEvent['DTSTART']!);
            DateTime end = parseICalDate(currentEvent['DTEND']!);

            String? description = currentEvent['DESCRIPTION'];
            debugPrint("📌 DESCRIPTION brute : ${currentEvent['DESCRIPTION']}");
            String? groupTDTP;
            String? prof;

            if (description != null) {
              String normalized = description.replaceAll(r'\n', '\n').trim();

              List<String> descLines;
              if (normalized.contains('\n')) {
                descLines = normalized.split('\n');
              } else if (normalized.contains('\r\n')) {
                descLines = normalized.split('\r\n');
              } else {
                descLines = normalized.split(' ');
              }

              descLines = descLines.where((line) => line.trim().isNotEmpty).toList();

              debugPrint("ℹ️ Nombre de lignes après split : ${descLines.length}");
              for (var i = 0; i < descLines.length; i++) {
                debugPrint("ligne[$i] = '${descLines[i]}'");
              }

              // Recherche TD ou TP
              for (String line in descLines) {
                if (line.startsWith("TD") || line.startsWith("TP")) {
                  groupTDTP = line.trim();
                  break;
                }
              }
              debugPrint("📝 Groupe TD/TP trouvé : ${groupTDTP ?? 'Aucun'}");

              // Extraction du nom du prof (ligne 1 si elle existe)
              if (descLines.length > 1) {
                prof = descLines[1].trim();
                debugPrint("👨‍🏫 Prof trouvé : $prof");
              }
            }

            events.add({
              'title': currentEvent['SUMMARY']!,
              'start': start,
              'end': end,
              'location': currentEvent['LOCATION'] ?? '',
              'group': groupTDTP ?? '',
              'prof': prof ?? '',
            });

            if (earliestDate == null || start.isBefore(earliestDate)) {
              earliestDate = start;
            }
            if (latestDate == null || end.isAfter(latestDate)) {
              latestDate = end;
            }
          }
        } else if (inEvent && line.contains(':')) {
          final parts = line.split(':');
          final key = parts.first.trim();
          final value = parts.sublist(1).join(':').trim();
          currentEvent[key] = value;
        }
      }

      if (earliestDate != null && latestDate != null) {
        setState(() {
          startDateRange = earliestDate!;
          endDateRange = latestDate!;
        });
      }

      return events;
    } catch (e) {
      debugPrint("Erreur lors du chargement du fichier ICS: $e");
      return [];
    }
  }




  DateTime parseICalDate(String raw) {
    try {
      if (raw.endsWith('Z')) {
        raw = raw.substring(0, raw.length - 1);
      }

      if (raw.length == 8) {
        raw += "T000000";
      }

      return DateTime.parse(raw).add(Duration(hours: 2)); // Ajoute 2 heures à chaque date
    } catch (e) {
      debugPrint("Erreur lors du parsing de la date ICS: $e");
      return DateTime.now();
    }
  }

  void filterEventsByDate() {
    setState(() {
      filteredEvents = allEvents.where((event) {
        final eventDate = event['start'] as DateTime;
        return eventDate.year == selectedDate.year &&
            eventDate.month == selectedDate.month &&
            eventDate.day == selectedDate.day;
      }).toList();

      filteredEvents.sort((a, b) =>
          (a['start'] as DateTime).compareTo(b['start'] as DateTime));
    });
  }

  String formatTimeRange(DateTime start, DateTime end) {
    return '${DateFormat.Hm().format(start)} → ${DateFormat.Hm().format(end)}';
  }

  String formatFullDate(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  List<DateTime> getAvailableDates() {
    List<DateTime> dates = [];
    DateTime current = startDateRange;

    while (current.isBefore(endDateRange) ||
        current.isAtSameMomentAs(endDateRange)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  Widget buildDateSelector() {
    final availableDates = getAvailableDates();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableDates.length,
        itemBuilder: (context, index) {
          final date = availableDates[index];
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                filterEventsByDate();
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400]!,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('fr_FR').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat.d().format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  formatTimeRange(event['start'], event['end']),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if ((event['group'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event['group'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
            ],
            if ((event['prof'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event['prof'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),
            ],
            if ((event['location'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event['location'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emploi du Temps"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: allEvents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Text(
              formatFullDate(selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          buildDateSelector(),
          const Divider(height: 1),
          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(child: Text('Aucun cours ce jour'))
                : ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                return buildEventCard(filteredEvents[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}