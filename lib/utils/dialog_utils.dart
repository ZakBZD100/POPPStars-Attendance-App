import 'package:flutter/material.dart';

Future<void> showLogoutConfirmationDialog(BuildContext context, VoidCallback onConfirmLogout) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmation de déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop(false); // Annuler
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Se déconnecter'),
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmer
            },
          ),
        ],
      );
    },
  );

  if (result == true) {
    onConfirmLogout();
  }
}