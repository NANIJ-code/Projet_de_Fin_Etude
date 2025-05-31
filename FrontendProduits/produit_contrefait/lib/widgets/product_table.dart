import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

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
                              DataCell(Center(child: Text(product.productionDate))),
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
                                      onPressed: () {
                                        Provider.of<ProductProvider>(context, listen: false)
                                            .updateProduct(product);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Supprimer',
                                      onPressed: () {
                                        Provider.of<ProductProvider>(context, listen: false)
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
                      columns: const [
                        DataColumn(label: Center(child: Text('Nom'))),
                        DataColumn(label: Center(child: Text('Fournisseur'))),
                        DataColumn(label: Center(child: Text('Prix'))),
                        DataColumn(label: Center(child: Text('Quantité'))),
                        DataColumn(label: Center(child: Text('Date enregistrement'))),
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
