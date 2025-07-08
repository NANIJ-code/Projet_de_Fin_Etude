// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_service.dart';
import '../../widgets/responsive_sidebar.dart'; // adapte le chemin si besoin

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedRole;
  String? _currentRole;
  bool _isLoading = false;
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  final List<Map<String, dynamic>> _roles = [
    {"value": "distributeur", "label": "Distributeur"},
    {"value": "gerant", "label": "Gérant"},
    {"value": "admin", "label": "Admin"},
    {"value": "fabricant", "label": "Fabricant"},
  ];
  int selectedSidebarIndex = 2; // Pour "Utilisateur"

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((u) {
        final name = (u['username'] ?? '').toLowerCase();
        final email = (u['email'] ?? '').toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await UserService.fetchUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      setState(() {
        _users = [];
        _filteredUsers = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addUser() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    try {
      final userData = {
        "username": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "role": _selectedRole ?? '',
      };
      final success = await UserService.addUser(userData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Utilisateur ajouté !' : 'Erreur lors de l\'ajout'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() => _selectedRole = null);
        await _loadUsers();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cet utilisateur ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Supprimer")),
        ],
      ),
    );
    if (confirm == true) {
      final success = await UserService.deleteUser(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Utilisateur supprimé'
              : 'Erreur lors de la suppression'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) await _loadUsers();
    }
  }

  Future<void> _editUser(Map user) async {
    final nameController = TextEditingController(text: user['username'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    String? role = user['role'];
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Modifier l'utilisateur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: "Rôle"),
              items: _roles
                  .map((r) => DropdownMenuItem<String>(
                        value: r['value'],
                        child: Text(r['label'] ?? ''),
                      ))
                  .toList(),
              onChanged: (v) => role = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final success = await UserService.updateUser(user['id'], {
                "username": nameController.text,
                "email": emailController.text,
                "role": role,
              });
              Navigator.pop(ctx, success);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
    if (result == true) {
      await _loadUsers();
    }
  }

  void _viewUser(Map user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Détails de l'utilisateur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom : ${user['username'] ?? ''}"),
            Text("Email : ${user['email'] ?? ''}"),
            Text("Rôle : ${user['role'] ?? ''}"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Fermer")),
        ],
      ),
    );
  }

  Future<void> _loadCurrentUser() async {
    final user =
        await UserService.getCurrentUser(); // Doit retourner {'role': ...}
    setState(() {
      _currentRole = user['role'];
    });
  }

  Future<void> completeProfile() async {
    final data = {
      "telephone": _phoneController.text,
      "pays": _countryController.text,
      "ville": _cityController.text,
      "adresse": _addressController.text,
    };
    final success = await UserService.completeProfile(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            success ? "Profil mis à jour !" : "Erreur lors de la mise à jour"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  List<Map<String, dynamic>> getRolesForCurrentUser(String? currentRole) {
    if (currentRole == "fabricant") {
      return [
        {"value": "distributeur", "label": "Distributeur"},
        {"value": "gerant", "label": "Gérant"},
      ];
    } else if (currentRole == "distributeur") {
      return [
        {"value": "gerant", "label": "Gérant"},
      ];
    }
    return [];
  }

  String getRoleLabel(String? role) {
    switch (role) {
      case 'fabricant':
        return 'Fabricant';
      case 'distributeur':
        return 'Distributeur';
      case 'gerant':
        return 'Gérant';
      case 'admin':
        return 'Admin';
      default:
        return role ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {

    // Affiche un loader tant que le rôle n'est pas chargé
    if (_currentRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Row(
        children: [
          ResponsiveSidebar(
            selectedIndex: selectedSidebarIndex,
            onItemSelected: (i) {
              setState(() => selectedSidebarIndex = i);
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
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + bouton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Gestion des Utilisateurs",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A6FC9),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A6FC9),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.person_add),
                            label: const Text("Ajouter un utilisateur"),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Ajouter un utilisateur"),
                                  content: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 240,
                                          child: TextFormField(
                                            controller: _nameController,
                                            decoration: InputDecoration(
                                              labelText: "Nom d'utilisateur",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                    ? "Champ requis"
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: 240,
                                          child: TextFormField(
                                            controller: _emailController,
                                            decoration: InputDecoration(
                                              labelText: "Email",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            validator: (v) =>
                                                v != null && v.contains('@')
                                                    ? null
                                                    : "Email invalide",
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: 240,
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              labelText: "Mot de passe",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            validator: (v) =>
                                                v == null || v.length < 6
                                                    ? "6 caractères minimum"
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: 200,
                                          child:
                                              DropdownButtonFormField<String>(
                                            value: _selectedRole,
                                            decoration: InputDecoration(
                                              labelText: "Rôle",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            items: _roles
                                                .map((role) =>
                                                    DropdownMenuItem<String>(
                                                      value: role['value'],
                                                      child: Text(
                                                          role['label'] ?? ''),
                                                    ))
                                                .toList(),
                                            onChanged: (v) => setState(
                                                () => _selectedRole = v),
                                            validator: (v) => v == null
                                                ? "Champ requis"
                                                : null,
                                          ),
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
                                      onPressed: _isLoading
                                          ? null
                                          : () async {
                                              await _addUser();
                                              Navigator.pop(ctx);
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1A6FC9),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white))
                                          : const Text("Créer utilisateur"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1A6FC9),
                              side: const BorderSide(color: Color(0xFF1A6FC9)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.account_circle),
                            label: const Text("Modifier son profil"),
                            onPressed: () {
                              // Ouvre le formulaire de modification du profil
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Modifier son profil"),
                                  content: Form(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 240,
                                          child: TextFormField(
                                            controller: _phoneController,
                                            decoration: InputDecoration(
                                              labelText: "Téléphone",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: 240,
                                          child: TextFormField(
                                            controller: _countryController,
                                            decoration: InputDecoration(
                                              labelText: "Pays",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: 240,
                                          child: TextFormField(
                                            controller: _cityController,
                                            decoration: InputDecoration(
                                              labelText: "Ville",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: 240,
                                          child: TextFormField(
                                            controller: _addressController,
                                            decoration: InputDecoration(
                                              labelText: "Adresse",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
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
                                        await completeProfile();
                                        Navigator.pop(ctx);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1A6FC9),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("Enregistrer"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Formulaire d'ajout stylisé
                  if (getRolesForCurrentUser(_currentRole).isNotEmpty)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              SizedBox(
                                width: 240,
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: "Nom d'utilisateur",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? "Champ requis"
                                      : null,
                                ),
                              ),
                              SizedBox(
                                width: 240,
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  validator: (v) => v != null && v.contains('@')
                                      ? null
                                      : "Email invalide",
                                ),
                              ),
                              SizedBox(
                                width: 240,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Mot de passe",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  validator: (v) => v == null || v.length < 6
                                      ? "6 caractères minimum"
                                      : null,
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  decoration: InputDecoration(
                                    labelText: "Rôle",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: getRolesForCurrentUser(_currentRole)
                                      .map((role) => DropdownMenuItem<String>(
                                            value: role['value'],
                                            child: Text(role['label'] ?? ''),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedRole = v),
                                  validator: (v) =>
                                      v == null ? "Champ requis" : null,
                                ),
                              ),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _addUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A6FC9),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.person_add),
                                  label: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Text("Créer utilisateur"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Recherche
                  Row(
                    children: [
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF1A6FC9)),
                            hintText: "Rechercher un utilisateur...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon:
                            const Icon(Icons.refresh, color: Color(0xFF1A6FC9)),
                        onPressed: _loadUsers,
                        tooltip: "Rafraîchir",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tableau stylisé et long
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 600),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _filteredUsers.isEmpty
                                ? const Center(
                                    child: Text("Aucun utilisateur trouvé"))
                                : DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                        const Color(0xFF1A6FC9)),
                                    headingTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    columns: const [
                                      DataColumn(label: Text("Nom")),
                                      DataColumn(label: Text("Email")),
                                      DataColumn(label: Text("Rôle")),
                                      DataColumn(label: Text("Actions")),
                                    ],
                                    rows: List<DataRow>.generate(
                                      _filteredUsers.length,
                                      (index) {
                                        final user = _filteredUsers[index];
                                        final isEven = index % 2 == 0;
                                        return DataRow(
                                          color: WidgetStateProperty.all(isEven
                                              ? Colors.white
                                              : const Color(0xFFE3F0FB)),
                                          cells: [
                                            DataCell(Text(
                                                user['username'] ?? '',
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16))),
                                            DataCell(Text(user['email'] ?? '',
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16))),
                                            DataCell(Text(
                                                getRoleLabel(user['role']),
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16))),
                                            DataCell(Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.remove_red_eye,
                                                      color: Color(0xFF1A6FC9)),
                                                  tooltip: "Visualiser",
                                                  onPressed: () =>
                                                      _viewUser(user),
                                                ),
                                                if (_currentRole !=
                                                    "gerant") ...[
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.orange),
                                                    tooltip: "Modifier",
                                                    onPressed: () =>
                                                        _editUser(user),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    tooltip: "Supprimer",
                                                    onPressed: () =>
                                                        _deleteUser(user['id']),
                                                  ),
                                                ]
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
