class Product {
  final int id;
  final String name;
  final String supplier;
  final double price;
  final int quantity;
  final String expirationDate;
  final String qrCode;

  Product({
    required this.id,
    required this.name,
    required this.supplier,
    required this.price,
    required this.quantity,
    required this.expirationDate,
    required this.qrCode,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['nom'],
        supplier: json['fournisseur'] is Map
            ? json['fournisseur']['nom']
            : json['fournisseur'].toString(),
        price: double.tryParse(json['prix'].toString()) ?? 0,
        quantity: json['quantite'],
        expirationDate: json['date_expiration'],
        qrCode: json['qr_code_url'] ?? '',
      );
}
