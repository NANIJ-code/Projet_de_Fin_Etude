// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/transaction_service.dart';

class LigneTransactionScreen extends StatefulWidget {
  const LigneTransactionScreen({super.key});

  @override
  State<LigneTransactionScreen> createState() => _LigneTransactionScreenState();
}

class _LigneTransactionScreenState extends State<LigneTransactionScreen> {
  List<Map<String, dynamic>> lignes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLignes();
  }

  Future<void> _loadLignes() async {
    final data = await TransactionService.fetchLigneTransactions();
    setState(() {
      lignes = data;
      isLoading = false;
    });
  }

  void _showLigneDetails(Map<String, dynamic> ligne) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Détails de la ligne de transaction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Produit : ${ligne['produit']}"),
            Text("Lots : ${(ligne['lots'] as List).join(', ')}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void _openAddOrEditLigneDialog({Map<String, dynamic>? ligne}) {
    String? produit = ligne?['produit']?.toString();
    List<String> lots = ligne?['lots'] != null ? List<String>.from(ligne!['lots'].map((e) => e.toString())) : [];
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ligne == null ? "Créer une ligne de transaction" : "Modifier la ligne"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: produit,
                decoration: const InputDecoration(labelText: "Produit"),
                onChanged: (v) => produit = v,
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
              TextFormField(
                initialValue: lots.join(', '),
                decoration: const InputDecoration(labelText: "Lots (séparés par des virgules)"),
                onChanged: (v) => lots = v.split(',').map((e) => e.trim()).toList(),
                validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final data = {
                  "produit": produit,
                  "lots": lots,
                };
                bool success;
                if (ligne == null) {
                  success = await TransactionService.createLigneTransaction(data);
                } else {
                  success = await TransactionService.updateLigneTransaction(ligne['id'], data);
                }
                if (!mounted) return;
                Navigator.pop(ctx);
                if (success) {
                  _loadLignes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ligne == null ? "Ligne créée !" : "Ligne modifiée !"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erreur lors de l'opération"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(ligne == null ? "Valider" : "Modifier"),
          ),
        ],
      ),
    );
  }

  void _deleteLigne(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Supprimer cette ligne ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Supprimer")),
        ],
      ),
    );
    if (confirm == true) {
      final success = await TransactionService.deleteLigneTransaction(id);
      if (success) {
        await _loadLignes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ligne supprimée"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur suppression"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A6FC9),
        title: const Text("Lignes de transaction"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A6FC9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => _openAddOrEditLigneDialog(),
            icon: const Icon(Icons.add),
            label: const Text("Nouvelle ligne"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 32,
                    horizontalMargin: 18,
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) => const Color(0xFF1A6FC9).withOpacity(0.08),
                    ),
                    columns: [
                      DataColumn(
                        label: Text("Produit", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text("Lots", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      DataColumn(
                        label: Text("Actions", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ],
                    rows: lignes
                        .map((l) => DataRow(
                              cells: [
                                DataCell(Text(l['produit'] ?? '', style: GoogleFonts.montserrat(fontSize: 15))),
                                DataCell(Text((l['lots'] as List).join(', '), style: GoogleFonts.montserrat(fontSize: 15))),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye, color: Color(0xFF1A6FC9)),
                                      tooltip: "Visualiser",
                                      onPressed: () => _showLigneDetails(l),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      tooltip: "Modifier",
                                      onPressed: () => _openAddOrEditLigneDialog(ligne: l),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: "Supprimer",
                                      onPressed: () => _deleteLigne(l['id']),
                                    ),
                                  ],
                                )),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }
}