import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      drawer: isMobile ? const Drawer(child: NavigationSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) const NavigationSidebar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Text(
                      "Préférences générales",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    const SwitchListTile(
                      title: Text("Notifications"),
                      subtitle: Text(
                          "Recevoir des alertes sur les produits suspects"),
                      value: true,
                      onChanged: null,
                    ),
                    const SwitchListTile(
                      title: Text("Mode sombre"),
                      subtitle: Text("Réduit la fatigue visuelle"),
                      value: false,
                      onChanged: null,
                    ),
                    const SwitchListTile(
                      title: Text("Mise à jour automatique"),
                      subtitle:
                          Text("Mettre à jour la base de données produits"),
                      value: true,
                      onChanged: null,
                    ),
                    const Divider(height: 32),
                    const Text(
                      "Sécurité",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    const SwitchListTile(
                      title: Text("Authentification biométrique"),
                      subtitle: Text(
                          "Déverrouiller l'application avec empreinte ou Face ID"),
                      value: false,
                      onChanged: null,
                    ),
                    const ListTile(
                      leading: Icon(Icons.lock_outline),
                      title: Text("Changer le mot de passe"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    const Divider(height: 32),
                    const Text(
                      "Langue",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 32),
                    const Text(
                      "À propos",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("Version de l'application"),
                      subtitle: Text("1.0.0"),
                    ),
                    const ListTile(
                      leading: Icon(Icons.privacy_tip_outlined),
                      title: Text("Politique de confidentialité"),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text("Se déconnecter"),
                        style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.redAccent),
                          foregroundColor:
                              WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sidebar complète avec navigation
class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(Icons.space_dashboard_outlined, "Dashboard", () {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }),
      _NavItem(Icons.qr_code_2_rounded, "Scan", () {
        Navigator.of(context).pushReplacementNamed('/scan');
      }),
      _NavItem(Icons.account_circle_outlined, "Utilisateur", () {
        Navigator.of(context).pushReplacementNamed('/user');
      }),
      _NavItem(Icons.inventory_2_outlined, "Produits", () {
        Navigator.of(context).pushReplacementNamed('/product');
      }),
      _NavItem(Icons.notifications_active_outlined, "Alertes", () {
        Navigator.of(context).pushReplacementNamed('/alerts');
      }),
      _NavItem(Icons.settings, "Paramètres", () {
        // Déjà sur la page paramètres
      }),
    ];

    return Container(
      width: 220,
      color: const Color(0xFF1976D2),
      child: Column(
        children: [
          const SizedBox(height: 32),
          ...navItems.map((item) => ListTile(
                leading: Icon(item.icon, color: Colors.white),
                title: Text(item.label,
                    style: const TextStyle(color: Colors.white)),
                onTap: item.onTap,
              )),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.icon, this.label, this.onTap);
}
