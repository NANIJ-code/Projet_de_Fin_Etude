import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://127.0.0.1:8000/api_user';

  static Future<List<dynamic>> fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/utilisateurs/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors du chargement des utilisateurs');
  }

  static Future<bool> addUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.post(
      Uri.parse('$baseUrl/utilisateurs/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.put(
      Uri.parse('$baseUrl/utilisateurs/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteUser(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/utilisateurs/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }

  static Future<List<Map<String, dynamic>>> fetchUniteProduits() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_produits/unite_produit'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des unités de produit');
    }
  }

  static Future<bool> deleteUniteProduit(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.delete(
      Uri.parse('http://localhost:8000/api_produits/unite_produit/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }

  static Future<bool> updateUniteProduit(
      int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.put(
      Uri.parse('http://localhost:8000/api_produits/unite_produit/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> completeProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getInt('user_id');
    final response = await http.put(
      Uri.parse('http://localhost:8000/api_user/utilisateurs/$userId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getInt('user_id');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_user/utilisateurs/$userId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Impossible de récupérer le profil utilisateur');
    }
  }
}
