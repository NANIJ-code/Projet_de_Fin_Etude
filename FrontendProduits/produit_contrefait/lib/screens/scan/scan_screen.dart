import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MaterialApp(home: QrScanPage()));
}

class QrScanPage extends StatelessWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR: ${barcode.rawValue}')),
          );
        },
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

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? scanResult;

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
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const QrScanPage()),
                            );
                            if (result != null) {
                              setState(() {
                                scanResult = result.toString();
                              });
                            }
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
                      child: Text(
                        scanResult != null
                            ? "Résultat du scan : $scanResult"
                            : "Résultat du scan affiché ici...",
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
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
