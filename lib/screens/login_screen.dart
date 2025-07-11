import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:frontend/screens/student_home.dart';
import 'package:frontend/screens/teacher_home.dart';
import 'package:frontend/screens/scolarite_home.dart';
import 'package:frontend/screens/admin_home.dart';
import 'package:frontend/models/sftp_upload.dart';
import 'package:path_provider/path_provider.dart';

const String remoteUserFile = '/data/data_test/user.txt';
late String localUserFile;

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController identifiantController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _obscurePassword = true;

  double screenHeight = 0;
  double screenWidth = 0;

  @override
  void initState() {
    super.initState();
    prepareLocalUserFile();
  }

  Future<void> prepareLocalUserFile() async {
    final directory = await getApplicationDocumentsDirectory();
    localUserFile = '${directory.path}/user.txt';
  }

  void _handleLogin() async {
    String identifiant = identifiantController.text.trim();
    String password = passController.text.trim();

    if (_checkHardcodedCredentials(identifiant, password)) return;

    await verifyUpload(remoteUserFile);
    await downloadFile(remotePath: remoteUserFile, localPath: localUserFile);

    Map<String, String>? user = await _getUserFromLocalFile(identifiant);
    if (user != null && user["mdp"] == password) {
      _redirectUser(user["role"]);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Identifiant ou mot de passe incorrect.")),
    );
  }

  bool _checkHardcodedCredentials(String identifiant, String password) {
    final Map<String, Widget> staticUsers = {
      'etudiant@popp.app': StudentHome(onToggleTheme: widget.onToggleTheme),
      'enseignant@popp.app': HomeEnseignant(onToggleTheme: widget.onToggleTheme),
      'scolarite@popp.app': HomeScolarite(onToggleTheme: widget.onToggleTheme),
      'admin@popp.app': HomeAdmin(onToggleTheme: widget.onToggleTheme),
    };

    if (staticUsers.containsKey(identifiant) && password == identifiant.split('@')[0]) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => staticUsers[identifiant]!));
      return true;
    }

    return false;
  }

  Future<Map<String, String>?> _getUserFromLocalFile(String identifiant) async {
    try {
      final file = File(localUserFile);
      if (!file.existsSync()) {
        debugPrint("❌ Le fichier `user.txt` téléchargé n'existe pas !");
        return null;
      }

      final lines = await file.readAsLines();

      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        if (line.startsWith("ID:")) continue; // Ignorer la première ligne

        final parts = line.trim().split(' ');
        if (parts.length < 3) continue;

        final email = parts[0];
        final mdp = parts[1];
        final role = parts.sublist(2).join(' '); // gérer les rôles à plusieurs mots

        if (email == identifiant) {
          debugPrint("✅ Utilisateur trouvé : $email, rôle : $role");
          return {"email": email, "mdp": mdp, "role": role};
        }
      }
    } catch (e) {
      debugPrint("❌ Erreur de lecture du fichier local `user.txt` : $e");
    }
    return null;
  }

  void _redirectUser(String? role) {
    Map<String, Widget> roleMapping = {
      'Etudiant': StudentHome(onToggleTheme: widget.onToggleTheme),
      'Enseignant': HomeEnseignant(onToggleTheme: widget.onToggleTheme),
      'Scolarite': HomeScolarite(onToggleTheme: widget.onToggleTheme),
      'Admin': HomeAdmin(onToggleTheme: widget.onToggleTheme),
    };

    if (roleMapping.containsKey(role)) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => roleMapping[role]!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Rôle inconnu : $role")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isKeyboardVisible)
                    Container(
                      width: double.infinity,
                      height: screenHeight / 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xff173c6d),
                            const Color(0xff0f2b4c),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/logo_popp.png',
                              width: screenWidth / 2.4,
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(Icons.brightness_6),
                              color: Colors.white,
                              onPressed: widget.onToggleTheme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 25),
                  Text(
                    "Bienvenue sur POPP 🎓",
                    style: TextStyle(
                      fontSize: screenWidth / 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple.shade200
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: screenWidth / 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.purple.shade200
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fieldTitle("Identifiant"),
                        customField("Identifiant", identifiantController, false, Icons.person),
                        fieldTitle("Mot de passe"),
                        customField("Mot de passe", passController, _obscurePassword, Icons.lock, isPassword: true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: _handleLogin,
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              fontSize: screenWidth / 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              "Propulsé par POPPstars",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.purple.shade200
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget customField(String hint, TextEditingController controller, bool obscure, IconData icon, {bool isPassword = false}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDarkMode ? Colors.white : Theme.of(context).primaryColor;

    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.white24 : Colors.black26,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth / 6,
            child: Icon(
              icon,
              color: iconColor,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isPassword ? 0 : screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: !isPassword,
                autocorrect: !isPassword,
                obscureText: obscure,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: screenHeight / 35),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: isPassword
                      ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
