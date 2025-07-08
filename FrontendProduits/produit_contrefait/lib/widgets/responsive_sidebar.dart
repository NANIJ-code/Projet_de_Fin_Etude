// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _username;

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
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Utilisateur';
    });
  }

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
          crossAxisAlignment: _isHovered || isMobile
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 28),
            // Logo
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: (_isHovered || isMobile) ? 24 : 0),
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6FC9).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.security,
                      color: Color(0xFF1A6FC9), size: 28),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: (_isHovered || isMobile) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: (_isHovered || isMobile)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8, left: 24),
                      child: Text(
                        "SecureScan",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          color: const Color(0xFF1A6FC9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 18),
            // Menu vertical
            ...List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isActive = widget.selectedIndex == i;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => widget.onItemSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                      vertical: 4, horizontal: (_isHovered || isMobile) ? 16 : 0),
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
                    mainAxisAlignment: _isHovered || isMobile
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: (_isHovered || isMobile) ? 120 : 0,
                        curve: Curves.ease,
                        child: (_isHovered || isMobile)
                            ? Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.montserrat(
                                    color: isActive
                                        ? const Color(0xFF1A6FC9)
                                        : const Color(0xFFB3B8C8),
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            // Profil utilisateur en bas
            Padding(
              padding: EdgeInsets.only(
                  bottom: 18, left: (_isHovered || isMobile) ? 24 : 0),
              child: Row(
                mainAxisAlignment: _isHovered || isMobile
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1A6FC9).withOpacity(0.12),
                    child: const Icon(Icons.person,
                        color: Color(0xFF1A6FC9), size: 26),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: (_isHovered || isMobile) ? 120 : 0,
                    curve: Curves.ease,
                    child: (_isHovered || isMobile)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _username ?? "Utilisateur",
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
                          )
                        : null,
                  ),
                ],
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