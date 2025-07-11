import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'sftp_upload.dart';

class ScolariteCreateUser extends StatefulWidget {
  const ScolariteCreateUser({super.key});

  @override
  State<ScolariteCreateUser> createState() => _ScolariteCreateUserState();
}

class _ScolariteCreateUserState extends State<ScolariteCreateUser> {
  final _formKey = GlobalKey<FormState>();

  String? id, nom, prenom, email, mdp, role;
  final List<String> roles = ['Enseignant', 'Etudiant'];
  final List<String> specialite = ['Informatique et Réseau', 'Automatique & Systèmes Embarqués', 'Textile & Fibres', 'Mécanique, Génie Industriel'];
  final List<String> td = ['td1', 'td2'];
  final List<String> tp = ['tp1', 'tp2', 'tp3'];
  String? specialiteValue, tdValue, tpValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(label: 'ID', onSaved: (val) => id = val),
              _buildTextField(label: 'Nom', onSaved: (val) => nom = val),
              _buildTextField(label: 'Prénom', onSaved: (val) => prenom = val),
              _buildTextField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val,
                validator: (val) => val != null && val.contains('@') ? null : 'Email invalide',
              ),
              _buildTextField(
                label: 'Mot de passe',
                obscureText: true,
                onSaved: (val) => mdp = val,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Rôle'),
                value: role,
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => role = val),
                validator: (val) => val == null ? 'Veuillez sélectionner un rôle' : null,
              ),
              if (role == 'Etudiant') ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Spécialité'),
                  value: specialiteValue,
                  items: specialite.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => specialiteValue = val),
                  validator: (val) => val == null ? 'Veuillez sélectionner une spécialité' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'TD'),
                  value: tdValue,
                  items: td.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => tdValue = val),
                  validator: (val) => val == null ? 'Veuillez sélectionner un TD' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'TP'),
                  value: tpValue,
                  items: tp.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => tpValue = val),
                  validator: (val) => val == null ? 'Veuillez sélectionner un TP' : null,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Créer identifiant'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    try {
                      final directory = await getApplicationDocumentsDirectory();
                      final localPath = '${directory.path}/user.txt';
                      final file = File(localPath);

                      final userData = '$email $mdp $role\n';
                      print("📄 Données utilisateur à écrire : $userData");

                      await file.writeAsString(userData, mode: FileMode.append, flush: true);

                      final content = await file.readAsString();
                      print("✅ Contenu local de user.txt :\n$content");

                      await uploadFile(
                        localPath: localPath,
                        remotePath: '/data/data_test/user.txt',
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Identifiant créé et sauvegardé sur le serveur !')),
                      );

                      _formKey.currentState!.reset();
                      setState(() {
                        role = null;
                        specialiteValue = null;
                        tdValue = null;
                        tpValue = null;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur : $e")),
                      );
                    }

                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
