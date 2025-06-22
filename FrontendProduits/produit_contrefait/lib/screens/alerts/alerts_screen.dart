// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Copie la classe ResponsiveSidebar depuis user_screen.dart

class ResponsiveSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  const ResponsiveSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  bool _isHovered = false;

  final List<_NavItem> navItems = const [
    _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
    _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
    _NavItem(Icons.account_circle_outlined, "Utilisateur", '/user'),
    _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
    _NavItem(Icons.swap_horiz, "Transaction", '/transaction'),
    _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
    _NavItem(Icons.settings, "Paramètres", '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final sidebarWidth = _isHovered || isMobile ? 220.0 : 80.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: sidebarWidth,
        constraints: BoxConstraints(maxWidth: sidebarWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.10),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 28),
            // Logo centré
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6FC9).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.security, color: Color(0xFF1A6FC9), size: 28),
              ),
            ),
            if (_isHovered || isMobile)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text(
                  "SecureScan",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: const Color(0xFF1A6FC9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            // Menu vertical, icônes centrés
            ...List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isActive = widget.selectedIndex == i;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => widget.onItemSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: _isHovered || isMobile ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1A6FC9).withOpacity(0.13)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône parfaitement centrée dans un carré
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1A6FC9).withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: isActive
                              ? const Color(0xFF1A6FC9)
                              : const Color(0xFFB3B8C8),
                          size: 26,
                        ),
                      ),
                      if (_isHovered || isMobile)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            item.label,
                            style: GoogleFonts.montserrat(
                              color: isActive
                                  ? const Color(0xFF1A6FC9)
                                  : const Color(0xFFB3B8C8),
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            // Profil utilisateur centré
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A6FC9).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF1A6FC9), size: 26),
                    ),
                    if (_isHovered || isMobile)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin",
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF1A6FC9),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Administrateur",
                              style: GoogleFonts.montserrat(
                                color: Colors.blueGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int selectedIndex = 5; // Index de "Alertes"

  void _onSidebarItemSelected(int i) {
    setState(() => selectedIndex = i);
    switch (i) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/scan');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/user');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/product');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/transaction');
        break;
      case 5:
        // Déjà sur alertes
        break;
      case 6:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      drawer: isMobile
          ? ResponsiveSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) {
                Navigator.of(context).pop();
                _onSidebarItemSelected(i);
              },
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            ResponsiveSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: _onSidebarItemSelected,
            ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F5F7), Color(0xFFEAEAEC)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12.0 : 32.0),
                child: ListView(
                  children: [
                    // Header style dashboard
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A6FC9), Color(0xFF16213E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        "Alertes",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Card d'alertes
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dernières alertes",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 18),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 3,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, i) => ListTile(
                                leading: const Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFB42B51)),
                                title: Text(
                                  "Alerte ${i + 1} : Produit suspect détecté",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  "Le ${DateTime.now().subtract(Duration(hours: i * 3)).toString().substring(0, 16)}",
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
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

class NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const NavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.white.withOpacity(0.7), size: 26),
        title: Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white.withOpacity(0.7),
            fontSize: 15,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        minLeadingWidth: 0,
        tileColor: isSelected ? Colors.white.withOpacity(0.1) : null,
      ),
    );
  }
}

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                "Administrateur",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
