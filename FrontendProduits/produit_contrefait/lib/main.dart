import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:produit_contrefait/providers/product_provider.dart';
import 'package:produit_contrefait/screens/auth/login_screen.dart'; // Ajouté
import 'package:produit_contrefait/screens/dashboard/dashboard_screen.dart'; // Ajouté
import 'package:produit_contrefait/screens/scan/scan_screen.dart'; // Ajouté
import 'package:produit_contrefait/screens/user/user_screen.dart'; // Ajouté
import 'package:produit_contrefait/screens/product/product_screen.dart'; // Ajouté
import 'package:produit_contrefait/screens/alerts/alerts_screen.dart'; // Ajouté
import 'package:produit_contrefait/screens/settings/settings_screen.dart'; // Ajouté

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Détection Contrefaçon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF42A5F5), // Bleu ciel
          secondary: Color(0xFF64B5F6), // Bleu ciel plus clair
          surface: Colors.white, // Fond très légèrement bleuté
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF42A5F5)),
          titleTextStyle: TextStyle(
            color: Color(0xFF42A5F5),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF42A5F5),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/scan': (context) => const ScanScreen(),
        '/user': (context) => const UserScreen(),
        '/product': (context) => const ProductScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
