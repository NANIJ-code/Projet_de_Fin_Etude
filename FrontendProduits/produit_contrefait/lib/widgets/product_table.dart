import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ProductTable extends StatelessWidget {
  const ProductTable({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Consumer<ProductProvider>(
          builder: (context, provider, _) {
            final products = provider.filteredProducts;
            if (products.isEmpty) {
              return const Center(child: Text('Aucun produit enregistré.'));
            }
            return Center(
              child: Card(
                elevation: 8,
                shadowColor: const Color(0xFF607D8B).withAlpha(51), // 0.2*255 ≈ 51
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  constraints: const BoxConstraints(minWidth: 900),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF1565C0)),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 48,
                      columnSpacing: 32,
                      rows: List<DataRow>.generate(
                        products.length,
                        (index) {
                          final product = products[index];
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.blue[50];
                                }
                                return index % 2 == 0 ? Colors.blueGrey[50] : Colors.white;
                              },
                            ),
                            cells: [
                              DataCell(Center(child: Text(product.name))),
                              DataCell(Center(child: Text(product.supplier))),
                              DataCell(Center(child: Text(product.price.toString()))),
                              DataCell(Center(child: Text(product.quantity.toString()))),
                              DataCell(Center(child: Text(product.expirationDate))),
                              DataCell(
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
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
                                                const Icon(Icons.qr_code_2, color: Colors.grey, size: 32),
                                          )
                                        : const Icon(Icons.qr_code_2, color: Colors.grey, size: 32),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Modifier',
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) => EditProductDialog(product: product),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Supprimer',
                                      onPressed: () async {
                                        await Provider.of<ProductProvider>(context, listen: false).removeProduct(product.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      columns: const [
                        DataColumn(label: Center(child: Text('Nom'))),
                        DataColumn(label: Center(child: Text('Fournisseur'))),
                        DataColumn(label: Center(child: Text('Prix'))),
                        DataColumn(label: Center(child: Text('Quantité'))),
                        DataColumn(label: Center(child: Text('Date expiration'))),
                        DataColumn(label: Center(child: Text('QR Code'))),
                        DataColumn(label: Center(child: Text('Action'))),
                      ],
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
  late TextEditingController supplierController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController expirationDateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    supplierController = TextEditingController(text: widget.product.supplier);
    priceController = TextEditingController(text: widget.product.price.toString());
    quantityController = TextEditingController(text: widget.product.quantity.toString());
    expirationDateController = TextEditingController(text: widget.product.expirationDate);
  }

  @override
  void dispose() {
    nameController.dispose();
    supplierController.dispose();
    priceController.dispose();
    quantityController.dispose();
    expirationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le produit'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Fournisseur'),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: expirationDateController,
                decoration: const InputDecoration(labelText: 'Date expiration'),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final data = {
                'nom': nameController.text,
                'fournisseur': supplierController.text,
                'prix': double.tryParse(priceController.text) ?? 0,
                'quantite': int.tryParse(quantityController.text) ?? 0,
                'date_expiration': expirationDateController.text,
              };
              await Provider.of<ProductProvider>(context, listen: false)
                  .updateProduct(widget.product, data);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
