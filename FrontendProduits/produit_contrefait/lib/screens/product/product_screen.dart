// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Sidebar stylée et navigation fonctionnelle
class ResponsiveSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  const ResponsiveSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  bool _isHovered = false;

  final List<_NavItem> navItems = const [
    _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
    _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
    _NavItem(Icons.account_circle_outlined, "Utilisateur", '/user'),
    _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
    _NavItem(Icons.swap_horiz, "Transaction", '/transaction'),
    _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
    _NavItem(Icons.settings, "Paramètres", '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final sidebarWidth = _isHovered || isMobile ? 220.0 : 80.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: sidebarWidth,
        constraints: BoxConstraints(maxWidth: sidebarWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.10),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 28),
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6FC9).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.security,
                    color: Color(0xFF1A6FC9), size: 28),
              ),
            ),
            if (_isHovered || isMobile)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text(
                  "SecureScan",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: const Color(0xFF1A6FC9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            ...List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isActive = widget.selectedIndex == i;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => widget.onItemSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: _isHovered || isMobile ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1A6FC9).withOpacity(0.13)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1A6FC9).withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: isActive
                              ? const Color(0xFF1A6FC9)
                              : const Color(0xFFB3B8C8),
                          size: 26,
                        ),
                      ),
                      if (_isHovered || isMobile)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            item.label,
                            style: GoogleFonts.montserrat(
                              color: isActive
                                  ? const Color(0xFF1A6FC9)
                                  : const Color(0xFFB3B8C8),
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A6FC9).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person,
                          color: Color(0xFF1A6FC9), size: 26),
                    ),
                    if (_isHovered || isMobile)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin",
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF1A6FC9),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Administrateur",
                              style: GoogleFonts.montserrat(
                                color: Colors.blueGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ProductScreen responsive ---
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int selectedIndex = 3;

  List<Map<String, dynamic>> produits = [
    {
      'nom': 'Paracétamol',
      'prix': '1000',
      'description': 'Antidouleur',
      'fournisseur': 'Sanofi'
    },
    {
      'nom': 'Ibuprofène',
      'prix': '1200',
      'description': 'Anti-inflammatoire',
      'fournisseur': 'Bayer'
    },
  ];
  List<Map<String, dynamic>> lots = [
    {
      'numero': 'L001',
      'produit': 'Paracétamol',
      'quantite': '50',
      'dateEnreg': '2024-06-21',
      'dateExp': '2025-01-01',
      'qr': 'QR1'
    },
    {
      'numero': 'L002',
      'produit': 'Ibuprofène',
      'quantite': '30',
      'dateEnreg': '2024-06-21',
      'dateExp': '2024-12-01',
      'qr': 'QR2'
    },
  ];

  String searchProduit = '';
  String searchLot = '';

  // Pour le formulaire produit
  final _formProduitKey = GlobalKey<FormState>();
  String? nomProduit;
  String? prixProduit;
  String? descProduit;
  String? fournisseurProduit;

  // Pour le formulaire lot
  final _formLotKey = GlobalKey<FormState>();
  String? produitLot;
  String? quantiteLot;
  String? dateExpLot;

  // Pour le formulaire QR Code
  String? produitQr;
  String? numeroLotQr;

  void _openAddProduitDialog() {
    nomProduit = null;
    prixProduit = null;
    descProduit = null;
    fournisseurProduit = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un produit"),
        content: SizedBox(
          width: 350,
          child: Form(
            key: _formProduitKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Nom"),
                  onChanged: (v) => nomProduit = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Prix"),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => prixProduit = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Description"),
                  onChanged: (v) => descProduit = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Fournisseur"),
                  onChanged: (v) => fournisseurProduit = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formProduitKey.currentState?.validate() ?? false) {
                setState(() {
                  produits.add({
                    'nom': nomProduit!,
                    'prix': prixProduit!,
                    'description': descProduit!,
                    'fournisseur': fournisseurProduit!,
                  });
                });
                Navigator.of(context).pop();
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un lot"),
        content: SizedBox(
          width: 350,
          child: Form(
            key: _formLotKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Produit"),
                  value: produitLot,
                  items: produits
                      .map((p) => DropdownMenuItem(
                            value: p['nom'] as String,
                            child: Text(p['nom'] as String),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => produitLot = v),
                  validator: (v) => v == null ? "Champ requis" : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Quantité"),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => quantiteLot = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Date d'expiration"),
                  readOnly: true,
                  controller: TextEditingController(text: dateExpLot),
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
                      });
                    }
                  },
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ requis" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formLotKey.currentState?.validate() ?? false) {
                setState(() {
                  lots.add({
                    'numero': 'L${lots.length + 1}'.padLeft(4, '0'),
                    'produit': produitLot!,
                    'quantite': quantiteLot!,
                    'dateEnreg':
                        DateTime.now().toIso8601String().substring(0, 10),
                    'dateExp': dateExpLot!,
                    'qr': 'QR${lots.length + 1}'
                  });
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _openQrCodeDialog() {
    produitQr = null;
    numeroLotQr = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Générer un QR Code"),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Produit"),
                value: produitQr,
                items: produits
                    .map((p) => DropdownMenuItem(
                          value: p['nom'] as String,
                          child: Text(p['nom'] as String),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    produitQr = v;
                    numeroLotQr = null;
                  });
                },
                validator: (v) => v == null ? "Champ requis" : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Numéro de lot"),
                value: numeroLotQr,
                items: lots
                    .where(
                        (l) => produitQr == null || l['produit'] == produitQr)
                    .map((l) => DropdownMenuItem(
                          value: l['numero'] as String,
                          child: Text(l['numero'] as String),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => numeroLotQr = v),
                validator: (v) => v == null ? "Champ requis" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("QR Code téléchargé (simulation)")),
              );
            },
            child: const Text("Télécharger"),
          ),
        ],
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

    const List<_NavItem> navItems = [
      _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
      _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
      _NavItem(Icons.account_circle_outlined, "Utilisateur", '/user'),
      _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
      _NavItem(Icons.swap_horiz, "Transaction", '/transaction'),
      _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
      _NavItem(Icons.settings, "Paramètres", '/settings'),
    ];

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Row(
        children: [
          ResponsiveSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) {
              setState(() => selectedIndex = i);
              Navigator.of(context).pushReplacementNamed(navItems[i].route);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entête stylé en haut de la page
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              color: Color(0xFF4E4FEB), size: 36),
                          const SizedBox(width: 12),
                          Text(
                            "Gestion des produits",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Section Produits
                    Row(
                      children: [
                        Text(
                          "Produits",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _openAddProduitDialog,
                          icon: const Icon(Icons.add),
                          label: const Text("Ajouter un produit"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: isMobile ? double.infinity : 350,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher un produit...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F1F3),
                        ),
                        onChanged: (v) => setState(() => searchProduit = v),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
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
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 900),
                          child: DataTable(
                            columnSpacing: 32,
                            horizontalMargin: 18,
                            headingRowColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (states) =>
                                  const Color(0xFF4E4FEB).withOpacity(0.08),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      const Color(0xFF4E4FEB).withOpacity(0.15),
                                  width: 1.5),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            columns: [
                              DataColumn(
                                  label: Text("Nom",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Prix",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Description",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Fournisseur",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Actions",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredProduits
                                .map((p) => DataRow(
                                      cells: [
                                        DataCell(Text(p['nom'] ?? '')),
                                        DataCell(Text(p['prix'] ?? '')),
                                        DataCell(Text(p['description'] ?? '')),
                                        DataCell(Text(p['fournisseur'] ?? '')),
                                        DataCell(
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  tooltip: "Modifier",
                                                  onPressed: () {},
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  tooltip: "Supprimer",
                                                  onPressed: () {},
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.remove_red_eye,
                                                      color: Colors.grey),
                                                  tooltip: "Consulter",
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Section Lots avec boutons sur la même ligne que le titre
                    Row(
                      children: [
                        Text(
                          "Lots",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _openAddLotDialog,
                          icon: const Icon(Icons.add),
                          label: const Text("Ajouter un lot"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _openQrCodeDialog,
                          icon: const Icon(Icons.qr_code),
                          label: const Text("Qr Code"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: isMobile ? double.infinity : 350,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher un lot...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F1F3),
                        ),
                        onChanged: (v) => setState(() => searchLot = v),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
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
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 900),
                          child: DataTable(
                            columnSpacing: 27,
                            horizontalMargin: 18,
                            headingRowColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (states) =>
                                  const Color(0xFF4E4FEB).withOpacity(0.08),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      const Color(0xFF4E4FEB).withOpacity(0.15),
                                  width: 1.5),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            columns: [
                              DataColumn(
                                  label: Text("N° Lot",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Produit",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Qté",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Date d'ajout",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Date d'exp",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Qr Code",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text("Actions",
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredLots
                                .map((l) => DataRow(
                                      cells: [
                                        DataCell(Text(l['numero'] ?? '')),
                                        DataCell(Text(l['produit'] ?? '')),
                                        DataCell(Text(l['quantite'] ?? '')),
                                        DataCell(Text(l['dateEnreg'] ?? '')),
                                        DataCell(Text(l['dateExp'] ?? '')),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.qr_code,
                                                color: Colors.green),
                                            tooltip: "Voir QR Code",
                                            onPressed: () {},
                                          ),
                                        ),
                                        DataCell(Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              tooltip: "Modifier",
                                              onPressed: () {},
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              tooltip: "Supprimer",
                                              onPressed: () {},
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_red_eye,
                                                  color: Colors.grey),
                                              tooltip: "Consulter",
                                              onPressed: () {},
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
