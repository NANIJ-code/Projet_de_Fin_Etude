import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  bool autoUpdate = true;
  String language = 'fr';
  bool biometricAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                "Préférences générales",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Notifications"),
                subtitle: const Text("Recevoir des alertes sur les produits suspects"),
                value: notificationsEnabled,
                onChanged: (v) => setState(() => notificationsEnabled = v),
              ),
              SwitchListTile(
                title: const Text("Mode sombre"),
                subtitle: const Text("Réduit la fatigue visuelle"),
                value: darkMode,
                onChanged: (v) => setState(() => darkMode = v),
              ),
              SwitchListTile(
                title: const Text("Mise à jour automatique"),
                subtitle: const Text("Mettre à jour la base de données produits"),
                value: autoUpdate,
                onChanged: (v) => setState(() => autoUpdate = v),
              ),
              const Divider(height: 32),
              const Text(
                "Sécurité",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Authentification biométrique"),
                subtitle: const Text("Déverrouiller l'application avec empreinte ou Face ID"),
                value: biometricAuth,
                onChanged: (v) => setState(() => biometricAuth = v),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text("Changer le mot de passe"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Ajoute ici la navigation vers la page de changement de mot de passe
                },
              ),
              const Divider(height: 32),
              const Text(
                "Langue",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: language,
                decoration: const InputDecoration(
                  labelText: "Langue de l'application",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'en', child: Text('Anglais')),
                  DropdownMenuItem(value: 'ar', child: Text('Arabe')),
                ],
                onChanged: (v) => setState(() => language = v ?? 'fr'),
              ),
              const Divider(height: 32),
              const Text(
                "À propos",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("Version de l'application"),
                subtitle: const Text("1.0.0"),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text("Politique de confidentialité"),
                onTap: () {
                  // Ajoute ici la navigation vers la politique de confidentialité
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Se déconnecter"),
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                  ),
                  onPressed: null, // Remplace par ta logique si besoin
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}