// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  
import 'package:intl/date_symbol_data_local.dart';
// Ajoute cet import en haut si ce n'est pas déjà fait :

// Constantes pour les couleurs
const Color primaryColor = Color(0xFF1A6FC9);
const Color secondaryColor = Color(0xFF64B5F6);
const Color alertColor = Color(0xFFF44336);
const Color aboutGradientStart = Color(0xFF1A6FC9);
const Color aboutGradientEnd = Color(0xFF0D47A1);
const Color gridLineColor = Color(0xFFEAEAEC);
const Color textColor = Color(0xFF6B6B6B);
const Color cardBackgroundColor = Colors.white;
const Color scaffoldBackgroundColor = Color(0xFFF5F5F7);

// Styles de texte réutilisables
final TextStyle titleTextStyle = GoogleFonts.playfairDisplay(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  color: primaryColor,
);

final TextStyle sectionTitleTextStyle = GoogleFonts.playfairDisplay(
  fontWeight: FontWeight.w700,
  fontSize: 20,
  color: primaryColor,
);

final TextStyle labelTextStyle = GoogleFonts.montserrat(
  fontSize: 14,
  color: Colors.white.withOpacity(0.9),
  letterSpacing: 0.5,
);

final TextStyle valueTextStyle = GoogleFonts.playfairDisplay(
  fontSize: 30,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

final TextStyle montserratStyle = GoogleFonts.montserrat();

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  // Ajoute ces variables dans ta classe :
  int produitsCount = 0;
  int qrCodesCount = 0;
  int utilisateursCount = 0;
  int alertesCount = 0;

  String? _username;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      setState(() {}); // Rebuild after locale data is loaded
    });
    _fetchDashboardStats();
    _loadUsername();
  }

  Future<void> _fetchDashboardStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Produits
    final produitsResp = await http.get(
      Uri.parse('http://127.0.0.1:8000/api_produits/produits/'),
      headers: headers,
    );
    if (produitsResp.statusCode == 200) {
      final produits = jsonDecode(produitsResp.body);
      setState(() => produitsCount = produits.length);
    }

    // QR Codes
    final qrResp = await http.get(
      Uri.parse('http://127.0.0.1:8000/api_produits/qrcodes/'),
      headers: headers,
    );
    if (qrResp.statusCode == 200) {
      final qrs = jsonDecode(qrResp.body);
      setState(() => qrCodesCount = qrs.length);
    }

    // Utilisateurs
    final usersResp = await http.get(
      Uri.parse('http://127.0.0.1:8000/api_user/utilisateurs/'),
      headers: headers,
    );
    if (usersResp.statusCode == 200) {
      final users = jsonDecode(usersResp.body);
      setState(() => utilisateursCount = users.length);
    }

    // Alertes
    final alertsResp = await http.get(
      Uri.parse('http://127.0.0.1:8000/api_produits/alertes/'),
      headers: headers,
    );
    if (alertsResp.statusCode == 200) {
      final alerts = jsonDecode(alertsResp.body);
      setState(() => alertesCount = alerts.length);
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Utilisateur';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Row(
        children: [
          // Sidebar à gauche
          if (!isMobile)
            ResponsiveSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) {
                _onSidebarItemSelected(i);
              },
            ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header style carte de bienvenue
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
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
                      image: const DecorationImage(
                        image: AssetImage(
                            'assets/images/dashboard_bg.png'), // Ajoute une image d’illustration douce
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        opacity: 0.12,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFE3E8F7),
                          child: Icon(Icons.person,
                              size: 48, color: Colors.blueGrey[300]),
                        ),
                        const SizedBox(width: 32),
                        // Texte de bienvenue
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${getGreeting()}, ${_username ?? 'Utilisateur'}!",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A6FC9),
                                ),
                              ),
                              Text(
                                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()),
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: Colors.blueGrey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date et badge
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF3FB),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: Color(0xFF1A6FC9)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Apr 13, 2021 2:11 pm",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: const Color(0xFF1A6FC9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A6FC9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                "Admin",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Grille de stats
                  _StatsGrid(
                    produitsCount: produitsCount,
                    qrCodesCount: qrCodesCount,
                    utilisateursCount: utilisateursCount,
                    alertesCount: alertesCount,
                  ),
                  const SizedBox(height: 32),
                  // Activité et alertes récentes côte à côte
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activité (chart)
                      Expanded(child: _ActivityChartCard()),
                      SizedBox(width: 32),
                      // Alertes récentes
                      Expanded(child: _RecentAlertsCard()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Carte "À propos" sécurité
                  const _AboutCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        Navigator.of(context).pushReplacementNamed('/transaction'); // AJOUT ICI
        break;
      case 5:
        Navigator.of(context).pushReplacementNamed('/alerts');
        break;
      case 6:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour";
    if (hour < 18) return "Bon après-midi";
    return "Bonsoir";
  }
}

