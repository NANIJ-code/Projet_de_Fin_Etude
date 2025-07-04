// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _loginEmailController.text,
          'password': _loginPasswordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);

        // Décoder le token pour obtenir l'id utilisateur
        Map<String, dynamic> decodedToken = JwtDecoder.decode(data['access']);
        final userId = decodedToken['user_id']; // ou 'id' selon ton backend

        if (userId != null) {
          await prefs.setInt('user_id', userId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie !')),
        );

        // Redirige vers le dashboard (remplace DashboardScreen par ta page réelle)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        final data = jsonDecode(response.body);
        String error = data['detail'] ?? "Identifiants invalides";
        _showErrorDialog(error);
      }
    } catch (e) {
      _showErrorDialog("Erreur de connexion au serveur");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Erreur",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "OK",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4E4FEB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: SizedBox(
          width: isMobile ? double.infinity : 420,
          child: Card(
            elevation: 8,
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF1F5F9)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Connexion",
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Accédez à la plateforme de détection des produits contrefaits",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _loginEmailController,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              labelText: "Nom d'utilisateur",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon:
                  const Icon(Icons.person_outline, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) => value != null && value.trim().isNotEmpty
                ? null
                : "Nom d'utilisateur requis",
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: true,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              labelText: "Mot de passe",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) => value != null && value.length >= 6
                ? null
                : "Mot de passe trop court",
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E4FEB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF4E4FEB).withOpacity(0.3),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "SE CONNECTER",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen()),
                );
              },
              child: Text(
                "Mot de passe oublié ?",
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF4E4FEB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
