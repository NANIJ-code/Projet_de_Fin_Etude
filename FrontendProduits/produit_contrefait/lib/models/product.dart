class Product {
  final String id;
  final String name;
  final String supplier;
  final String productionDate;
  final String expirationDate;
  final String qrCode;

  Product({
    required this.id,
    required this.name,
    required this.supplier,
    required this.productionDate,
    required this.expirationDate,
    required this.qrCode,
  });

  factory Product.empty() {
    return Product(
      id: '',
      name: '',
      supplier: '',
      productionDate: '',
      expirationDate: '',
      qrCode: '',
    );
  }
}