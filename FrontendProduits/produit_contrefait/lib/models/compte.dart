class Compte {
  final int id;
  final String username;
  final bool isActive;

  Compte({required this.id, required this.username, required this.isActive});

  factory Compte.fromJson(Map<String, dynamic> json) => Compte(
        id: json['id'],
        username: json['username'],
        isActive: json['is_active'],
      );
}