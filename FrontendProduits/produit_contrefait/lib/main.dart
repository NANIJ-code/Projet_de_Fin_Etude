import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:produit_contrefait/providers/product_provider.dart';
import 'package:produit_contrefait/screens/auth/login_screen.dart';
import 'package:produit_contrefait/screens/dashboard/dashboard_screen.dart';
import 'package:produit_contrefait/screens/user/user_screen.dart';
import 'package:produit_contrefait/screens/product/product_screen.dart';
import 'package:produit_contrefait/screens/alerts/alerts_screen.dart';
import 'package:produit_contrefait/screens/settings/settings_screen.dart';
import 'package:produit_contrefait/screens/transaction/transaction_screen.dart';
import 'package:produit_contrefait/screens/product/unite_produit_screen.dart';
import 'package:produit_contrefait/screens/scan/scan_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Camera Error: ${e.description}');
  }

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
          primary: Color(0xFF42A5F5),
          secondary: Color(0xFF64B5F6),
          surface: Colors.white,
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
        '/scan': (context) =>
            const ScanScreen(), // Modifié pour utiliser QrScanPage
        '/user': (context) => const UserScreen(),
        '/product': (context) => const ProductScreen(),
        '/transaction': (context) => const TransactionScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/unite_produit': (context) => const UniteProduitScreen(),
      },
    );
  }
}
