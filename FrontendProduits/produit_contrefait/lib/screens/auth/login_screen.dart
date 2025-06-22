// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showLogin = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmController.dispose();
    super.dispose();
  }

  

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final username = _registerNameController.text;
      final email = _registerEmailController.text;
      final password = _registerPasswordController.text;
      
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      
      if (!mounted) return;
      
      if (response.statusCode == 201) {
        setState(() => showLogin = true);
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = 'Erreur lors de l\'inscription';
        if (responseData['email'] != null) {
          errorMessage = responseData['email'][0];
        } else if (responseData['username'] != null) {
          errorMessage = responseData['username'][0];
        } else if (responseData['password'] != null) {
          errorMessage = responseData['password'][0];
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("Erreur de connexion au serveur");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            final offset = showLogin ? const Offset(1, 0) : const Offset(-1, 0);
            return SlideTransition(
              position: Tween<Offset>(
                begin: offset,
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: SizedBox(
            key: ValueKey(showLogin),
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
                  child: showLogin ? _buildLoginForm() : _buildRegisterForm(),
                ),
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
              labelText: "Email",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) =>
                value != null && value.contains('@') ? null : "Email invalide",
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: true,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              labelText: "Mot de passe",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) =>
                value != null && value.length >= 6 ? null : "Mot de passe trop court",
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null, // Désactive le bouton, aucune action
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
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => showLogin = false),
            child: Text(
              "Créer un compte",
              style: GoogleFonts.montserrat(
                color: const Color(0xFF4E4FEB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Inscription",
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Créez un compte pour vérifier l'authenticité de vos produits",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _registerNameController,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              labelText: "Nom complet",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) =>
                value != null && value.trim().isNotEmpty ? null : "Nom requis",
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerEmailController,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) =>
                value != null && value.contains('@') ? null : "Email invalide",
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: true,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              labelText: "Mot de passe",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) =>
                value != null && value.length >= 6 ? null : "6 caractères minimum",
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerConfirmController,
            obscureText: true,
            style: GoogleFonts.montserrat(),
            decoration: InputDecoration(
              labelText: "Confirmer le mot de passe",
              labelStyle: GoogleFonts.montserrat(),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B6B6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F1F3),
            ),
            validator: (value) =>
                value == _registerPasswordController.text
                    ? null
                    : "Les mots de passe ne correspondent pas",
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
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
                      "S'INSCRIRE",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => showLogin = true),
            child: Text(
              "Déjà un compte ? Se connecter",
              style: GoogleFonts.montserrat(
                color: const Color(0xFF4E4FEB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}