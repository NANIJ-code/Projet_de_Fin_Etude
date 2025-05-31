class Product {
  final int id; // Ajoute ceci
  final String name;
  final String supplier;
  final double price;
  final int quantity;
  final String productionDate;
  final String expirationDate;
  final String qrCode;

  Product({
    required this.id, // Ajoute ceci
    required this.name,
    required this.supplier,
    required this.price,
    required this.quantity,
    required this.productionDate,
    required this.expirationDate,
    required this.qrCode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], // Ajoute ceci
      name: json['nom'],
      supplier: json['fournisseur'],
      price: double.parse(json['prix'].toString()),
      quantity: json['quantite'],
      productionDate: json['date_enregistrement'] ?? '',
      expirationDate: json['date_expiration'],
      qrCode: json['qr_code'] ?? '',
    );
  }
}