import 'package:flutter/material.dart';


class Edt extends StatelessWidget {
  const Edt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Emploi du temps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 30),
            onPressed: () {
              // Action to perform on logout
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'EDT',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}