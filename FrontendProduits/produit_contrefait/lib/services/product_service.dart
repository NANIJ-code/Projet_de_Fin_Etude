import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  static const String baseUrl = 'http://127.0.0.1:8000/api_produits';

  // PRODUITS
  static Future<List<dynamic>> fetchProduits() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    var response = await http.get(
      Uri.parse('$baseUrl/produits/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 401) {
      // Token expiré, tente de le rafraîchir
      bool refreshed = await refreshAccessToken();
      if (refreshed) {
        token = prefs.getString('access_token');
        response = await http.get(
          Uri.parse('$baseUrl/produits/'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors du chargement des produits');
  }

  static Future<bool> addProduit(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    var response = await http.post(
      Uri.parse('$baseUrl/produits/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 401) {
      bool refreshed = await refreshAccessToken();
      if (refreshed) {
        token = prefs.getString('access_token');
        response = await http.post(
          Uri.parse('$baseUrl/produits/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(data),
        );
      }
    }
    return response.statusCode == 201;
  }

  static Future<bool> updateProduit(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.put(
      Uri.parse('$baseUrl/produits/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteProduit(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/produits/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }

  // LOTS
  static Future<List<dynamic>> fetchLots() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/lot_produit/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors du chargement des lots');
  }

  static Future<bool> addLot(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.post(
      Uri.parse('$baseUrl/lot_produit/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateLot(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.put(
      Uri.parse('$baseUrl/lot_produit/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteLot(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/lot_produit/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }

  // QR CODES
  static Future<List<dynamic>> fetchQRCodes(param0) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/qrcodes/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors du chargement des QR codes');
  }

  static Future<bool> addQRCode(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.post(
      Uri.parse('$baseUrl/qrcodes/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateQRCode(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.put(
      Uri.parse('$baseUrl/qrcodes/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteQRCode(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/qrcodes/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }

  static Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('access_token', data['access']);
      return true;
    }
    return false;
  }

  static Future<bool> addUniteProduit(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api_produits/unite_produit/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> fetchUniteProduits() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_produits/unité_produit'),
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

  static Future<bool> updateUniteProduit(int id, Map<String, dynamic> data) async {
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
    final response = await http.put(
      Uri.parse('http://localhost:8000/api_user/utilisateurs/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> getUniteProduitDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api_produits/unite_produit/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<List<int>?> exportQrCodePdf(String numeroLot) async {
    final url = 'http://localhost:8000/api_produits/export_qr_pdf/$numeroLot/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }
}
