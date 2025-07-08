// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_import, unused_element, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../settings/settings_screen.dart';
import '../../services/transaction_service.dart';
import 'ligne_transaction_screen.dart';// Pour ResponsiveSidebar

Future<Map<String, String>> getAuthHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int selectedIndex = 4;
  String search = '';

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> utilisateurs = [];
  List<String> types = ['B2B', 'B2C'];
  List<Map<String, dynamic>> produitsList = [];
  List<Map<String, dynamic>> lotsList = [];

  final _formKey = GlobalKey<FormState>();
  int? emetteurId;
  int? destinataireId;
  String? typeTransaction;
  List<Map<String, String?>> produits = [];

  Map<String, dynamic>? utilisateurConnecte;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadAllData();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('user_id');
    if (utilisateurs.isNotEmpty && currentUserId != null) {
      setState(() {
        utilisateurConnecte = utilisateurs.firstWhere(
          (u) => parseIntOrNull(u['id']) == currentUserId,
          orElse: () => {},
        );
      });
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadTransactions(),
      _loadUtilisateurs(),
      _loadProduits(),
      _loadLots(),
    ]);
  }

  Future<void> _loadTransactions() async {
    final data = await TransactionService.fetchTransactions();
    setState(() => transactions = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _loadUtilisateurs() async {
    final data = await TransactionService.fetchUtilisateurs();
    print('API utilisateurs: $data');
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('user_id');
    setState(() {
      utilisateurs = List<Map<String, dynamic>>.from(data)
          .where((u) => parseIntOrNull(u['id']) != null)
          .toList();
      utilisateurConnecte = utilisateurs.firstWhere(
        (u) => parseIntOrNull(u['id']) == currentUserId,
        orElse: () => {},
      );
      emetteurId = currentUserId;
    });
  }

  Future<void> _loadProduits() async {
    final data = await TransactionService.fetchProduits();
    setState(() {
      produitsList = List<Map<String, dynamic>>.from(data)
          .where((e) => parseIntOrNull(e['id']) != null)
          .toList();
      print('Loaded produitsList: $produitsList');
    });
  }

  Future<void> _loadLots() async {
    final data = await TransactionService.fetchLots();
    setState(() {
      lotsList = List<Map<String, dynamic>>.from(data);
      print('Loaded lotsList: $lotsList');
    });
  }

  void _openAddOrEditTransactionDialog({Map<String, dynamic>? transaction}) {
    if (transaction != null) {
      emetteurId = parseIntOrNull(transaction['emetteur']);
      destinataireId = parseIntOrNull(transaction['destinataire']);
      typeTransaction = transaction['type_transaction'];
      produits = (transaction['lignes'] as List? ?? [])
          .map<Map<String, String?>>((l) => {
                'produit': parseIntOrNull(l['produit'])?.toString(),
                'lot': l['lot']?.toString(), // Lot peut être une chaîne
              })
          .where((p) => p['produit'] != null && p['lot'] != null)
          .toList();
      if (produits.isEmpty) {
        produits = [
          {
            'produit': produitsList.isNotEmpty
                ? produitsList.first['id'].toString()
                : null,
            'lot': lotsList.isNotEmpty ? lotsList.first['numero_lot'] : null,
          }
        ];
      }
    } else {
      emetteurId = utilisateurConnecte != null
          ? parseIntOrNull(utilisateurConnecte!['id'])
          : null;
      destinataireId = null;
      typeTransaction = null;
      produits = [
        {
          'produit': produitsList.isNotEmpty
              ? produitsList.first['id'].toString()
              : null,
          'lot': lotsList.isNotEmpty ? lotsList.first['numero_lot'] : null,
        }
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16), // Réduit le padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 500,
          child: StatefulBuilder(
            builder: (context, setModalState) => Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Émetteur & Destinataire
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            enabled: false,
                            initialValue: (utilisateurConnecte != null &&
                                    utilisateurConnecte!.isNotEmpty)
                                ? '${utilisateurConnecte!['username']} (${utilisateurConnecte!['role']}, ${utilisateurConnecte!['ville']})'
                                : 'Utilisateur non trouvé',
                            decoration:
                                const InputDecoration(labelText: "Émetteur"),
                            style: const TextStyle(
                                fontSize: 14), // Réduit la taille du texte
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: "Destinataire",
                              labelStyle: TextStyle(fontSize: 14),
                            ),
                            value: destinataireId,
                            items: utilisateurs
                                .where((u) =>
                                    parseIntOrNull(u['id']) != null &&
                                    parseIntOrNull(u['id']) != emetteurId)
                                .map((u) => DropdownMenuItem<int>(
                                      value: parseIntOrNull(u['id']),
                                      child: Text(
                                        '${u['username']} (${u['role']}, ${u['ville']})',
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow
                                            .ellipsis, // Gère les textes longs
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setModalState(() => destinataireId = v),
                            validator: (v) => v == null ? "Champ requis" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Type de transaction
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Type de transaction",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      value: typeTransaction,
                      items: types
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => typeTransaction = v),
                      validator: (v) => v == null ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 12),
                    // Produits & Lots
                    Column(
                      children: [
                        ...List.generate(produits.length, (i) {
                          int? produitValue =
                              parseIntOrNull(produits[i]['produit']);
                          if (produitValue == null ||
                              !produitsList
                                  .any((e) => e['id'] == produitValue)) {
                            produitValue = produitsList.isNotEmpty
                                ? produitsList.first['id'] as int?
                                : null;
                            produits[i]['produit'] = produitValue?.toString();
                          }
                          String? lotValue = produits[i]['lot'];
                          if (lotValue == null ||
                              !lotsList
                                  .any((e) => e['numero_lot'] == lotValue)) {
                            lotValue = lotsList.isNotEmpty
                                ? lotsList.first['numero_lot'] as String?
                                : null;
                            produits[i]['lot'] = lotValue;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                      labelText: "Produit",
                                      labelStyle: TextStyle(fontSize: 14),
                                    ),
                                    value: produitsList.isNotEmpty &&
                                            produitValue != null &&
                                            produitsList.any(
                                                (e) => e['id'] == produitValue)
                                        ? produitValue
                                        : null,
                                    items: produitsList.isNotEmpty
                                        ? produitsList
                                            .where((e) => e['id'] is int)
                                            .map((e) => DropdownMenuItem<int>(
                                                  value: e['id'] as int,
                                                  child: Text(
                                                    e['nom']?.toString() ??
                                                        'N/A',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                            .toList()
                                        : [],
                                    onChanged: produitsList.isEmpty
                                        ? null
                                        : (v) => setModalState(() => produits[i]
                                            ['produit'] = v?.toString()),
                                    validator: (v) =>
                                        v == null && produitsList.isNotEmpty
                                            ? "Champ requis"
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: "Lot produit",
                                      labelStyle: TextStyle(fontSize: 14),
                                    ),
                                    value: lotValue,
                                    items: lotsList
                                        .map((e) => DropdownMenuItem<String>(
                                              value: e['numero_lot'],
                                              child: Text(
                                                e['numero_lot'],
                                                style: const TextStyle(
                                                    fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: lotsList.isEmpty
                                        ? null
                                        : (v) => setModalState(
                                            () => produits[i]['lot'] = v),
                                    validator: (v) =>
                                        v == null && lotsList.isNotEmpty
                                            ? "Champ requis"
                                            : null,
                                  ),
                                ),
                                if (i == produits.length - 1)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    tooltip: "Ajouter une ligne",
                                    onPressed:
                                        produitsList.isEmpty || lotsList.isEmpty
                                            ? null
                                            : () {
                                                setModalState(() {
                                                  produits.add({
                                                    'produit':
                                                        produitsList.isNotEmpty
                                                            ? produitsList
                                                                .first['id']
                                                                .toString()
                                                            : null,
                                                    'lot': lotsList.isNotEmpty
                                                        ? lotsList
                                                            .first['numero_lot']
                                                        : null,
                                                  });
                                                });
                                              },
                                  ),
                                if (produits.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    tooltip: "Supprimer cette ligne",
                                    onPressed: () {
                                      setModalState(() {
                                        produits.removeAt(i);
                                      });
                                    },
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Bouton valider
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final validProduits = produits
                                .where((l) =>
                                    (l['produit'] ?? '')
                                        .toString()
                                        .isNotEmpty &&
                                    (l['lot'] ?? '').toString().isNotEmpty)
                                .toList();

                            if (validProduits.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Au moins un produit et un lot sont requis"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final data = {
                              "destinataire": destinataireId,
                              "type_transaction": typeTransaction,
                              "lignes": validProduits.map((l) {
                                // inutile de chercher l'id, on envoie le numero_lot
                                return {
                                  "produit": int.parse(l['produit']!),
                                  "lots": [l['lot']],
                                };
                              }).toList(),
                            };
                            bool success;
                            if (transaction == null) {
                              success =
                                  await TransactionService.createTransaction(
                                      data);
                            } else {
                              success =
                                  await TransactionService.updateTransaction(
                                      transaction['id'], data);
                            }
                            if (success) {
                              Navigator.of(context).pop();
                              await _loadTransactions();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(transaction == null
                                      ? "Transaction créée !"
                                      : "Transaction modifiée !"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Erreur lors de l'opération"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child:
                            Text(transaction == null ? "Valider" : "Modifier"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteTransaction(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Supprimer cette transaction ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await TransactionService.deleteTransaction(id);
      if (success) {
        await _loadTransactions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction supprimée"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur suppression"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getUtilisateurLabel(dynamic utilisateurId) {
    final user = utilisateurs.firstWhere(
      (u) => u['id'] == utilisateurId,
      orElse: () => {},
    );
    if (user.isEmpty) return utilisateurId?.toString() ?? '';
    return '${user['username']} (${user['role']}, ${user['ville']})';
  }

  String _getProductName(dynamic productId) {
    final product = produitsList.firstWhere(
      (p) => p['id'] == productId,
      orElse: () => {},
    );
    return product.isNotEmpty ? product['nom'] : 'Inconnu';
  }

  Widget _buildMainContent(BuildContext context) {
    final filteredTransactions = transactions.where((t) {
      final q = search.toLowerCase();
      return t.values.any((v) => v.toString().toLowerCase().contains(q));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barre de recherche stylisée et moins longue
        Row(
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher une transaction...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (v) => setState(() => search = v),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (produitsList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Aucun produit disponible. Veuillez charger les produits."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (lotsList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Aucun lot disponible. Veuillez charger les lots."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                _openAddOrEditTransactionDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text("Ajouter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6FC9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: filteredTransactions.isEmpty
                  ? const Center(child: Text("Aucune transaction trouvée"))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF1A6FC9)),
                        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        columns: const [
                          DataColumn(label: Text("Émetteur", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Destinataire", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Type", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Produits & Lots", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Actions", style: TextStyle(color: Colors.white))),
                        ],
                        rows: List<DataRow>.generate(
                          filteredTransactions.length,
                          (index) {
                            final t = filteredTransactions[index];
                            final isEven = index % 2 == 0;
                            return DataRow(
                              color: WidgetStateProperty.all(isEven ? Colors.white : const Color(0xFFE3F0FB)),
                              cells: [
                                DataCell(Text(_getUtilisateurLabel(t['emetteur']), style: const TextStyle(fontSize: 15))),
                                DataCell(Text(_getUtilisateurLabel(t['destinataire']), style: const TextStyle(fontSize: 15))),
                                DataCell(Text(t['type_transaction'] ?? '', style: const TextStyle(fontSize: 15))),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: (t['lignes'] as List? ?? [])
                                        .map<Widget>((l) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                              child: Text(
                                                "${_getProductName(l['produit'])} (Lot: ${l['lot']})",
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _openAddOrEditTransactionDialog(transaction: t),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteTransaction(t['id']),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Row(
        children: [
          ResponsiveSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) {
              setState(() => selectedIndex = i);
              switch (i) {
                case 0:
                  Navigator.of(context).pushReplacementNamed('/dashboard');
                  break;
                case 1:
                  Navigator.of(context).pushReplacementNamed('/scan');
                  break;
                case 2:
                  Navigator.of(context).pushReplacementNamed('/user');
                  break;
                case 3:
                  Navigator.of(context).pushReplacementNamed('/product');
                  break;
                case 4:
                  // Déjà sur la page transaction
                  break;
                case 5:
                  Navigator.of(context).pushReplacementNamed('/alerts');
                  break;
                case 6:
                  Navigator.of(context).pushReplacementNamed('/settings');
                  break;
              }
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildMainContent(context),
            ),
          ),
        ],
      ),
    );
  }
}

int? parseIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String && v.isNotEmpty) {
    // Supprimer les caractères non numériques pour tenter un parsing
    final numericPart = v.replaceAll(RegExp(r'[^0-9]'), '');
    final result = int.tryParse(numericPart);
    if (result == null && v != '') {
      print('Failed to parse int from: $v (numeric part: $numericPart)');
    }
    return result;
  }
  print('Invalid value for parsing: $v');
  return null;
}
