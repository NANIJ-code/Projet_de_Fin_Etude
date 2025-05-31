import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
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
  DateTime? _registrationDate;
  DateTime? _expirationDate;

  @override
  void dispose() {
    _nameController.dispose();
    _supplierController.dispose();
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
  }) {
    return TextFormField(
      controller: controller,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_registrationDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date d\'enregistrement')),
        );
        return;
      }
      
      if (_expirationDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date d\'expiration')),
        );
        return;
      }

      if (_expirationDate!.isBefore(_registrationDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La date d\'expiration doit être après la date d\'enregistrement')),
        );
        return;
      }

      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        supplier: _supplierController.text,
        productionDate: DateFormat('yyyy-MM-dd').format(_registrationDate!),
        expirationDate: DateFormat('yyyy-MM-dd').format(_expirationDate!),
        qrCode: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);
      
      // Réinitialisation du formulaire
      _formKey.currentState?.reset();
      setState(() {
        _registrationDate = null;
        _expirationDate = null;
      });
    }
  }
}