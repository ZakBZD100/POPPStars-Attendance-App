import 'package:flutter/material.dart';
import 'package:frontend/models/session.dart';
import 'package:frontend/utils/dialog_utils.dart';
import 'package:frontend/widgets/custom_action_card.dart'; // On utilise CustomActionCard

class HomeScolarite extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeScolarite({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Tableau de Bord Scolarité',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        backgroundColor: colors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 25),
            onPressed: () {
              showLogoutConfirmationDialog(context, () {
                Session.userId = null;
                Navigator.pushNamed(context, '/login');
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.2,
                children: [
                  CustomActionCard(
                    icon: Icons.calendar_today,
                    title: 'Emplois du Temps',
                    color: Colors.purple.shade600,
                    onTap: () => Navigator.pushNamed(context, '/edt_scolarite'),
                  ),
                  CustomActionCard(
                    icon: Icons.person_add,
                    title: 'Créer identifiants',
                    color: Colors.green.shade600,
                    onTap: () => Navigator.pushNamed(context, '/create_credentials'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
