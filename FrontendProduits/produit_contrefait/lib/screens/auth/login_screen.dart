import 'package:flutter/material.dart';

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

  void _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    setState(() => showLogin = true); // Retour à la connexion après inscription
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Scaffold(
      backgroundColor: const Color(0xFFe3f2fd),
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
            width: isMobile ? double.infinity : 370,
            child: Card(
              elevation: 8,
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: showLogin ? _buildLoginForm() : _buildRegisterForm(),
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
          const Text(
            "Connexion",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Accédez à la plateforme de détection des produits contrefaits.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _loginEmailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value != null && value.contains('@') ? null : "Email invalide",
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Mot de passe",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value != null && value.length >= 6 ? null : "Mot de passe trop court",
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Se connecter"),
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => showLogin = false),
            child: const Text("S'inscrire"),
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
          const Text(
            "Inscription",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Créez un compte pour vérifier l’authenticité de vos produits.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _registerNameController,
            decoration: const InputDecoration(
              labelText: "Nom",
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value != null && value.trim().isNotEmpty ? null : "Nom requis",
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerEmailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value != null && value.contains('@') ? null : "Email invalide",
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Mot de passe",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value != null && value.length >= 6 ? null : "6 caractères minimum",
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerConfirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Confirmer le mot de passe",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == _registerPasswordController.text
                    ? null
                    : "Les mots de passe ne correspondent pas",
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              label: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("S'inscrire"),
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => showLogin = true),
            child: const Text("Déjà un compte ? Se connecter"),
          ),
        ],
      ),
    );
  }
}