// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api_user/password-reset/request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code envoyé à votre adresse email')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetCodeScreen(email: _emailController.text),
          ),
        );
      } else {
        _showError("Email non reconnu");
      }
    } catch (e) {
      _showError("Erreur de connexion");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mot de passe oublié")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Entrez votre adresse email",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Adresse email"),
                validator: (v) =>
                    v != null && v.contains('@') ? null : "Email invalide",
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendCode,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Envoyer le code"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetCodeScreen extends StatelessWidget {
  final String email;
  const ResetCodeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ResetCodeScreenStateful(email: email);
  }
}

class ResetCodeScreenStateful extends StatefulWidget {
  final String email;
  const ResetCodeScreenStateful({super.key, required this.email});

  @override
  State<ResetCodeScreenStateful> createState() => _ResetCodeScreenStatefulState();
}

class _ResetCodeScreenStatefulState extends State<ResetCodeScreenStateful> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.email.isEmpty) {
        _showError("Email manquant, veuillez recommencer la procédure.");
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost:8000/api_user/password-reset/confirm/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': _codeController.text,
          'new_password': _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe réinitialisé !')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        String msg = "Erreur lors de la réinitialisation";
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['detail'] != null) {
            msg = data['detail'];
          } else if (data is Map && data.values.isNotEmpty) {
            msg = data.values.first.toString();
          }
        } catch (_) {}
        _showError(msg);
      }
    } catch (e) {
      _showError("Erreur de connexion");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Code de récupération")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Entrez le code reçu par email",
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Pour l'email : ${widget.email}",
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "Code"),
                validator: (v) =>
                    v != null && v.length == 6 ? null : "Code à 6 chiffres",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Nouveau mot de passe"),
                validator: (v) =>
                    v != null && v.length >= 6 ? null : "Au moins 6 caractères",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirmer le mot de passe"),
                validator: (v) => v == _passwordController.text
                    ? null
                    : "Les mots de passe ne correspondent pas",
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Valider"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
