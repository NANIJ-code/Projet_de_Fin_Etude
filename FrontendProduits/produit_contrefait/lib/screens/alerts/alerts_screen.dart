// ignore_for_file: unused_local_variable, deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                child: const Icon(Icons.security,
                    color: Color(0xFF1A6FC9), size: 28),
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
                      child: const Icon(Icons.person,
                          color: Color(0xFF1A6FC9), size: 26),
                    ),
                    if (_isHovered || isMobile) const SizedBox(width: 8),
                    if (_isHovered || isMobile)
                      Expanded(
                        // <-- Ajoute ceci
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
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Administrateur",
                              style: GoogleFonts.montserrat(
                                color: Colors.blueGrey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
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
  int selectedIndex = 5;
  List<Map<String, dynamic>> _alertes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAlertes();
  }

  Future<void> _fetchAlertes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('http://localhost:8000/api_produits/alertes/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _alertes = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Erreur serveur : ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erreur réseau : $e";
        _loading = false;
      });
    }
  }

  Future<void> _showAlerteDetail(int id) async {
    final token = await _getToken();
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<http.Response>(
        future: http.get(
          Uri.parse('http://localhost:8000/api_produits/alertes/$id/'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.data!.statusCode != 200) {
            return AlertDialog(
              title: const Text("Erreur"),
              content:
                  const Text("Impossible de charger le détail de l'alerte."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Fermer"),
                ),
              ],
            );
          }
          final detail = json.decode(utf8.decode(snap.data!.bodyBytes));
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              "Détail de l'alerte",
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 350,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type : ${detail['type'] ?? 'Inconnu'}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Message : ${detail['message'] ?? ''}"),
                    const SizedBox(height: 8),
                    Text("Produit : ${detail['produit'] ?? ''}"),
                    const SizedBox(height: 8),
                    Text(
                        "Date : ${detail['date'] ?? detail['created_at'] ?? ''}"),
                    const SizedBox(height: 8),
                    Text(
                        "Utilisateur : ${detail['utilisateur'] ?? detail['user'] ?? ''}"),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Fermer"),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getAlerteColor(Map<String, dynamic> alerte) {
    // Si lot_id est null => rouge, sinon bleu
    if (alerte['lot_id'] == null) {
      return const Color(0xFFB42B51); // Rouge
    }
    return const Color(0xFF1A6FC9); // Bleu
  }

  IconData _getAlerteIcon(Map<String, dynamic> alerte) {
    if (alerte['lot_id'] == null) {
      return Icons.error_outline;
    }
    return Icons.warning_amber_rounded;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ENTÊTE STYLÉE
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 18 : 32,
                    horizontal: isMobile ? 16 : 36,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6FC9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(isMobile ? 24 : 36),
                      bottomRight: Radius.circular(isMobile ? 24 : 36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Text(
                        "Alertes",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 22 : 28,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "${_alertes.length} alerte${_alertes.length > 1 ? 's' : ''}",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: isMobile ? 13 : 15,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(
                                  child: Text(_error!,
                                      style:
                                          const TextStyle(color: Colors.red)))
                              : _alertes.isEmpty
                                  ? Center(
                                      child: Text(
                                        "Aucune alerte trouvée.",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 18, color: Colors.grey),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _alertes.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 18),
                                      itemBuilder: (context, i) {
                                        final alerte = _alertes[i];
                                        final color = _getAlerteColor(alerte);
                                        final icon = _getAlerteIcon(alerte);
                                        String dateStr = (alerte['date'] ??
                                                alerte['created_at'] ??
                                                '')
                                            .toString()
                                            .replaceAll('T', ' ');
                                        if (dateStr.length > 16) {
                                          dateStr = dateStr.substring(0, 16);
                                        }
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          onTap: () =>
                                              _showAlerteDetail(alerte['id']),
                                          child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.09),
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                              border: Border.all(
                                                color: color.withOpacity(0.25),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      color.withOpacity(0.08),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 54,
                                                  height: 54,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        color.withOpacity(0.18),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                  ),
                                                  child: Icon(icon,
                                                      color: color, size: 36),
                                                ),
                                                const SizedBox(width: 22),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        (alerte['id'] ??
                                                                'Alerte')
                                                            .toString()
                                                            .toUpperCase(),
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: color,
                                                          letterSpacing: 1.2,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        alerte['message'] ?? '',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontSize: 16,
                                                          color: const Color(
                                                              0xFF1A1A2E),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .calendar_today,
                                                              size: 16,
                                                              color: color),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            dateStr,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        13,
                                                                    color:
                                                                        color),
                                                          ),
                                                          const SizedBox(
                                                              width: 18),
                                                          Icon(Icons.person,
                                                              size: 16,
                                                              color: color),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            (alerte['utilisateur'] ??
                                                                alerte[
                                                                    'user'] ??
                                                                ''),
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        13,
                                                                    color:
                                                                        color),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('token'); // doit être le token d'accès (access)
    return token;
  }

  void _onSidebarItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    final routes = [
      '/dashboard',
      '/scan',
      '/user',
      '/product',
      '/transaction',
      '/alerts',
      '/settings',
    ];
    if (index >= 0 && index < routes.length) {
      Navigator.of(context).pushReplacementNamed(routes[index]);
    }
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
