class Utilisateur {
  final int? id;
  final int compte; // ID du compte
  final String nom;
  final String telephone;
  final String email;
  final String pays;
  final String ville;
  final String adresse;
  final String role;

  Utilisateur({
    this.id,
    required this.compte,
    required this.nom,
    required this.telephone,
    required this.email,
    required this.pays,
    required this.ville,
    required this.adresse,
    required this.role,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) => Utilisateur(
        id: json['id'],
        compte: json['compte'] is Map
            ? json['compte']['id']
            : json['compte'],
        nom: json['nom'],
        telephone: json['telephone'],
        email: json['email'],
        pays: json['pays'],
        ville: json['ville'],
        adresse: json['adresse'],
        role: json['role'],
      );

  Map<String, dynamic> toJson() => {
        'compte': compte,
        'nom': nom,
        'telephone': telephone,
        'email': email,
        'pays': pays,
        'ville': ville,
        'adresse': adresse,
        'role': role,
      };
}