// Sidebar icon stylé
class SidebarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarIcon({
    super.key,
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                isActive ? primaryColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: isActive ? primaryColor : const Color(0xFFB3B8C8),
            size: 26,
          ),
        ),
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              const Icon(Icons.space_dashboard, color: Colors.white, size: 30),
        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
            delay: 1000.ms,
            duration: 2000.ms,
            color: Colors.white.withOpacity(0.3)),
        const SizedBox(width: 20),
        Text("Vue d'Ensemble", style: titleTextStyle),
        const Spacer(),
        _buildSecureSystemBadge(),
      ],
    );
  }

  Widget _buildSecureSystemBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            "Système Sécurisé",
            style: montserratStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int produitsCount;
  final int qrCodesCount;
  final int utilisateursCount;
  final int alertesCount;

  const _StatsGrid({
    required this.produitsCount,
    required this.qrCodesCount,
    required this.utilisateursCount,
    required this.alertesCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 1000 ? 2 : 4,
      childAspectRatio: 1.6,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _StatCard(
          icon: Icons.inventory_2_outlined,
          label: "Produits",
          value: produitsCount.toString(),
          color: primaryColor,
          secondaryColor: secondaryColor,
          animationDelay: 0,
        ),
        _StatCard(
          icon: Icons.qr_code_2_rounded,
          label: "QR Codes",
          value: qrCodesCount.toString(),
          color: Colors.green,
          secondaryColor: const Color(0xFF81C784),
          animationDelay: 100,
        ),
        _StatCard(
          icon: Icons.account_circle_outlined,
          label: "Utilisateurs",
          value: utilisateursCount.toString(),
          color: Colors.purple,
          secondaryColor: const Color(0xFFBA68C8),
          animationDelay: 200,
        ),
        _StatCard(
          icon: Icons.notifications_active_outlined,
          label: "Alertes",
          value: alertesCount.toString(),
          color: alertColor,
          secondaryColor: const Color(0xFFEF9A9A),
          animationDelay: 300,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color secondaryColor;
  final int animationDelay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.secondaryColor,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/product'),
      child: Tooltip(
        message: "Voir la liste des produits",
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: valueTextStyle),
                      const SizedBox(height: 4),
                      Text(label, style: labelTextStyle),
                    ],
                  ),
                ],
              ),
            )
                .animate(delay: (animationDelay * 1.5).ms)
                .slideX(
                  begin: 0.5,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn()),
      ));
  }
}

class _ActivityChartCard extends StatelessWidget {
  const _ActivityChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Activité des Scans", style: sectionTitleTextStyle),
                  const Spacer(),
                  _buildLast7DaysBadge(),
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(
                height: 220,
                child: _FakeChart(),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 20, end: 0, curve: Curves.easeOut));
  }

  Widget _buildLast7DaysBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            "7 derniers jours",
            style: montserratStyle.copyWith(
              fontSize: 13,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeChart extends StatelessWidget {
  const _FakeChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 220),
      painter: _FakeChartPainter(),
    );
  }
}

