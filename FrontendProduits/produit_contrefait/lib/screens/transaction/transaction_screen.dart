// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Sidebar centrée et stylée ---
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

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

// --- Page Transaction ---
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  int selectedIndex = 4;

  String search = '';

  // Simulations de données pour les selects
  final List<String> emetteurs = ['Alice', 'Bob', 'Charlie'];
  final List<String> destinataires = ['David', 'Eve', 'Frank'];
  final List<String> types = ['Vente', 'Achat', 'Transfert'];
  final List<String> produitsList = ['Paracétamol', 'Ibuprofène', 'Aspirine'];
  final List<String> lotsList = ['Lot A', 'Lot B', 'Lot C'];

  List<Map<String, String>> transactions = [
    {
      'emetteur': 'Alice',
      'destinataire': 'Bob',
      'type': 'Vente',
      'produits': 'Paracétamol (Lot A), Ibuprofène (Lot B)'
    },
    {
      'emetteur': 'Charlie',
      'destinataire': 'David',
      'type': 'Achat',
      'produits': 'Aspirine (Lot C)'
    },
  ];

  final _formKey = GlobalKey<FormState>();
  String? emetteur;
  String? destinataire;
  String? typeTransaction;
  List<Map<String, String?>> produits = [
    {'produit': null, 'lot': null}
  ];

  void _openAddTransactionDialog() {
    setState(() {
      emetteur = null;
      destinataire = null;
      typeTransaction = null;
      produits = [
        {'produit': null, 'lot': null}
      ];
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
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
                    // Ligne 1 : Emetteur & Destinataire
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Émetteur",
                            ),
                            value: emetteur,
                            items: emetteurs
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (v) => setModalState(() => emetteur = v),
                            validator: (v) => v == null ? "Champ requis" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Destinataire",
                            ),
                            value: destinataire,
                            items: destinataires
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setModalState(() => destinataire = v),
                            validator: (v) => v == null ? "Champ requis" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Ligne 2 : Type de transaction centré
                    Center(
                      child: SizedBox(
                        width: 250,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Type de transaction",
                          ),
                          value: typeTransaction,
                          items: types
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setModalState(() => typeTransaction = v),
                          validator: (v) => v == null ? "Champ requis" : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Ligne 3+ : Produit & Lot produit (dynamique)
                    Column(
                      children: [
                        ...List.generate(produits.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: "Produit",
                                    ),
                                    value: produits[i]['produit'],
                                    items: produitsList
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setModalState(
                                        () => produits[i]['produit'] = v),
                                    validator: (v) =>
                                        v == null ? "Champ requis" : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: "Lot produit",
                                    ),
                                    value: produits[i]['lot'],
                                    items: lotsList
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setModalState(
                                        () => produits[i]['lot'] = v),
                                    validator: (v) =>
                                        v == null ? "Champ requis" : null,
                                  ),
                                ),
                                if (i == produits.length - 1)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    tooltip: "Ajouter une ligne",
                                    onPressed: () {
                                      setModalState(() {
                                        produits.add(
                                            {'produit': null, 'lot': null});
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
                    const SizedBox(height: 18),
                    // Bouton valider
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() {
                              transactions.add({
                                'emetteur': emetteur ?? '',
                                'destinataire': destinataire ?? '',
                                'type': typeTransaction ?? '',
                                'produits': produits
                                    .map((p) =>
                                        "${p['produit']} (Lot ${p['lot']})")
                                    .join(', ')
                              });
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Valider"),
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

  void _onSidebarItemSelected(int i) {
    setState(() => selectedIndex = i);
    var navItems = const [
      _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
      _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
      _NavItem(Icons.account_circle_outlined, "Utilisateur", '/user'),
      _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
      _NavItem(Icons.swap_horiz, "Transaction", '/transaction'),
      _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
      _NavItem(Icons.settings, "Paramètres", '/settings'),
    ];
    Navigator.of(context).pushReplacementNamed(navItems[i].route);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final filteredTransactions = transactions.where((t) {
      final q = search.toLowerCase();
      return t.values.any((v) => v.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Row(
        children: [
          ResponsiveSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: _onSidebarItemSelected,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12.0 : 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header + bouton ajouter
                  Row(
                    children: [
                      Text(
                        "Gestion des Transactions",
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xFF1A6FC9),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
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
                        onPressed: _openAddTransactionDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter une transaction"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Champ de recherche
                  SizedBox(
                    width: 350,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher une transaction...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F1F3),
                      ),
                      onChanged: (v) => setState(() => search = v),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Tableau stylé et plus long
                  Expanded(
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
                                label: Text("Émetteur",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                              ),
                              DataColumn(
                                label: Text("Destinataire",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                              ),
                              DataColumn(
                                label: Text("Type",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                              ),
                              DataColumn(
                                label: Text("Produits",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                              ),
                            ],
                            rows: filteredTransactions
                                .map((t) => DataRow(
                                      cells: [
                                        DataCell(Text(t['emetteur'] ?? '',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15))),
                                        DataCell(Text(t['destinataire'] ?? '',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15))),
                                        DataCell(Text(t['type'] ?? '',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15))),
                                        DataCell(Text(t['produits'] ?? '',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15))),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
