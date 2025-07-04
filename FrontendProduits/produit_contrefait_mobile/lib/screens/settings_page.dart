import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // Bannière en haut
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
                const Icon(Icons.settings, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  "Paramètres",
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
          // Contenu principal
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
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Color(0xFF4E4FEB)),
                      title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.security, color: Color(0xFF4E4FEB)),
                      title: Text('Confidentialité', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.help, color: Color(0xFF4E4FEB)),
                      title: Text('Aide', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(context, 3),
    );
  }
}

// Nav bar stylée et réutilisable
Widget _buildCustomBottomNav(BuildContext context, int selectedIndex) {
  return Container(
    height: 70,
    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8), // marge réduite
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1976D2).withOpacity(0.10),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: const Color(0xFF4E4FEB).withOpacity(0.07),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (var i = 0; i < 4; i++)
          _navItem(context, _navIcons[i], _navLabels[i], i, selectedIndex),
      ],
    ),
  );
}

const List<IconData> _navIcons = [
  Icons.home_rounded,
  Icons.history_rounded,
  Icons.chat_bubble_rounded,
  Icons.settings_rounded,
];

const List<String> _navLabels = [
  'Accueil',
  'Historique',
  'Chat',
  'Outils',
];

Widget _navItem(BuildContext context, IconData icon, String label, int index, int selectedIndex) {
  final bool isSelected = selectedIndex == index;
  return Flexible(
    fit: FlexFit.tight,
    child: GestureDetector(
      onTap: () {
        if (index == 0) Navigator.pushNamed(context, '/');
        if (index == 1) Navigator.pushNamed(context, '/historique');
        if (index == 2) Navigator.pushNamed(context, '/chat');
        if (index == 3) Navigator.pushNamed(context, '/settings');
      },
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // réduit
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4E4FEB).withOpacity(0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4E4FEB).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4E4FEB) : Colors.grey.shade500,
              size: isSelected ? 26 : 22, // réduit
            ),
            const SizedBox(height: 2), // réduit
            AnimatedDefaultTextStyle(
              duration: 300.ms,
              style: GoogleFonts.poppins(
                fontSize: 11, // réduit
                color: isSelected ? const Color(0xFF4E4FEB) : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    ),
  );
}