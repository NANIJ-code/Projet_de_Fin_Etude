// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:produit_contrefait/providers/user_provider.dart';
import 'dart:convert';
import '../models/utilisateur.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _expirationDate;

  Utilisateur? _selectedFournisseur;
  List<Utilisateur> _fournisseurs = [];

  @override
  void initState() {
    super.initState();
    _loadFournisseurs();
  }

  Future<void> _loadFournisseurs() async {
    final users = await UtilisateurService.fetchFournisseurs();
    setState(() {
      _fournisseurs = users;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_box, color: Colors.white, size: 28),
                    )
                    .animate()
                    .shimmer(delay: 1000.ms, duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
                    
                    const SizedBox(width: 16),
                    Text(
                      "Nouveau Produit",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildStyledTextField(
                  controller: _nameController,
                  label: "Nom du produit",
                  icon: Icons.shopping_bag,
                  validator: (value) => value == null || value.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 20),
                _buildStyledDropdown(
                  value: _selectedFournisseur,
                  items: _fournisseurs,
                  label: 'Fournisseur',
                  icon: Icons.business,
                  validator: (value) => value == null ? 'Sélectionnez un fournisseur' : null,
                ),
                const SizedBox(height: 20),
                _buildStyledTextField(
                  controller: _priceController,
                  label: "Prix",
                  icon: Icons.euro,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Champ obligatoire';
                    final numValue = num.tryParse(value);
                    if (numValue == null) return 'Veuillez entrer un nombre valide';
                    if (numValue < 0) return 'Prix >= 0';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildStyledTextField(
                  controller: _quantityController,
                  label: "Quantité",
                  icon: Icons.confirmation_number,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Champ obligatoire';
                    final numValue = num.tryParse(value);
                    if (numValue == null) return 'Veuillez entrer un nombre valide';
                    if (numValue <= 0) return 'Quantité > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildDateField(
                  "Date d'expiration",
                  _expirationDate,
                  (date) => setState(() => _expirationDate = date),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        side: const BorderSide(color: Color(0xFF1A1A2E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Annuler",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E4FEB),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        "Enregistrer",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          color: const Color(0xFF6B6B6B),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF4E4FEB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAEAEC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAEAEC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4E4FEB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.montserrat(),
    );
  }

  Widget _buildStyledDropdown({
    required Utilisateur? value,
    required List<Utilisateur> items,
    required String label,
    required IconData icon,
    required String? Function(Utilisateur?)? validator,
  }) {
    return DropdownButtonFormField<Utilisateur>(
      value: value,
      items: items.map((u) => DropdownMenuItem(
        value: u,
        child: Text(
          u.nom,
          style: GoogleFonts.montserrat(),
        ),
      )).toList(),
      onChanged: (u) => setState(() => _selectedFournisseur = u),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          color: const Color(0xFF6B6B6B),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF4E4FEB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAEAEC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAEAEC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4E4FEB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      style: GoogleFonts.montserrat(),
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: const Color(0xFF6B6B6B),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4E4FEB),
                      onPrimary: Colors.white,
                      onSurface: Color(0xFF1A1A2E),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4E4FEB),
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAEAEC)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate)
                      : 'Sélectionner une date',
                  style: GoogleFonts.montserrat(
                    color: selectedDate != null 
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF6B6B6B),
                  ),
                ),
                const Icon(Icons.calendar_today, 
                  color: Color(0xFF4E4FEB), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_expirationDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez sélectionner une date d\'expiration',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFB42B51),
          ),
        );
        return;
      }

      final success = await _sendProductToBackend(
        name: _nameController.text,
        fournisseurId: _selectedFournisseur!.id!,
        price: double.tryParse(_priceController.text) ?? 0,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        expirationDate: DateFormat('yyyy-MM-dd').format(_expirationDate!),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Produit ajouté avec succès !',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFF0D7377),
          ),
        );
        _formKey.currentState?.reset();
        setState(() {
          _expirationDate = null;
          _selectedFournisseur = null;
        });
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'ajout du produit',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFB42B51),
          ),
        );
      }
    }
  }

  Future<bool> _sendProductToBackend({
    required String name,
    required int fournisseurId,
    required double price,
    required int quantity,
    required String expirationDate,
  }) async {
    final url = Uri.parse('http://localhost:8000/api/produits/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': name,
        'fournisseur': fournisseurId,
        'prix': price,
        'quantite': quantity,
        'date_expiration': expirationDate,
      }),
    );
    return response.statusCode == 201;
  }
}