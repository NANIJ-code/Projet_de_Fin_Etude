// Importation du package http pour effectuer des requêtes HTTP
import 'package:http/http.dart' as http;
// Importation du package dart:convert pour décoder les données JSON
import 'dart:convert';
// Importation du modèle Compte pour manipuler les objets comptes
import '../models/compte.dart';

// Définition d'une classe de service pour gérer les opérations liées aux comptes
class CompteService {
  // Méthode statique asynchrone pour récupérer la liste des comptes depuis l'API
  static Future<List<Compte>> fetchComptes() async {
    // Envoie une requête GET à l'URL de l'API Django
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/comptes/'));

    // Vérifie si la requête a réussi (code 200)
    if (response.statusCode == 200) {
      // Décode la réponse JSON en une liste dynamique
      final List data = jsonDecode(response.body);
      // Transforme chaque élément JSON en objet Compte et retourne la liste
      return data.map((e) => Compte.fromJson(e)).toList();
    } else {
      // En cas d'erreur, lève une exception
      throw Exception('Erreur de chargement des comptes');
    }
  }
}
