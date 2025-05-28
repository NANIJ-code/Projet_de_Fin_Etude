import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class ProductTable extends StatelessWidget {
  const ProductTable({super.key});

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context).products;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Liste des Produits",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: products.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "Aucun produit enregistré",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              horizontalMargin: 16,
                              headingRowHeight: 48,
                              dataRowHeight: 56,
                              headingRowColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => const Color(0xFFE3F2FD),
                              ),
                              columns: const [
                                DataColumn(label: Text("No")),
                                DataColumn(label: Text("Nom")),
                                DataColumn(label: Text("Fournisseur")),
                                DataColumn(label: Text("Date Prod.")),
                                DataColumn(label: Text("Date Exp.")),
                                DataColumn(label: Text("QR Code")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: products.map((product) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${products.indexOf(product) + 1}')),
                                    DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * 0.15,
                                        child: Text(
                                          product.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * 0.15,
                                        child: Text(
                                          product.supplier,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(_formatDate(product.productionDate))),
                                    DataCell(
                                      Text(
                                        _formatDate(product.expirationDate),
                                        style: TextStyle(
                                          color: _isExpired(product.expirationDate)
                                              ? Colors.red
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      InkWell(
                                        onTap: () => _showQrDialog(context, product),
                                        child: QrImageView(
                                          data: product.qrCode,
                                          size: 36,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            color: Colors.blue,
                                            onPressed: () => _editProduct(context, product),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () => _confirmDelete(context, product.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  bool _isExpired(String expirationDate) {
    try {
      final expDate = DateTime.parse(expirationDate);
      return expDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer ce produit ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .removeProduct(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text("Produit supprimé"),
                ),
              );
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _editProduct(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _EditProductForm(product: product),
      ),
    );
  }

  void _showQrDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "QR Code du Produit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: product.qrCode,
                size: 200,
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("ID: ${product.id}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Fermer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProductForm extends StatefulWidget {
  final Product product;
  
  const _EditProductForm({required this.product});

  @override
  State<_EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<_EditProductForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _supplierController;
  late DateTime _productionDate;
  late DateTime _expirationDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _supplierController = TextEditingController(text: widget.product.supplier);
    _productionDate = DateTime.parse(widget.product.productionDate);
    _expirationDate = DateTime.parse(widget.product.expirationDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Modifier le Produit",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Nom du produit",
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _supplierController,
            decoration: const InputDecoration(
              labelText: "Fournisseur",
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _productionDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _productionDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date de production",
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_productionDate)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expirationDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _expirationDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date d'expiration",
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_expirationDate)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final updatedProduct = Product(
                id: widget.product.id,
                name: _nameController.text,
                supplier: _supplierController.text,
                productionDate: DateFormat('yyyy-MM-dd').format(_productionDate),
                expirationDate: DateFormat('yyyy-MM-dd').format(_expirationDate),
                qrCode: widget.product.qrCode,
              );

              Provider.of<ProductProvider>(context, listen: false)
                  .updateProduct(updatedProduct);
              
              Navigator.pop(context);
            },
            child: const Text("Mettre à jour"),
          ),
        ],
      ),
    );
  }
}