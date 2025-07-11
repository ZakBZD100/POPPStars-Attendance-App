import 'package:flutter/material.dart';
import 'package:frontend/screens/student_home.dart';
import 'package:frontend/screens/teacher_home.dart';
import 'package:frontend/screens/scolarite_home.dart';
import 'package:frontend/models/session.dart';
import 'package:frontend/utils/dialog_utils.dart';
import 'package:frontend/widgets/custom_action_card.dart'; // On utilise CustomActionCard

class HomeAdmin extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomeAdmin({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Tableau de Bord Admin',
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
                crossAxisCount: 1,
                mainAxisSpacing: 20,
                childAspectRatio: 3.5,
                children: [
                  CustomActionCard(
                    icon: Icons.school,
                    title: 'Voir comme Étudiant',
                    color: colors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentHome(onToggleTheme: onToggleTheme),
                      ),
                    ),
                  ),
                  CustomActionCard(
                    icon: Icons.person,
                    title: 'Voir comme Enseignant',
                    color: Colors.orange.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeEnseignant(onToggleTheme: onToggleTheme),
                      ),
                    ),
                  ),
                  CustomActionCard(
                    icon: Icons.admin_panel_settings,
                    title: 'Voir comme Scolarité',
                    color: Colors.green.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScolarite(onToggleTheme: onToggleTheme),
                      ),
                    ),
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
