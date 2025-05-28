import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  bool _showForm = false;
  final List<Product> _products = [];

  bool get showForm => _showForm;
  List<Product> get products => List.unmodifiable(_products);

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

  void removeProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }
} 