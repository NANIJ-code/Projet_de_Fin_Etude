import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  static const String baseUrl = 'http://localhost:8000/api_produits/transaction/';

  // Récupère le header d'authentification JWT
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    // Utilise le même nom de clé que partout ailleurs
    final token = prefs.getString('access_token');
    if (token == null) {
      // Redirige vers la page de connexion ou affiche une erreur
      return {};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> createTransaction(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final headers = await getAuthHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchLigneTransactions() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_produits/ligne_transaction/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  static Future<bool> createLigneTransaction(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('http://localhost:8000/api_produits/ligne_transaction/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  // Utilisateurs (emetteurs et destinataires)
  static Future<List<Map<String, dynamic>>> fetchUtilisateurs() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_user/utilisateurs/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // Types de transaction (en dur, car pas d'API)
  static List<String> fetchTypes() {
    return ['B2B', 'B2C'];
  }

  static Future<List<Map<String, dynamic>>> fetchProduits() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_produits/produits/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchLots() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_produits/lot_produit/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getTransactionDetail(int id) async {
    final headers = await getAuthHeaders();
    final response = await http.get(Uri.parse('$baseUrl$id/'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> updateTransaction(int id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteTransaction(int id) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(Uri.parse('$baseUrl$id/'), headers: headers);
    return response.statusCode == 204;
  }

  static Future<bool> updateLigneTransaction(int id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final response = await http.put(
      Uri.parse('http://localhost:8000/api_produits/ligne_transaction/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteLigneTransaction(int id) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('http://localhost:8000/api_produits/ligne_transaction/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }
}