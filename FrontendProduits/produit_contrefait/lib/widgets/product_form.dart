import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/product_provider.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _supplierController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _registrationDate;
  DateTime? _expirationDate;

  @override
  void dispose() {
    _nameController.dispose();
    _supplierController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nouveau Produit",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.read<ProductProvider>().toggleFormVisibility(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextFormField(
                controller: _nameController,
                label: "Nom du produit",
                icon: Icons.shopping_bag,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _supplierController,
                label: "Fournisseur",
                icon: Icons.business,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _priceController,
                label: "Prix",
                icon: Icons.euro,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _quantityController,
                label: "Quantité",
                icon: Icons.confirmation_number,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      "Date d'enregistrement",
                      _registrationDate,
                      (date) => setState(() => _registrationDate = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      "Date d'expiration",
                      _expirationDate,
                      (date) => setState(() => _expirationDate = date),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => context.read<ProductProvider>().toggleFormVisibility(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text("Annuler"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42A5F5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Enregistrer"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF42A5F5)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        if (keyboardType == TextInputType.number || keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
          final numValue = num.tryParse(value);
          if (numValue == null) return 'Veuillez entrer un nombre valide';
          if (label == "Quantité" && numValue <= 0) return 'Quantité > 0';
          if (label == "Prix" && numValue < 0) return 'Prix >= 0';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF42A5F5),
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(color: Color.fromRGBO(158, 158, 158, 0.5)),
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null 
                    ? DateFormat('dd/MM/yyyy').format(selectedDate)
                    : 'Sélectionner une date',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_registrationDate == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date d\'enregistrement')),
        );
        return;
      }
      if (_expirationDate == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date d\'expiration')),
        );
        return;
      }
      if (_expirationDate!.isBefore(_registrationDate!)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La date d\'expiration doit être après la date d\'enregistrement')),
        );
        return;
      }

      final success = await _sendProductToBackend(
        name: _nameController.text,
        supplier: _supplierController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        productionDate: DateFormat('yyyy-MM-dd').format(_registrationDate!),
        expirationDate: DateFormat('yyyy-MM-dd').format(_expirationDate!),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit ajouté avec succès !')),
        );
        _formKey.currentState?.reset();
        setState(() {
          _registrationDate = null;
          _expirationDate = null;
        });
        context.read<ProductProvider>().toggleFormVisibility();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout du produit')),
        );
      }
    }
  }

  Future<bool> _sendProductToBackend({
    required String name,
    required String supplier,
    required double price,
    required int quantity,
    required String productionDate,
    required String expirationDate,
  }) async {
    final url = Uri.parse('http://localhost:8000/api/produits/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': name,
        'fournisseur': supplier,
        'prix': price,
        'quantite': quantity,
        'date_expiration': expirationDate,
        'date_enregistrement': productionDate, // si tu ajoutes ce champ côté backend
      }),
    );
    return response.statusCode == 201;
  }
}