import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_form.dart';
import '../../widgets/product_table.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Scaffold(
          drawer: isMobile ? const Drawer(child: _NavigationSidebar()) : null,
          body: Row(
            children: [
              if (!isMobile) const _NavigationSidebar(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 8.0 : 24.0),
                  child: Consumer<ProductProvider>(
                    builder: (ctx, provider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const Expanded(child: ProductTable()),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProductProvider provider, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

class _NavigationSidebar extends StatefulWidget {
  const _NavigationSidebar();

  @override
  State<_NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<_NavigationSidebar> with SingleTickerProviderStateMixin {
  int selectedIndex = 3; // Par défaut "Produits"
  late AnimationController _controller;

  final List<_NavItemData> navItems = [
    const _NavItemData(Icons.space_dashboard_outlined, "Dashboard", Color(0xFF42A5F5)), // bleu clair
    const _NavItemData(Icons.qr_code_2_rounded, "Scan", Color(0xFF42A5F5)),
    const _NavItemData(Icons.account_circle_outlined, "Utilisateur", Color(0xFF42A5F5)),
    const _NavItemData(Icons.inventory_2_outlined, "Produits", Color(0xFF42A5F5)),
    const _NavItemData(Icons.notifications_active_outlined, "Alertes", Color(0xFF42A5F5)),
    const _NavItemData(Icons.settings_outlined, "Paramètres", Color(0xFF42A5F5)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.95,
      upperBound: 1.05,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNavTap(int index) async {
    setState(() => selectedIndex = index);
    await _controller.forward();
    await _controller.reverse();
    if (!mounted) return; // Ajouté pour éviter le warning
    if (index == 5) { // 5 = Paramètres
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
    // Ajoute ici la navigation réelle pour les autres onglets si besoin
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF283593),
            Color(0xFF1976D2),
            Color(0xFF00BCD4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(33, 150, 243, 0.15),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header animé
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.18),
                  Color.fromRGBO(255, 255, 255, 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(32),
                bottomLeft: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(33, 150, 243, 0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.rotate(
                    angle: value * 0.2,
                    child: child,
                  ),
                  child: const Icon(Icons.security, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.cyanAccent, Colors.white, Colors.blueAccent],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Anti-Contrefaçon',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(navItems.length, (i) {
            final item = navItems[i];
            final isActive = selectedIndex == i;
            return GestureDetector(
              onTap: () => _onNavTap(i),
              child: AnimatedScale(
                scale: isActive ? _controller.value : 1.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    // Bloc AnimatedContainer couleur de fond
                    color: isActive
                        ? Color.fromRGBO(
                            (item.color.r * 255.0).round() & 0xff,
                            (item.color.g * 255.0).round() & 0xff,
                            (item.color.b * 255.0).round() & 0xff,
                            0.18,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              // Bloc BoxShadow couleur
                              color: Color.fromRGBO(
                                (item.color.r * 255.0).round() & 0xff,
                                (item.color.g * 255.0).round() & 0xff,
                                (item.color.b * 255.0).round() & 0xff,
                                0.22,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: ListTile(
                    leading: AnimatedRotation(
                      turns: isActive ? 0.1 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Icon(item.icon, color: item.color, size: 28),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isActive ? item.color : Colors.white,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const Divider(color: Colors.white54, height: 1),
          _buildNavItem(Icons.logout, "Déconnexion"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.08),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String title;
  final Color color;
  const _NavItemData(this.icon, this.title, this.color);
}