import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan de produit'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      drawer: isMobile ? const Drawer(child: NavigationSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) const NavigationSidebar(),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8.0 : 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR code image et bouton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // QR code image grise
                        Container(
                          width: isMobile ? 180 : 250,
                          height: isMobile ? 180 : 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(Icons.qr_code_2,
                                size: 100, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Bouton à droite
                        ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text("Scanner un produit"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 20),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            // Ajoute ici la logique de scan
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Bloc résultat du scan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        "Résultat du scan affiché ici...",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
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
        // Déjà sur la page scan
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
