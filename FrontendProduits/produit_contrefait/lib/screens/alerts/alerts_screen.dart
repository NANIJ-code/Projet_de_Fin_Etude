import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final List<Map<String, dynamic>> alerts = [
      {
        "type": "Produit suspect",
        "icon": Icons.warning_amber_rounded,
        "color": Colors.orange,
        "date": "30/05/2025 14:32",
        "description": "Un produit scanné présente des anomalies de code-barres."
      },
      {
        "type": "Produit contrefait",
        "icon": Icons.block,
        "color": Colors.redAccent,
        "date": "29/05/2025 10:12",
        "description": "Un produit a été bloqué suite à une détection de contrefaçon."
      },
      {
        "type": "Information",
        "icon": Icons.info_outline,
        "color": Colors.blue,
        "date": "28/05/2025 09:00",
        "description": "Nouvelle mise à jour de la base de données produits."
      },
      {
        "type": "Sécurité",
        "icon": Icons.verified_user,
        "color": Colors.green,
        "date": "27/05/2025 18:45",
        "description": "Authentification biométrique activée pour un utilisateur."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      drawer: isMobile ? const Drawer(child: NavigationSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) const NavigationSidebar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Alertes & notifications",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Retrouvez ici toutes les alertes de sécurité, notifications système et événements récents.",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: alerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final alert = alerts[i];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (alert["color"] as Color).withAlpha(38),
                              child: Icon(alert["icon"] as IconData, color: alert["color"] as Color),
                            ),
                            title: Text(
                              alert["type"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: alert["color"] as Color,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert["description"],
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert["date"],
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // Actions supplémentaires (archiver, supprimer, etc.)
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Toutes les alertes sont traitées avec la plus grande confidentialité.",
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
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
        // Déjà sur la page alertes
      }),
      _NavItem(Icons.settings, "Paramètres", () {
        Navigator.of(context).pushReplacementNamed('/settings');
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