class _FakeChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (var i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Area gradient
    final areaPath = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width, size.height * 0.5),
    ];
    areaPath.moveTo(points[0].dx, points[0].dy);
    for (final p in points.skip(1)) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    final areaGradient = LinearGradient(
      colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.01)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    canvas.drawPath(
      areaPath,
      Paint()..shader = areaGradient.createShader(Offset.zero & size),
    );

    // Line
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pointBorderPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 7, pointBorderPaint);
      canvas.drawCircle(p, 5, pointPaint);
    }

    // X-axis labels
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 11,
      fontFamily: montserratStyle.fontFamily,
      fontWeight: FontWeight.w500,
    );

    for (var i = 0; i < points.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(text: days[i], style: textStyle),
        
      )..layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentAlertsCard extends StatelessWidget {
  const _RecentAlertsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Alertes Récentes", style: sectionTitleTextStyle),
                  const Spacer(),
                  _buildNewAlertsBadge(),
                ],
              ),
              const SizedBox(height: 20),
              const _AlertItem(
                icon: Icons.warning_amber_rounded,
                color: Color(0xFFFFA41B),
                title: "Produit suspect détecté",
                subtitle: "Scan du 29/05/2025 à 14:32",
              ),
              const Divider(height: 24, thickness: 1, color: Color(0xFFF1F1F3)),
              const _AlertItem(
                icon: Icons.block,
                color: alertColor,
                title: "Produit contrefait bloqué",
                subtitle: "Scan du 28/05/2025 à 10:12",
              ),
              const Divider(height: 24, thickness: 1, color: Color(0xFFF1F1F3)),
              const _AlertItem(
                icon: Icons.info_outline,
                color: primaryColor,
                title: "Nouvelle mise à jour disponible",
                subtitle: "27/05/2025",
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 20, end: 0, curve: Curves.easeOut));
  }

  Widget _buildNewAlertsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber, size: 16, color: alertColor),
          const SizedBox(width: 8),
          Text(
            "4 nouvelles",
            style: montserratStyle.copyWith(
              fontSize: 13,
              color: alertColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _AlertItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: montserratStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: montserratStyle.copyWith(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [aboutGradientStart, aboutGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.security, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sécurité des Données",
                      style: titleTextStyle.copyWith(
                          fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Toutes vos données sont chiffrées avec un cryptage AES-256 et protégées conformément aux normes RGPD et ISO 27001.",
                      style: montserratStyle.copyWith(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 20, end: 0, curve: Curves.easeOut));
  }
}

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      const _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
      const _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
      const _NavItem(Icons.account_circle_outlined, "Utilisateur", '/user'),
      const _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
      const _NavItem(Icons.swap_horiz, "Transaction", '/transaction'), // AJOUT ICI
      const _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
      const _NavItem(Icons.settings, "Paramètres", '/settings'),
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo/Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.security, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Text(
                  "SecureScan",
                  style: titleTextStyle.copyWith(
                      fontSize: 22, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Menu items
          ...navItems.map((item) => _NavTile(
                icon: item.icon,
                label: item.label,
                route: item.route,
              )),
          const Spacer(),
          // User profile
          const Padding(
            padding: EdgeInsets.all(24),
            child: _UserProfile(username: "Admin"),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? route; // <-- nullable

  const _NavTile({
    required this.icon,
    required this.label,
    this.route, // <-- nullable
  });

  @override
  Widget build(BuildContext context) {
    final isActive = ModalRoute.of(context)?.settings.name == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1A6FC9).withOpacity(0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF1A6FC9)
                  : const Color(0xFFB3B8C8),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  final String username;
  const _UserProfile({required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: montserratStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              "Administrateur",
              style: montserratStyle.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white70, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }
}

class ResponsiveSidebar extends StatefulWidget {
  final int selectedIndex;
  
  final ValueChanged<int> onItemSelected;
  const ResponsiveSidebar(
      {super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  bool _isHovered = false;

  final List<_NavItem> navItems = [
    const _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
    const _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
    const _NavItem(Icons.account_circle_outlined, "Utilisateur", '/user'),
    const _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
    const _NavItem(Icons.swap_horiz, "Transaction", '/transaction'), // AJOUT ICI
    const _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
    const _NavItem(Icons.settings, "Paramètres", '/settings'),
  ];

  // Ajoute en haut de la classe _ResponsiveSidebarState :
  String? _username;

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
      ));
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem(this.icon, this.label, this.route);
}
