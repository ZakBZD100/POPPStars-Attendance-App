import 'package:flutter/material.dart';
import 'package:frontend/database_helper.dart';

class Presences extends StatefulWidget {
  const Presences({super.key});

  @override
  State<Presences> createState() => _PresencesState();
}

class _PresencesState extends State<Presences> {
  List<Map<String, dynamic>> presences = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DatabaseHelper.instance.getPresences();
    setState(() {
      presences = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Présences')),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: presences.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: presences.length,
              itemBuilder: (context, index) {
                final item = presences[index];
                return Card(
                  child: ListTile(
                    title: Text(item['cours']),
                    trailing: Text('Présence : ${item['taux']}'),
                  ),
                );
              },
            ),
    );
  }
}