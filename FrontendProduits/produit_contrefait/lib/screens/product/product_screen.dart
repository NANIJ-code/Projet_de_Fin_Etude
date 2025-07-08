// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_html/html.dart' as html;
import '../../services/product_service.dart';
import 'unite_produit_screen.dart';

import '../../widgets/responsive_sidebar.dart'; // adapte le chemin si besoin

// --- ProductScreen responsive ---
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> produits = [];
  List<Map<String, dynamic>> lots = [];
  String searchProduit = '';
  String searchLot = '';

  bool _isLoading = false;
  String? _error;
  int _produitPage = 0;
  int _lotPage = 0;
  final int _pageSize = 5;
  int selectedIndex = 3; // Correspond à "Produits" dans la sidebar
  String? nomProduit, prixProduit, descProduit, fournisseurProduit;
  String? produitLot, quantiteLot, dateExpLot;
  final _formProduitKey = GlobalKey<FormState>();
  final _formLotKey = GlobalKey<FormState>();
  final _dateExpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _dateExpController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadProduits(),
        _loadLots(),
      ]);
    } catch (e) {
      setState(() => _error = 'Erreur de chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProduits() async {
    final data = await ProductService.fetchProduits();
    setState(() => produits = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _loadLots() async {
    final data = await ProductService.fetchLots();
    setState(() => lots = List<Map<String, dynamic>>.from(data));
  }

  void _openAddProduitDialog() {
    nomProduit = null;
    prixProduit = null;
    descProduit = null;
    fournisseurProduit = null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ajouter un produit"),
        content: SizedBox(
          width: 300,
          child: Form(
            key: _formProduitKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: nomProduit,
                    decoration: const InputDecoration(
                      labelText: "Nom",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    style: const TextStyle(fontSize: 12),
                    onChanged: (v) => nomProduit = v,
                    validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    initialValue: descProduit,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    style: const TextStyle(fontSize: 12),
                    onChanged: (v) => descProduit = v,
                  ),
                  TextFormField(
                    initialValue: prixProduit,
                    decoration: const InputDecoration(
                      labelText: "Prix",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12),
                    onChanged: (v) => prixProduit = v,
                    validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null
                        ? "Prix requis et numérique"
                        : null,
                  ),
                  TextFormField(
                    initialValue: fournisseurProduit,
                    decoration: const InputDecoration(
                      labelText: "Fournisseur (id)",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12),
                    onChanged: (v) => fournisseurProduit = v,
                    validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (_formProduitKey.currentState?.validate() ?? false) {
                final data = {
                  "nom": nomProduit,
                  "description": descProduit,
                  "prix": double.tryParse(prixProduit ?? '') ?? 0.0,
                  "fournisseur": int.tryParse(fournisseurProduit ?? '') ?? 0,
                };
                final success = await ProductService.addProduit(data);
                if (success) {
                  Navigator.pop(ctx);
                  await _loadProduits();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Produit ajouté !"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Erreur lors de l'opération"),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _openAddLotDialog() {
    produitLot = null;
    quantiteLot = null;
    dateExpLot = null;
    _dateExpController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ajouter un lot"),
        content: SizedBox(
          width: 300,
          child: Form(
            key: _formLotKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Produit",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    value: produitLot,
                    items: produits
                        .map((p) => DropdownMenuItem<String>(
                              value: p['id'].toString(),
                              child: Text(p['nom'] ?? '', style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => produitLot = v),
                    validator: (v) => v == null ? "Champ requis" : null,
                  ),
                  TextFormField(
                    initialValue: quantiteLot,
                    decoration: const InputDecoration(
                      labelText: "Quantité",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12),
                    onChanged: (v) => quantiteLot = v,
                    validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    controller: _dateExpController,
                    decoration: const InputDecoration(
                      labelText: "Date d'expiration (YYYY-MM-DD)",
                      labelStyle: TextStyle(fontSize: 12),
                    ),
                    style: const TextStyle(fontSize: 12),
                    readOnly: true,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          dateExpLot = picked.toIso8601String().substring(0, 10);
                          _dateExpController.text = dateExpLot!;
                        });
                      }
                    },
                    validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (_formLotKey.currentState?.validate() ?? false) {
                final data = {
                  "produit": int.tryParse(produitLot ?? '') ?? 0,
                  "numero_lot": "LOT-${DateTime.now().millisecondsSinceEpoch}",
                  "quantite": int.tryParse(quantiteLot ?? '') ?? 0,
                  "date_expiration": dateExpLot,
                };
                final success = await ProductService.addLot(data);
                if (success) {
                  Navigator.pop(ctx);
                  await _loadLots();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lot ajouté !"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Erreur lors de l'opération"),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _openExportQrPdfDialog() {
    String? selectedProduit;
    String? selectedLot;
    List<Map<String, dynamic>> filteredLots = [];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Exporter QR Code en PDF"),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Sélectionner un produit",
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                  value: selectedProduit,
                  items: produits
                      .map((p) => DropdownMenuItem<String>(
                            value: p['id'].toString(),
                            child: Text(p['nom'] ?? '', style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedProduit = v;
                      selectedLot = null;
                      filteredLots = lots.where((l) => l['produit'].toString() == v).toList();
                    });
                  },
                  validator: (v) => v == null ? "Champ requis" : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Sélectionner un lot",
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                  value: selectedLot,
                  items: filteredLots
                      .map((l) => DropdownMenuItem<String>(
                            value: l['numero_lot'],
                            child: Text(l['numero_lot'] ?? '', style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedLot = v),
                  validator: (v) => v == null ? "Champ requis" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: selectedLot == null
                  ? null
                  : () async {
                      final pdfData = await ProductService.exportQrCodePdf(selectedLot!);
                      if (pdfData != null) {
                        final blob = html.Blob([pdfData], 'application/pdf');
                        final url = html.Url.createObjectUrlFromBlob(blob);
                        html.AnchorElement(href: url)
                          ..setAttribute('download', 'qr_code_$selectedLot.pdf')
                          ..click();
                        html.Url.revokeObjectUrl(url);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("PDF exporté avec succès !"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Erreur: Aucun PDF retourné"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: const Text("Télécharger"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProduits = produits.where((p) {
      final q = searchProduit.toLowerCase();
      return p.values.any((v) => v.toString().toLowerCase().contains(q));
    }).toList();
    final filteredLots = lots.where((l) {
      final q = searchLot.toLowerCase();
      return l.values.any((v) => v.toString().toLowerCase().contains(q));
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 900;

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    final produitStart = _produitPage * _pageSize;
    final produitEnd = (_produitPage + 1) * _pageSize;
    final paginatedProduits = filteredProduits.skip(produitStart).take(_pageSize).toList();

    final lotStart = _lotPage * _pageSize;
    final lotEnd = (_lotPage + 1) * _pageSize;
    final paginatedLots = filteredLots.skip(lotStart).take(_pageSize).toList();

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
                  // Déjà sur la page produit
                  break;
                case 4:
                  Navigator.of(context).pushReplacementNamed('/transaction');
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entête
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              color: Color(0xFF4E4FEB), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "Gestion des produits",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // --- TITRE PRODUITS ---
                    Row(
                      children: [
                        Text(
                          "Produits",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26, // Augmenté
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E4FEB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          onPressed: _openAddProduitDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Ajouter un produit",
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: isMobile ? double.infinity : 250,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher un produit...",
                          prefixIcon: const Icon(Icons.search, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F1F3),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (v) => setState(() => searchProduit = v),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - (isMobile ? 0 : 100),
                          ),
                          child: DataTable(
                            columnSpacing: 25,
                            horizontalMargin: 20,
                            headingRowColor:
                                WidgetStateProperty.resolveWith<Color?>(
                                    (states) =>
                                        const Color(0xFF4E4FEB).withOpacity(0.08)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF4E4FEB).withOpacity(0.15),
                                  width: 1),
                              color: Colors.white,
                            ),
                            columns: [
                              DataColumn(
                                  label: Text("Nom",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15))),
                              DataColumn(
                                  label: Text("Prix",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15))),
                              DataColumn(
                                  label: Text("Description",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15))),
                              DataColumn(
                                  label: Text("Fournisseur",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15))),
                              DataColumn(
                                  label: Text("Actions",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15))),
                            ],
                            rows: paginatedProduits.map((p) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    p['nom'] ?? '',
                                    style: const TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  DataCell(Text(
                                    p['prix']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  DataCell(Text(
                                    p['description'] ?? '',
                                    style: const TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  DataCell(Text(
                                    p['fournisseur']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  DataCell(
                                    SizedBox(
                                      width: 140,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue, size: 28),
                                            tooltip: "Modifier",
                                            onPressed: () {
                                              nomProduit = p['nom'];
                                              prixProduit = p['prix']?.toString();
                                              descProduit = p['description'];
                                              fournisseurProduit = p['fournisseur']?.toString();
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text("Modifier le produit"),
                                                  content: SizedBox(
                                                    width: 300,
                                                    child: Form(
                                                      key: _formProduitKey,
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            TextFormField(
                                                              initialValue: nomProduit,
                                                              decoration: const InputDecoration(
                                                                labelText: "Nom",
                                                                labelStyle: TextStyle(fontSize: 12),
                                                              ),
                                                              style: const TextStyle(fontSize: 12),
                                                              onChanged: (v) => nomProduit = v,
                                                              validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                                                            ),
                                                            TextFormField(
                                                              initialValue: prixProduit,
                                                              decoration: const InputDecoration(
                                                                labelText: "Prix",
                                                                labelStyle: TextStyle(fontSize: 12),
                                                              ),
                                                              keyboardType: TextInputType.number,
                                                              style: const TextStyle(fontSize: 12),
                                                              onChanged: (v) => prixProduit = v,
                                                              validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null
                                                                  ? "Prix requis et numérique"
                                                                  : null,
                                                            ),
                                                            TextFormField(
                                                              initialValue: descProduit,
                                                              decoration: const InputDecoration(
                                                                labelText: "Description",
                                                                labelStyle: TextStyle(fontSize: 12),
                                                              ),
                                                              style: const TextStyle(fontSize: 12),
                                                              onChanged: (v) => descProduit = v,
                                                            ),
                                                            TextFormField(
                                                              initialValue: fournisseurProduit,
                                                              decoration: const InputDecoration(
                                                                labelText: "Fournisseur",
                                                                labelStyle: TextStyle(fontSize: 12),
                                                              ),
                                                              keyboardType: TextInputType.number,
                                                              style: const TextStyle(fontSize: 12),
                                                              onChanged: (v) => fournisseurProduit = v,
                                                              validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text("Annuler"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        if (_formProduitKey.currentState?.validate() ?? false) {
                                                          final success = await ProductService.updateProduit(p['id'], {
                                                            'nom': nomProduit!,
                                                            'prix': double.tryParse(prixProduit!) ?? 0.0,
                                                            'description': descProduit!,
                                                            'fournisseur': int.tryParse(fournisseurProduit!) ?? 0,
                                                          });
                                                          if (success) {
                                                            await _loadProduits();
                                                            Navigator.of(context).pop();
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                  content: Text("Produit modifié !"),
                                                                  backgroundColor: Colors.green),
                                                            );
                                                          } else {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                  content: Text("Erreur lors de la modification"),
                                                                  backgroundColor: Colors.red),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      child: const Text("Enregistrer"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red, size: 28),
                                            tooltip: "Supprimer",
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text("Confirmation"),
                                                  content: const Text("Supprimer ce produit ?"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(ctx, false),
                                                        child: const Text("Annuler")),
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(ctx, true),
                                                        child: const Text("Supprimer")),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                final success = await ProductService.deleteProduit(p['id']);
                                                if (success) {
                                                  await _loadProduits();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                        content: Text("Produit supprimé"),
                                                        backgroundColor: Colors.green),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                        content: Text("Erreur suppression"),
                                                        backgroundColor: Colors.red),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove_red_eye,
                                                color: Colors.grey, size: 28),
                                            tooltip: "Consulter",
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text("Détail du produit"),
                                                  content: Text(
                                                    "Nom : ${p['nom']}\n"
                                                    "Prix : ${p['prix']}\n"
                                                    "Description : ${p['description']}\n"
                                                    "Fournisseur : ${p['fournisseur'] ?? ''}",
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(ctx),
                                                        child: const Text("Fermer")),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // Pagination pour les produits
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            'Page ${_produitPage + 1} / ${((filteredProduits.length - 1) / _pageSize).floor() + 1}',
                            style: const TextStyle(fontSize: 12)),
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 16),
                          onPressed: _produitPage > 0
                              ? () => setState(() => _produitPage--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          onPressed: produitEnd < filteredProduits.length
                              ? () => setState(() => _produitPage++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // --- TITRE LOTS ---
                    Row(
                      children: [
                        Text(
                          "Lots",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26, // Augmenté
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E4FEB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          onPressed: _openAddLotDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Ajouter un lot",
                              style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          onPressed: _openExportQrPdfDialog,
                          icon: const Icon(Icons.qr_code, size: 16),
                          label: const Text("QR Code", style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const UniteProduitScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.view_list, size: 16),
                          label: const Text("Unité de produit",
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: isMobile ? double.infinity : 250,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher un lot...",
                          prefixIcon: const Icon(Icons.search, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F1F3),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (v) => setState(() => searchLot = v),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // --- TABLE DES LOTS ---
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - (isMobile ? 0 : 100), // même que produits
                          ),
                          child: DataTable(
                            columnSpacing: 25,
                            horizontalMargin: 20,
                            headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                              (states) => const Color(0xFF4E4FEB).withOpacity(0.08),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF4E4FEB).withOpacity(0.15),
                                width: 1,
                              ),
                              color: Colors.white,
                            ),
                            columns: [
                              DataColumn(label: Text("N° Lot", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15))),
                              DataColumn(label: Text("Produit", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15))),
                              DataColumn(label: Text("Qté", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15))),
                              DataColumn(label: Text("Date d'ajout", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15))),
                              DataColumn(label: Text("Date d'exp", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15))),
                              DataColumn(label: Text("QR Code", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15))),
                              DataColumn(label: Text("Actions", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15))),
                            ],
                            rows: paginatedLots.isEmpty
                                ? <DataRow>[
                                    DataRow(
                                      cells: List.generate(
                                        7,
                                        (index) => index == 0
                                            ? const DataCell(Text("Aucun lot trouvé"))
                                            : const DataCell(SizedBox.shrink()),
                                      ),
                                    ),
                                  ]
                                : paginatedLots.map((l) {
                                    final produitNom = produits
                                        .firstWhere(
                                          (p) => p['id'] == l['produit'],
                                          orElse: () => {'nom': 'Inconnu'},
                                        )['nom']
                                        ?.toString() ?? 'Inconnu';
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(l['numero_lot']?.toString() ?? '', style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
                                        DataCell(Text(produitNom, style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
                                        DataCell(Text(l['quantite']?.toString() ?? '', style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
                                        DataCell(Text(l['date_enregistrement']?.toString() ?? '', style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
                                        DataCell(Text(l['date_expiration']?.toString() ?? '', style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
                                        DataCell(
                                          (l['qr_code']?.toString().isNotEmpty ?? false)
                                              ? Image.network(
                                                  l['qr_code'],
                                                  width: 32,
                                                  height: 32,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.qr_code, color: Colors.grey, size: 20),
                                                )
                                              : const Icon(Icons.qr_code, color: Colors.grey, size: 20),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 140,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.blue, size: 28),
                                                  tooltip: "Modifier",
                                                  onPressed: () {
                                                    produitLot = l['produit']?.toString();
                                                    quantiteLot = l['quantite']?.toString();
                                                    dateExpLot = l['date_expiration']?.toString();
                                                    _dateExpController.text = dateExpLot ?? '';
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text("Modifier le lot"),
                                                        content: SizedBox(
                                                          width: 300,
                                                          child: Form(
                                                            key: _formLotKey,
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  DropdownButtonFormField<String>(
                                                                    decoration: const InputDecoration(
                                                                      labelText: "Produit",
                                                                      labelStyle: TextStyle(fontSize: 12),
                                                                    ),
                                                                    value: produitLot,
                                                                    items: produits
                                                                        .map((p) => DropdownMenuItem(
                                                                              value: p['id'].toString(),
                                                                              child: Text(
                                                                                p['nom'] ?? '',
                                                                                style: const TextStyle(fontSize: 12),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ))
                                                                        .toList(),
                                                                    onChanged: (v) => setState(() => produitLot = v),
                                                                    validator: (v) => v == null ? "Champ requis" : null,
                                                                  ),
                                                                  TextFormField(
                                                                    initialValue: quantiteLot,
                                                                    decoration: const InputDecoration(
                                                                      labelText: "Quantité",
                                                                      labelStyle: TextStyle(fontSize: 12),
                                                                    ),
                                                                    keyboardType: TextInputType.number,
                                                                    style: const TextStyle(fontSize: 12),
                                                                    onChanged: (v) => quantiteLot = v,
                                                                    validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                                                                  ),
                                                                  TextFormField(
                                                                    readOnly: true,
                                                                    controller: _dateExpController,
                                                                    decoration: const InputDecoration(
                                                                      labelText: "Date d'expiration",
                                                                      labelStyle: TextStyle(fontSize: 12),
                                                                    ),
                                                                    style: const TextStyle(fontSize: 12),
                                                                    onTap: () async {
                                                                      FocusScope.of(context).requestFocus(FocusNode());
                                                                      final picked = await showDatePicker(
                                                                        context: context,
                                                                        initialDate: DateTime.tryParse(dateExpLot ?? '') ?? DateTime.now(),
                                                                        firstDate: DateTime(2020),
                                                                        lastDate: DateTime(2100),
                                                                      );
                                                                      if (picked != null) {
                                                                        setState(() {
                                                                          dateExpLot = picked.toIso8601String().substring(0, 10);
                                                                          _dateExpController.text = dateExpLot!;
                                                                        });
                                                                      }
                                                                    },
                                                                    validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(),
                                                            child: const Text("Annuler"),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () async {
                                                              if (_formLotKey.currentState?.validate() ?? false) {
                                                                final success = await ProductService.updateLot(l['id'], {
                                                                  'produit': int.tryParse(produitLot!) ?? 0,
                                                                  'quantite': int.tryParse(quantiteLot!) ?? 0,
                                                                  'date_expiration': dateExpLot!,
                                                                });
                                                                if (success) {
                                                                  await _loadLots();
                                                                  Navigator.of(context).pop();
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                        content: Text("Lot modifié !"),
                                                                        backgroundColor: Colors.green),
                                                                  );
                                                                } else {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    const SnackBar(
                                                                        content: Text("Erreur lors de la modification"),
                                                                        backgroundColor: Colors.red),
                                                                  );
                                                                }
                                                              }
                                                            },
                                                            child: const Text("Enregistrer"),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red, size: 28),
                                                  tooltip: "Supprimer",
                                                  onPressed: () async {
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text("Confirmation"),
                                                        content: const Text("Supprimer ce lot ?"),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () => Navigator.pop(ctx, false),
                                                              child: const Text("Annuler")),
                                                          TextButton(
                                                              onPressed: () => Navigator.pop(ctx, true),
                                                              child: const Text("Supprimer")),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      final success = await ProductService.deleteLot(l['id']);
                                                      if (success) {
                                                        await _loadLots();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                              content: Text("Lot supprimé"),
                                                              backgroundColor: Colors.green),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                              content: Text("Erreur suppression"),
                                                              backgroundColor: Colors.red),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.remove_red_eye,
                                                      color: Colors.grey, size: 28),
                                                  tooltip: "Consulter",
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text("Détail du lot"),
                                                        content: SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "N° Lot : ${l['numero_lot'] ?? ''}",
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                              Text(
                                                                "Produit : ${produits.firstWhere((p) => p['id'] == l['produit'], orElse: () => {'nom': 'Inconnu'})['nom']}",
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                              Text(
                                                                "Quantité : ${l['quantite'] ?? ''}",
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                              Text(
                                                                "Date d'ajout : ${l['date_enregistrement'] ?? ''}",
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                              Text(
                                                                "Date d'expiration : ${l['date_expiration'] ?? ''}",
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Center(
                                                                child: l['qr_code'] != null && l['qr_code'].toString().isNotEmpty
                                                                    ? Image.network(
                                                                        l['qr_code'],
                                                                        width: 80,
                                                                        height: 80,
                                                                        errorBuilder: (context, error, stackTrace) =>
                                                                            const Icon(Icons.qr_code, size: 50, color: Colors.grey),
                                                                      )
                                                                    : const Icon(Icons.qr_code, size: 50, color: Colors.grey),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () => Navigator.pop(ctx),
                                                              child: const Text("Fermer")),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // Pagination pour les lots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            'Page ${_lotPage + 1} / ${((filteredLots.length - 1) / _pageSize).floor() + 1}',
                            style: const TextStyle(fontSize: 11)),
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 16),
                          onPressed: _lotPage > 0
                              ? () => setState(() => _lotPage--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          onPressed: lotEnd < filteredLots.length
                              ? () => setState(() => _lotPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
