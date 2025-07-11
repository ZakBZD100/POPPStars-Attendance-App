import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/ics_parser.dart';
import 'package:frontend/models/custom_events_storage.dart';
import 'package:intl/intl.dart';

class EdtScolariteScreen extends StatefulWidget {
  const EdtScolariteScreen({super.key});

  @override
  _EdtScolariteScreenState createState() => _EdtScolariteScreenState();
}

class _EdtScolariteScreenState extends State<EdtScolariteScreen> {
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  List<Map<String, dynamic>> customEvents = [];
  DateTime selectedDate = DateTime(2025, 6, 2);
  DateTime startDateRange = DateTime(2025, 6, 2);
  DateTime endDateRange = DateTime(2025, 6, 7);
  bool _showFreeSlots = true; // Activé par défaut pour la scolarité

  final List<Map<String, String>> standardTimeSlots = [
    {'start': '08:00', 'end': '10:00'},
    {'start': '10:00', 'end': '12:00'},
    {'start': '12:00', 'end': '14:00'},
    {'start': '14:00', 'end': '16:00'},
    {'start': '16:00', 'end': '18:00'},
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await _loadICSEvents();
    await _loadCustomEvents();
    filterEventsByDate();
  }

  Future<void> _loadICSEvents() async {
    try {
      final icsString = await rootBundle.loadString('assets/edt2.ics');
      final events = ICSParser.parseICS(icsString);

      DateTime? earliestDate;
      DateTime? latestDate;

      for (var event in events) {
        DateTime start = event['start'];
        DateTime end = event['end'];

        if (earliestDate == null || start.isBefore(earliestDate)) {
          earliestDate = start;
        }
        if (latestDate == null || end.isAfter(latestDate)) {
          latestDate = end;
        }
      }

      setState(() {
        allEvents = events;
        if (earliestDate != null && latestDate != null) {
          startDateRange = earliestDate;
          endDateRange = latestDate;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadCustomEvents() async {
    customEvents = await CustomEventsStorage.loadCustomEvents();
    setState(() {});
  }

  void filterEventsByDate() {
    List<Map<String, dynamic>> dayEvents = [];

    // Événements ICS
    dayEvents.addAll(allEvents.where((event) {
      final eventDate = event['start'] as DateTime;
      return eventDate.year == selectedDate.year &&
          eventDate.month == selectedDate.month &&
          eventDate.day == selectedDate.day;
    }));

    // Événements personnalisés
    dayEvents.addAll(customEvents.where((event) {
      final eventDate = event['start'] as DateTime;
      return eventDate.year == selectedDate.year &&
          eventDate.month == selectedDate.month &&
          eventDate.day == selectedDate.day;
    }));

    // Créneaux libres si demandés
    if (_showFreeSlots) {
      dayEvents.addAll(_getFreeSlots(selectedDate));
    }

    setState(() {
      filteredEvents = dayEvents;
      filteredEvents.sort((a, b) => (a['start'] as DateTime).compareTo(b['start'] as DateTime));
    });
  }

  List<Map<String, dynamic>> _getFreeSlots(DateTime day) {
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return [];
    }

    final dayEvents = _getAllEventsForDay(day);
    List<Map<String, dynamic>> freeSlots = [];

    for (var slot in standardTimeSlots) {
      DateTime slotStart = DateTime(
        day.year,
        day.month,
        day.day,
        int.parse(slot['start']!.split(':')[0]),
        int.parse(slot['start']!.split(':')[1]),
      );
      DateTime slotEnd = DateTime(
        day.year,
        day.month,
        day.day,
        int.parse(slot['end']!.split(':')[0]),
        int.parse(slot['end']!.split(':')[1]),
      );

      // ⚠️ Chevauchement intelligent
      bool isOccupied = dayEvents.any((event) {
        DateTime eventStart = event['start'];
        DateTime eventEnd = event['end'];

        return !(eventEnd.isAtSameMomentAs(slotStart) || eventEnd.isBefore(slotStart) ||
            eventStart.isAtSameMomentAs(slotEnd) || eventStart.isAfter(slotEnd));
      });

      if (!isOccupied) {
        freeSlots.add({
          'summary': 'Créneau libre',
          'start': slotStart,
          'end': slotEnd,
          'location': '',
          'description': '',
          'group': '',
          'prof': '',
          'isFree': true,
        });
      }
    }

    return freeSlots;
  }


  List<Map<String, dynamic>> _getAllEventsForDay(DateTime day) {
    List<Map<String, dynamic>> dayEvents = [];

    dayEvents.addAll(allEvents.where((event) {
      final eventDate = event['start'] as DateTime;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }));

    dayEvents.addAll(customEvents.where((event) {
      final eventDate = event['start'] as DateTime;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }));

    return dayEvents;
  }

// Remplace ton _showAddEventDialog par celui-ci
  void _showAddEventDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController profController = TextEditingController();
    final TextEditingController groupController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    String selectedTimeSlot =
        '${standardTimeSlots.first['start']!}-${standardTimeSlots.first['end']!}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un créneau'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du cours',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: profController,
                  decoration: const InputDecoration(
                    labelText: 'Professeur',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: groupController,
                  decoration: const InputDecoration(
                    labelText: 'Groupe (TD/TP)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Lieu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTimeSlot,
                  decoration: const InputDecoration(
                    labelText: 'Horaire',
                    border: OutlineInputBorder(),
                  ),
                  items: standardTimeSlots.map((slot) {
                    String timeSlot = '${slot['start']!}-${slot['end']!}';
                    return DropdownMenuItem(
                      value: timeSlot,
                      child: Text('${slot['start']} → ${slot['end']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedTimeSlot = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom du cours est obligatoire')),
                  );
                  return;
                }

                List<String> timeParts = selectedTimeSlot.split('-');
                List<String> startTime = timeParts[0].split(':');
                List<String> endTime = timeParts[1].split(':');

                DateTime eventStart = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  int.parse(startTime[0]),
                  int.parse(startTime[1]),
                );

                DateTime eventEnd = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  int.parse(endTime[0]),
                  int.parse(endTime[1]),
                );

                // ⚠️ Vérifie chevauchement
                bool overlaps = _getAllEventsForDay(selectedDate).any((event) {
                  DateTime existingStart = event['start'];
                  DateTime existingEnd = event['end'];
                  String existingGroup = (event['group'] ?? '').trim().toLowerCase();
                  String newGroup = groupController.text.trim().toLowerCase();

                  // Si même groupe et chevauchement → interdit
                  if (existingGroup.isNotEmpty && existingGroup == newGroup) {
                    return !(existingEnd.isAtSameMomentAs(eventStart) || existingEnd.isBefore(eventStart) ||
                        existingStart.isAtSameMomentAs(eventEnd) || existingStart.isAfter(eventEnd));
                  }
                  return false;
                });


                if (overlaps) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Un autre cours existe déjà sur ce créneau')),
                  );
                  return;
                }

                Map<String, dynamic> newEvent = {
                  'summary': titleController.text.trim(),
                  'start': eventStart,
                  'end': eventEnd,
                  'location': locationController.text.trim(),
                  'description': '',
                  'group': groupController.text.trim(),
                  'prof': profController.text.trim(),
                  'isCustom': true,
                };

                customEvents.add(newEvent);
                await CustomEventsStorage.saveCustomEvents(customEvents);
                filterEventsByDate();

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Créneau ajouté avec succès')),
                );
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }


