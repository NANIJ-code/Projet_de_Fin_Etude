import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    try {
      final data = {
        "telephone": _phoneController.text,
        "pays": _countryController.text,
        "ville": _cityController.text,
        "adresse": _addressController.text,
      };
      final success = await UserService.completeProfile(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profil complété !' : 'Erreur lors de la sauvegarde'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.of(context).pop(); // ou Navigator.pushReplacement vers la page d'accueil
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compléter mon profil"),
        backgroundColor: const Color(0xFF1A6FC9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Merci de compléter vos informations", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: "Téléphone"),
                      validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                    ),
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: "Pays"),
                      validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: "Ville"),
                      validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: "Adresse"),
                      validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A6FC9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text("Enregistrer"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}