// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../models/utilisateur.dart';

class ProductTable extends StatelessWidget {
  const ProductTable({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4E4FEB),
            ),
          );
        }
        return Consumer<ProductProvider>(
          builder: (context, provider, _) {
            final products = provider.filteredProducts;
            if (products.isEmpty) {
              return Center(
                child: Text(
                  'Aucun produit enregistré.',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF6B6B6B),
                    fontSize: 16,
                  ),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600), // ← plus large
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: const Icon(Icons.list_alt, color: Colors.white, size: 28),
                              )
                              .animate()
                              .shimmer(delay: 1000.ms, duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
                              
                              const SizedBox(width: 16),
                              Text(
                                "Liste des Produits",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFF1A1A2E)),
                              headingTextStyle: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 64,
                              columnSpacing: 36,
                              horizontalMargin: 12,
                              dividerThickness: 1,
                              border: TableBorder(
                                borderRadius: BorderRadius.circular(12),
                                horizontalInside: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              columns: [
                                _buildDataColumn('Nom'),
                                _buildDataColumn('Fournisseur'),
                                _buildDataColumn('Prix'),
                                _buildDataColumn('Quantité'),
                                _buildDataColumn('Date expiration'),
                                _buildDataColumn('QR Code'),
                                _buildDataColumn('Actions'),
                              ],
                              rows: List<DataRow>.generate(
                                products.length,
                                (index) {
                                  final product = products[index];
                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith<Color?>(
                                      (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.hovered)) {
                                          return const Color(0xFFEAEAEC);
                                        }
                                        return index % 2 == 0 ? Colors.white : Colors.grey[50];
                                      },
                                    ),
                                    cells: [
                                      _buildDataCell(product.name),
                                      _buildDataCell(product.supplier),
                                      _buildDataCell(product.price.toString()),
                                      _buildDataCell(product.quantity.toString()),
                                      _buildDataCell(product.expirationDate),
                                      DataCell(
                                        Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: const Color(0xFFEAEAEC),
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: product.qrCode.isNotEmpty
                                                ? Image.network(
                                                    product.qrCode.startsWith('http')
                                                        ? product.qrCode
                                                        : 'http://localhost:8000${product.qrCode}',
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        const Icon(Icons.qr_code_2, 
                                                          color: Color(0xFF4E4FEB), 
                                                          size: 32),
                                                  )
                                                : const Icon(Icons.qr_code_2, 
                                                    color: Color(0xFF4E4FEB), 
                                                    size: 32),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        // Remplace Row par Wrap pour éviter l'overflow
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 8,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Color(0xFF4E4FEB)),
                                              tooltip: 'Modifier',
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => EditProductDialog(product: product),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Color(0xFFB42B51)),
                                              tooltip: 'Supprimer',
                                              onPressed: () async {
                                                await Provider.of<ProductProvider>(context, listen: false)
                                                  .removeProduct(product.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Center(
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value) {
    return DataCell(
      Center(
        child: Text(
          value,
          style: GoogleFonts.montserrat(),
        ),
      ),
    );
  }
}

class EditProductDialog extends StatefulWidget {
  final Product product;
  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController expirationDateController;

  Utilisateur? selectedFournisseur;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    priceController = TextEditingController(text: widget.product.price.toString());
    quantityController = TextEditingController(text: widget.product.quantity.toString());
    expirationDateController = TextEditingController(text: widget.product.expirationDate);

    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.fetchFournisseurs().then((_) {
      setState(() {
        selectedFournisseur = provider.fournisseurs.isNotEmpty
            ? provider.fournisseurs.firstWhere(
                (u) => u.nom == widget.product.supplier,
                orElse: () => provider.fournisseurs.first,
              )
            : null;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    expirationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fournisseurs = Provider.of<ProductProvider>(context).fournisseurs;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Modifier le produit',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildStyledTextField(
                    controller: nameController,
                    label: 'Nom',
                    icon: Icons.shopping_bag,
                    validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledDropdown(
                    value: selectedFournisseur,
                    items: fournisseurs,
                    label: 'Fournisseur',
                    icon: Icons.business,
                    validator: (value) => value == null ? 'Sélectionnez un fournisseur' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: priceController,
                    label: 'Prix',
                    icon: Icons.euro,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: quantityController,
                    label: 'Quantité',
                    icon: Icons.confirmation_number,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: expirationDateController,
                    label: 'Date expiration',
                    icon: Icons.calendar_today,
                    validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                    'Annuler',
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'nom': nameController.text,
                        'fournisseur': selectedFournisseur?.id,
                        'prix': double.tryParse(priceController.text) ?? 0,
                        'quantite': int.tryParse(quantityController.text) ?? 0,
                        'date_expiration': expirationDateController.text,
                      };
                      await Provider.of<ProductProvider>(context, listen: false)
                          .updateProduct(widget.product, data);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Enregistrer',
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
      onChanged: (u) => setState(() => selectedFournisseur = u),
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
}