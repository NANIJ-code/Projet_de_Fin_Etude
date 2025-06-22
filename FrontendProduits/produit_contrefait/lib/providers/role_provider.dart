import 'package:http/http.dart' as http;
import 'dart:convert';

class RoleService {
  static Future<List<Map<String, String>>> fetchRoles() async {
    final response = await http.get(Uri.parse('http://localhost:8000/api/roles/'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Map<String, String>>((e) => {
        'value': e['value'] as String,
        'label': e['label'] as String,
      }).toList();
    } else {
      throw Exception('Erreur de chargement des rôles');
    }
  }
}