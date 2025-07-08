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
                      leading: const Icon(
                        Icons.notifications,
                        color: Color(0xFF4E4FEB),
                      ),
                      title: Text(
                        'Notifications',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
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
                      leading: const Icon(
                        Icons.security,
                        color: Color(0xFF4E4FEB),
                      ),
                      title: Text(
                        'Confidentialité',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
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
                      title: Text(
                        'Aide',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(context, 2),
    );
  }
}

// Nav bar stylée et réutilisable
Widget _buildCustomBottomNav(BuildContext context, int selectedIndex) {
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
        _navItem(context, Icons.home_rounded, 'Accueil', 0, selectedIndex),
        _navItem(context, Icons.chat_bubble_outline, 'Chat', 1, selectedIndex),
        _navItem(context, Icons.settings_rounded, 'Outils', 2, selectedIndex),
      ],
    ),
  );
}

Widget _navItem(
  BuildContext context,
  IconData icon,
  String label,
  int index,
  int selectedIndex,
) {
  bool isSelected = selectedIndex == index;
  return GestureDetector(
    onTap: () {
      if (index == 0) Navigator.pushNamed(context, '/');
      if (index == 1) Navigator.pushNamed(context, '/chat');
      if (index == 2) Navigator.pushNamed(context, '/settings');
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
