import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/utilisateur.dart';

class UtilisateurService {
  static const String baseUrl = 'http://localhost:8000/api/utilisateurs/';

  static Future<List<Utilisateur>> fetchUtilisateurs({String? search}) async {
    final url = search == null || search.isEmpty
        ? baseUrl
        : '$baseUrl?search=$search';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Utilisateur.fromJson(e)).toList();
    } else {
      throw Exception('Erreur de chargement des utilisateurs');
    }
  }

  static Future<bool> addUtilisateur(Utilisateur user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<List<Utilisateur>> fetchFournisseurs() async {
    final response = await http.get(Uri.parse('http://localhost:8000/api/fournisseurs/'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Utilisateur.fromJson(e)).toList();
    } else {
      throw Exception('Erreur de chargement des fournisseurs');
    }
  }
}