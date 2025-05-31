import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  bool _showForm = false;
  final List<Product> _products = [];
  String _searchQuery = '';

  bool get showForm => _showForm;
  List<Product> get products => List.unmodifiable(_products);
  String get searchQuery => _searchQuery;

  void toggleFormVisibility() {
    _showForm = !_showForm;
    notifyListeners();
  }

  void addProduct(Product product) {
    _products.insert(0, product); // Ajoute en haut de la liste
    notifyListeners();
    toggleFormVisibility();
    // Vous pourriez aussi ajouter un SnackBar ici si vous préférez
  }

  Future<void> removeProduct(int id) async {
    // ...code de suppression...
  }

  Future<void> updateProduct(Product product, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('http://localhost:8000/api/produits/${product.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      // Mets à jour localement
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = Product.fromJson(jsonDecode(response.body));
        notifyListeners();
      }
    } else {
      throw Exception('Erreur lors de la modification');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (_searchQuery.isEmpty) return products;
    return products.where((p) =>
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.supplier.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/produits/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _products.clear();
      _products.addAll(data.map((item) => Product.fromJson(item)).toList());
      notifyListeners();
    } else {
      throw Exception('Erreur lors du chargement des produits');
    }
  }
}
