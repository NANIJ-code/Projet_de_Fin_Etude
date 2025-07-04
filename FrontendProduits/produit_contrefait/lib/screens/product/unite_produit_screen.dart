// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:produit_contrefait/services/product_service.dart';

class UniteProduitScreen extends StatefulWidget {
  const UniteProduitScreen({super.key});

  @override
  State<UniteProduitScreen> createState() => _UniteProduitScreenState();
}

class _UniteProduitScreenState extends State<UniteProduitScreen> {
  List<Map<String, dynamic>> unites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUnites();
  }

  Future<void> _loadUnites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('http://localhost:8000/api_produits/unite_produit/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          unites = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur lors du chargement des unités');
      }
    } catch (e) {
      setState(() {
        _error = "Erreur lors du chargement des unités";
        _isLoading = false;
      });
    }
  }

  void _openAddUniteDialog() {
    final formKey = GlobalKey<FormState>();
    String? lot;
    String? position;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ajouter une unité"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Lot"),
                onChanged: (v) => lot = v,
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Position"),
                onChanged: (v) => position = v,
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final success = await ProductService.addUniteProduit({
                  "lot": lot,
                  "position": position,
                });
                if (success) {
                  Navigator.pop(ctx);
                  await _loadUnites();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unité ajoutée !")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'ajout")));
                }
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unité de produit"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: _openAddUniteDialog,
            icon: const Icon(Icons.add),
            label: const Text("Nouvelle unité"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF1E3A8A)),
              headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              columns: [
                DataColumn(label: Text("ID", style: GoogleFonts.montserrat(color: Colors.white))),
                DataColumn(label: Text("Lot", style: GoogleFonts.montserrat(color: Colors.white))),
                DataColumn(label: Text("Position", style: GoogleFonts.montserrat(color: Colors.white))),
                DataColumn(label: Text("Actions", style: GoogleFonts.montserrat(color: Colors.white))),
              ],
              rows: List<DataRow>.generate(
                unites.length,
                (index) {
                  final u = unites[index];
                  final isEven = index % 2 == 0;
                  return DataRow(
                    color: WidgetStateProperty.all(isEven ? Colors.white : Colors.blue.shade50),
                    cells: [
                      DataCell(Text(u['id']?.toString() ?? '')),
                      DataCell(Text(u['lot']?.toString() ?? '')),
                      DataCell(Text(u['position']?.toString() ?? '')),
                      DataCell(Row(
                        children: [
                          // Modifier
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF1E3A8A)),
                            onPressed: () async {
                              final controller = TextEditingController(text: u['position'] ?? '');
                              final result = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Modifier la position"),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(labelText: "Position"),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, controller.text),
                                      child: const Text("Enregistrer"),
                                    ),
                                  ],
                                ),
                              );
                              if (result != null && result != u['position']) {
                                final success = await ProductService.updateUniteProduit(u['id'], {
                                  "lot": u['lot'],
                                  "position": result,
                                });
                                if (success) {
                                  setState(() => u['position'] = result);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unité modifiée")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la modification")));
                                }
                              }
                            },
                          ),
                          // Supprimer
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Confirmation"),
                                  content: const Text("Voulez-vous vraiment supprimer cette unité ?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
                                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Supprimer")),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final success = await ProductService.deleteUniteProduit(u['id']);
                                if (success) {
                                  setState(() => unites.removeWhere((e) => e['id'] == u['id']));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unité supprimée")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression")));
                                }
                              }
                            },
                          ),
                          // Visualiser
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye, color: Colors.grey),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Détail de l'unité"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("ID : ${u['id']}"),
                                      Text("Lot : ${u['lot']}"),
                                      Text("Position : ${u['position']}"),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fermer")),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}