import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      drawer: isMobile ? const Drawer(child: NavigationSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) const NavigationSidebar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8.0 : 24.0),
              child: ListView(
                children: const [
                  // Header
                  _DashboardHeader(),
                  SizedBox(height: 24),

                  // Statistiques principales
                  _StatsGrid(),
                  SizedBox(height: 32),

                  // Graphique d'activité
                  _ActivityChartCard(),
                  SizedBox(height: 32),

                  // Liste des alertes récentes
                  _RecentAlertsCard(),
                  SizedBox(height: 32),

                  // Bloc à propos
                  _AboutCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.space_dashboard_outlined,
            color: Color(0xFF1976D2), size: 32),
        SizedBox(width: 12),
        Text(
          "Tableau de bord",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        Spacer(),
        Chip(
          label: Text("Sécurisé"),
          avatar: Icon(Icons.verified_user, color: Colors.white, size: 18),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _StatCard(
          icon: Icons.inventory_2_outlined,
          label: "Produits",
          value: "128",
          color: Colors.blue,
          animationDelay: 0,
        ),
        _StatCard(
          icon: Icons.qr_code_2_rounded,
          label: "Scans",
          value: "542",
          color: Colors.cyan,
          animationDelay: 200,
        ),
        _StatCard(
          icon: Icons.account_circle_outlined,
          label: "Utilisateurs",
          value: "37",
          color: Colors.indigo,
          animationDelay: 400,
        ),
        _StatCard(
          icon: Icons.notifications_active_outlined,
          label: "Alertes",
          value: "4",
          color: Colors.redAccent,
          animationDelay: 600,
        ),
      ],
    );
  }
}

class _ActivityChartCard extends StatelessWidget {
  const _ActivityChartCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Activité des scans (7 derniers jours)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: _FakeChart(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentAlertsCard extends StatelessWidget {
  const _RecentAlertsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alertes récentes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            _AlertItem(
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              title: "Produit suspect détecté",
              subtitle: "Scan du 29/05/2025 à 14:32",
            ),
            _AlertItem(
              icon: Icons.block,
              color: Colors.redAccent,
              title: "Produit contrefait bloqué",
              subtitle: "Scan du 28/05/2025 à 10:12",
            ),
            _AlertItem(
              icon: Icons.info_outline,
              color: Colors.blue,
              title: "Nouvelle mise à jour disponible",
              subtitle: "27/05/2025",
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.security, color: Color(0xFF1976D2), size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "Ce tableau de bord vous permet de suivre l'activité de votre système anti-contrefaçon en temps réel. Toutes les données sont sécurisées et confidentielles.",
                style: TextStyle(fontSize: 16, color: Color(0xFF1976D2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int animationDelay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + animationDelay),
      curve: Curves.easeOutBack,
      builder: (context, valueAnim, child) => Opacity(
        opacity: valueAnim.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 40 * (1 - valueAnim)),
          child: child,
        ),
      ),
      child: Container(
        width: 220,
        height: 120,
        decoration: BoxDecoration(
          color: Color.alphaBlend(color.withAlpha(25), Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: Color.alphaBlend(color.withAlpha(45), Colors.white)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Color.alphaBlend(color.withAlpha(45), Colors.white),
                radius: 28,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 18),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FakeChart extends StatelessWidget {
  const _FakeChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 160),
      painter: _FakeChartPainter(),
      // child: ... (si tu veux ajouter un child, mets-le ici à la fin)
    );
  }
}

class _FakeChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          Color.alphaBlend(const Color(0xFF1976D2).withAlpha(45), Colors.white)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width, size.height * 0.5),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);

    // Points
    final pointPaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 6, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color.alphaBlend(color.withAlpha(38), Colors.white),
        child: Icon(icon, color: color),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}

// Ajoute ceci dans le même fichier ou dans settings_screen.dart si tu mutualises la sidebar

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