  void _deleteEvent(Map<String, dynamic> event) {
    if (event['isCustom'] == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Supprimer le créneau'),
            content: Text('Êtes-vous sûr de vouloir supprimer "${event['summary']}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  customEvents.removeWhere((e) =>
                  e['summary'] == event['summary'] &&
                      e['start'] == event['start'] &&
                      e['end'] == event['end']
                  );
                  await CustomEventsStorage.saveCustomEvents(customEvents);
                  filterEventsByDate();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Créneau supprimé')),
                  );
                },
                child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seuls les créneaux personnalisés peuvent être supprimés')),
      );
    }
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

    while (current.isBefore(endDateRange) || current.isAtSameMomentAs(endDateRange)) {
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
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
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
    bool isFree = event['isFree'] == true;
    bool isCustom = event['isCustom'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      color: isFree ? Colors.green[50] : (isCustom ? Colors.blue[50] : null),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isFree ? Icons.free_breakfast : Icons.access_time,
                      size: 16,
                      color: isFree ? Colors.green : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTimeRange(event['start'], event['end']),
                      style: TextStyle(
                        color: isFree ? Colors.green : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (!isFree) // Ne pas afficher les actions pour les créneaux libres
                  Row(
                    children: [
                      if (isCustom)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteEvent(event),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event['summary'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isFree ? Colors.green[700] : null,
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
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event['location'],
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
            if (isCustom) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Personnalisé',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        title: const Text("Gestion Emploi du Temps - Scolarité"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showFreeSlots ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showFreeSlots = !_showFreeSlots;
                filterEventsByDate();
              });
            },
            tooltip: _showFreeSlots ? 'Masquer créneaux libres' : 'Afficher créneaux libres',
          ),
        ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Ajouter un créneau',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}