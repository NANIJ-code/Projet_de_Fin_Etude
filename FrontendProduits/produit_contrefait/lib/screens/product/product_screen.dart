import 'package:flutter/material.dart';
import 'package:produit_contrefait/widgets/product_form.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart' as product_provider;
import 'package:produit_contrefait/widgets/product_table.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Scaffold(
          drawer: isMobile ? const Drawer(child: NavigationSidebar()) : null,
          body: Row(
            children: [
              if (!isMobile) const NavigationSidebar(),
              Expanded(
                child: Column(
                  children: [
                    // Bannière en haut
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: const Text(
                        "Produits",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    // Le contenu principal
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 8.0 : 24.0),
                        child: Consumer<product_provider.ProductProvider>(
                          builder: (ctx, provider, _) {
                            return ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                _buildHeader(context, provider, isMobile),
                                const SizedBox(height: 24),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: provider.showForm
                                      ? const ProductForm()
                                      : const SizedBox.shrink(),
                                ),
                                if (provider.showForm) const SizedBox(height: 24),
                                const SizedBox(
                                  height: 400,
                                  child: ProductTable(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, product_provider.ProductProvider provider, bool isMobile) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      spacing: 24,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Produits",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${provider.products.length} produits enregistrés",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: isMobile ? 140 : 260,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: provider.setSearchQuery,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: provider.showForm
                  ? IconButton(
                      key: const ValueKey('close-icon'),
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => provider.toggleFormVisibility(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.all(12),
                      ),
                    )
                  : ElevatedButton.icon(
                      key: const ValueKey('add-button'),
                      onPressed: () => provider.toggleFormVisibility(),
                      icon: const Icon(Icons.add),
                      label: const Text("Ajouter un produit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        shadowColor: const Color.fromRGBO(33, 150, 243, 0.3),
                      ),
                    ),
            ),
          ],
        ),
        if (isMobile)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
      ],
    );
  }
}

// Sidebar complète avec navigation cohérente
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
        // Déjà sur la page produits
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