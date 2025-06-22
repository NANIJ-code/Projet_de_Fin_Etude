// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:produit_contrefait/models/utilisateur.dart';
import 'package:produit_contrefait/providers/user_provider.dart';
import 'package:produit_contrefait/models/compte.dart';
import 'package:produit_contrefait/providers/compte_provider.dart';
import 'package:produit_contrefait/providers/role_provider.dart';

// Sidebar harmonisée avec "Transaction"
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
            // Logo centré
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6FC9).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.security, color: Color(0xFF1A6FC9), size: 28),
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
            // Menu vertical, icônes centrés
            ...List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isActive = widget.selectedIndex == i;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => widget.onItemSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                      // Icône parfaitement centrée dans un carré
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
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.normal,
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
            // Profil utilisateur centré
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
                      child: const Icon(Icons.person, color: Color(0xFF1A6FC9), size: 26),
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

// ----------- PAGE PRINCIPALE -----------
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int selectedIndex = 2;

  bool _isLoading = false;

  List<Utilisateur> _users = [];
  List<Compte> _comptes = [];
  List<Map<String, dynamic>> _roles = [];

  Compte? _selectedCompte;
  String? _selectedRole;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _onSidebarItemSelected(int i) {
    setState(() => selectedIndex = i);
    switch (i) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/scan');
        break;
      case 2:
        // Déjà sur la page utilisateur
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/product');
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
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadUsers(),
        _loadComptes(),
        _loadRoles(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers({String? search}) async {
    try {
      final users = await UtilisateurService.fetchUtilisateurs(search: search);
      setState(() => _users = users);
    } catch (e) {
      setState(() {
        _users = [];
      });
      rethrow;
    }
  }

  Future<void> _loadComptes() async {
    try {
      final comptes = await CompteService.fetchComptes();
      setState(() => _comptes = comptes);
    } catch (e) {
      setState(() {
        _comptes = [];
      });
      rethrow;
    }
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await RoleService.fetchRoles();
      setState(() => _roles = roles);
    } catch (e) {
      setState(() {
        _roles = [];
      });
      rethrow;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _addUser() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedCompte == null) return;

    setState(() => _isLoading = true);

    try {
      final user = Utilisateur(
        compte: _selectedCompte!.id,
        nom: _nameController.text,
        telephone: _phoneController.text,
        email: _emailController.text,
        pays: _countryController.text,
        ville: _cityController.text,
        adresse: _addressController.text,
        role: _selectedRole ?? '',
      );

      final success = await UtilisateurService.addUtilisateur(user);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Utilisateur ajouté !' : 'Erreur lors de l\'ajout'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        await _loadUsers();
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _countryController.clear();
        _cityController.clear();
        _addressController.clear();
        setState(() {
          _selectedRole = null;
          _selectedCompte = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      drawer: isMobile
          ? ResponsiveSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) {
                Navigator.of(context).pop();
                _onSidebarItemSelected(i);
              },
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            ResponsiveSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: _onSidebarItemSelected,
            ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F5F7), Color(0xFFEAEAEC)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12.0 : 32.0),
                child: ListView(
                  children: [
                    // Bannière style dashboard
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A6FC9), Color(0xFF16213E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gestion des Utilisateurs",
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            onPressed: _loadData,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Formulaire d'ajout
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ajouter un Utilisateur",
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 20),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 600;
                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      // Compte
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: DropdownButtonFormField<Compte>(
                                          value: _selectedCompte,
                                          decoration: InputDecoration(
                                            labelText: "Compte",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(
                                                Icons.account_circle,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          items: _comptes
                                              .map((compte) => DropdownMenuItem(
                                                    value: compte,
                                                    child: Text(
                                                      compte.username,
                                                      style: GoogleFonts
                                                          .montserrat(),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) => setState(
                                              () => _selectedCompte = value),
                                          validator: (value) => value == null
                                              ? "Champ requis"
                                              : null,
                                        ),
                                      ),
                                      // Nom
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: TextFormField(
                                          controller: _nameController,
                                          style: GoogleFonts.montserrat(),
                                          decoration: InputDecoration(
                                            labelText: "Nom complet",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(Icons.person,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          validator: (v) => v?.isEmpty ?? true
                                              ? "Champ requis"
                                              : null,
                                        ),
                                      ),
                                      // Téléphone
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: TextFormField(
                                          controller: _phoneController,
                                          style: GoogleFonts.montserrat(),
                                          decoration: InputDecoration(
                                            labelText: "Téléphone",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(Icons.phone,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          validator: (v) => v?.isEmpty ?? true
                                              ? "Champ requis"
                                              : null,
                                        ),
                                      ),
                                      // Email
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: TextFormField(
                                          controller: _emailController,
                                          style: GoogleFonts.montserrat(),
                                          decoration: InputDecoration(
                                            labelText: "Email",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(Icons.email,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          validator: (v) =>
                                              v?.contains('@') ?? false
                                                  ? null
                                                  : "Email invalide",
                                        ),
                                      ),
                                      // Pays
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: TextFormField(
                                          controller: _countryController,
                                          style: GoogleFonts.montserrat(),
                                          decoration: InputDecoration(
                                            labelText: "Pays",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(Icons.flag,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          validator: (v) => v?.isEmpty ?? true
                                              ? "Champ requis"
                                              : null,
                                        ),
                                      ),
                                      // Ville
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: TextFormField(
                                          controller: _cityController,
                                          style: GoogleFonts.montserrat(),
                                          decoration: InputDecoration(
                                            labelText: "Ville",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(
                                                Icons.location_city,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          validator: (v) => v?.isEmpty ?? true
                                              ? "Champ requis"
                                              : null,
                                        ),
                                      ),
                                      // Adresse
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: TextFormField(
                                          controller: _addressController,
                                          style: GoogleFonts.montserrat(),
                                          decoration: InputDecoration(
                                            labelText: "Adresse",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(Icons.home,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          validator: (v) => v?.isEmpty ?? true
                                              ? "Champ requis"
                                              : null,
                                        ),
                                      ),
                                      // Rôle
                                      SizedBox(
                                        width: isWide ? 280 : double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedRole,
                                          style: GoogleFonts.montserrat(),
                                          decoration: InputDecoration(
                                            labelText: "Rôle",
                                            labelStyle:
                                                GoogleFonts.montserrat(),
                                            prefixIcon: const Icon(
                                                Icons.security,
                                                color: Color(0xFF6B6B6B)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F3),
                                          ),
                                          items: _roles
                                              .map((role) =>
                                                  DropdownMenuItem<String>(
                                                    value: role['value']
                                                        as String?,
                                                    child: Text(
                                                      role['label'] ??
                                                          'Sans label',
                                                      style: GoogleFonts
                                                          .montserrat(),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) => setState(
                                              () => _selectedRole = value),
                                          validator: (value) => value == null
                                              ? 'Sélectionnez un rôle'
                                              : null,
                                        ),
                                      ),
                                      // Bouton d'ajout
                                      SizedBox(
                                        width: double.infinity,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed:
                                                _isLoading ? null : _addUser,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF4E4FEB),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 24),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 3,
                                              shadowColor:
                                                  const Color(0xFF4E4FEB)
                                                      .withOpacity(0.3),
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    "AJOUTER UTILISATEUR",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Liste des utilisateurs
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Liste des Utilisateurs",
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 300,
                                  child: TextField(
                                    style: GoogleFonts.montserrat(),
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher un utilisateur...',
                                      hintStyle: GoogleFonts.montserrat(),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Color(0xFF6B6B6B)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF1F1F3),
                                    ),
                                    onChanged: (value) =>
                                        _loadUsers(search: value),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : _users.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(40),
                                          child: Text(
                                            'Aucun utilisateur trouvé',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              color: const Color(0xFF6B6B6B),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 1400),
                                          child: DataTable(
                                            columnSpacing: 32,
                                            horizontalMargin: 18,
                                            headingRowColor: WidgetStateProperty
                                                .resolveWith<Color?>(
                                              (states) =>
                                                  const Color(0xFF4E4FEB)
                                                      .withOpacity(0.08),
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: const Color(0xFF4E4FEB)
                                                      .withOpacity(0.15),
                                                  width: 1.5),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            columns: [
                                              DataColumn(
                                                label: Text("Nom",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16)),
                                              ),
                                              DataColumn(
                                                label: Text("Email",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16)),
                                              ),
                                              DataColumn(
                                                label: Text("Téléphone",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16)),
                                              ),
                                              DataColumn(
                                                label: Text("Rôle",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16)),
                                              ),
                                              DataColumn(
                                                label: Text("Actions",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16)),
                                              ),
                                            ],
                                            rows: _users
                                                .map((user) => DataRow(
                                                      cells: [
                                                        DataCell(Text(user.nom,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        15))),
                                                        DataCell(Text(
                                                            user.email,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        15))),
                                                        DataCell(Text(
                                                            user.telephone,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        15))),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                      0xFF4E4FEB)
                                                                  .withOpacity(
                                                                      0.09),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Text(
                                                              user.role,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: const Color(
                                                                    0xFF4E4FEB),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Wrap(
                                                            spacing: 8,
                                                            children: [
                                                              IconButton(
                                                                icon: const Icon(
                                                                    Icons.edit,
                                                                    color: Color(
                                                                        0xFF4E4FEB)),
                                                                tooltip:
                                                                    "Modifier",
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                              IconButton(
                                                                icon: const Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Color(
                                                                        0xFFB42B51)),
                                                                tooltip:
                                                                    "Supprimer",
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                          ],
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

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      const _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
      const _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
      const _NavItem(Icons.account_circle_outlined, "Utilisateurs", '/users'),
      const _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
      const _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
      const _NavItem(Icons.settings, "Paramètres", '/settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo/Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.security, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Text(
                  "SecureScan",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Menu items
          ...navItems.map((item) => _NavTile(
                icon: item.icon,
                label: item.label,
                route: item.route,
              )),
          const Spacer(),
          // User profile
          const Padding(
            padding: EdgeInsets.all(24),
            child: _UserProfile(),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = ModalRoute.of(context)?.settings.name == route;

    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4E4FEB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              size: 26,
            ),
            title: Text(
              label,
              style: GoogleFonts.montserrat(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(route);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            minLeadingWidth: 0,
          ),
        ),
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              "Administrateur",
              style: GoogleFonts.montserrat(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white70, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;
  const NavItem(this.icon, this.label, this.route);
}
