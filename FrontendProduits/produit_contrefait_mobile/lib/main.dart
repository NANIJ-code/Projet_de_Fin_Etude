// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'screens/chat_page.dart';
import 'screens/history_page.dart';
import 'screens/settings_page.dart';
import 'screens/scan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScanPage(),
        '/historique': (context) => const HistoryPage(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const ChatPage(),
        '/scan': (context) => const ScanPage(),
      },
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
      ),
    );
  }
}

class HomeScanPage extends StatefulWidget {
  const HomeScanPage({super.key});

  @override
  State<HomeScanPage> createState() => _HomeScanPageState();
}

class _HomeScanPageState extends State<HomeScanPage> with TickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _heroController;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: 1000.ms,
    )..repeat(reverse: true);

    _gradientController = AnimationController(
      vsync: this,
      duration: 5000.ms,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heroController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          // Bannière en haut (même style que ChatPage)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
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
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  "Scanner un produit",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // Fond dégradé clair et contenu principal
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F5F7), Color(0xFFEAEAEC)],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Hero with Glassmorphism effect
                        ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.1).animate(
                            CurvedAnimation(parent: _heroController, curve: Curves.easeInOut),
                          ),
                          child: Hero(
                            tag: "scan_hero",
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                size: 100,
                                color: Color(0xFF4E4FEB),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.2, end: 0),

                        const SizedBox(height: 40),

                        // Title with animated text gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF1A1A2E), Color(0xFF4E4FEB)],
                            stops: [0.5, 1.0],
                          ).createShader(bounds),
                          child: Text(
                            "Scanner un produit",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

                        const SizedBox(height: 16),

                        // Subtitle with animated entry
                        Text(
                          "Scannez le QR code pour vérifier l'authenticité du produit.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

                        const SizedBox(height: 50),

                        // 3D Button with press effect
                        MouseRegion(
                          onEnter: (_) => _heroController.forward(),
                          onExit: (_) => _heroController.repeat(reverse: true),
                          child: GestureDetector(
                            onTapDown: (_) => _heroController.stop(),
                            onTapUp: (_) => _heroController.repeat(reverse: true),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              transform: Matrix4.identity()..scale(1.0),
                              transformAlignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(13, 71, 161, 0.5),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 18),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt, size: 28, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Scan maintenant",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .shimmer(
                              delay: 1000.ms,
                              duration: 1500.ms,
                              color: const Color.fromRGBO(255, 255, 255, 0.2),
                            )
                            .scaleXY(end: 1.02, duration: 1000.ms, curve: Curves.easeInOut),
                            onTap: () async {
                              if (!mounted) return;
                              final code = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ScanPage()),
                              );
                              if (code != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Code scanné : $code'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        // Ajoute cet espace pour éviter que le bouton soit caché par la nav bar
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Accueil', 0),
          _buildNavItem(Icons.history, 'Historique', 1),
          _buildNavItem(Icons.chat_bubble_outline, 'Chat', 2), // Ajouté
          _buildNavItem(Icons.settings, 'Outils', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);
        if (index == 1) Navigator.pushNamed(context, '/historique');
        if (index == 2) Navigator.pushNamed(context, '/chat');        // Ajouté
        if (index == 3) Navigator.pushNamed(context, '/settings');
        if (index == 0) Navigator.pushNamed(context, '/');
      },
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}