import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _users = [];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedRole;

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

  void _addUser() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _users.add({
          'Nom': _nameController.text,
          'Téléphone': _phoneController.text,
          'Email': _emailController.text,
          'Pays': _countryController.text,
          'Ville': _cityController.text,
          'Adresse': _addressController.text,
          'Rôle': _selectedRole ?? '',
        });
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _countryController.clear();
        _cityController.clear();
        _addressController.clear();
        _selectedRole = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      drawer: isMobile ? const Drawer(child: NavigationSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) const NavigationSidebar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8.0 : 24.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 3,
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ajouter un utilisateur",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 18),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 600;
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    SizedBox(
                                      width: isWide ? 260 : double.infinity,
                                      child: TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          labelText: "Nom",
                                          prefixIcon: Icon(Icons.person),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? "Champ requis"
                                            : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: isWide ? 260 : double.infinity,
                                      child: TextFormField(
                                        controller: _phoneController,
                                        decoration: const InputDecoration(
                                          labelText: "Téléphone",
                                          prefixIcon: Icon(Icons.phone),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? "Champ requis"
                                            : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: isWide ? 260 : double.infinity,
                                      child: TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: "Email",
                                          prefixIcon: Icon(Icons.email),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? "Champ requis"
                                            : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: isWide ? 260 : double.infinity,
                                      child: TextFormField(
                                        controller: _countryController,
                                        decoration: const InputDecoration(
                                          labelText: "Pays",
                                          prefixIcon: Icon(Icons.public),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? "Champ requis"
                                            : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: isWide ? 260 : double.infinity,
                                      child: TextFormField(
                                        controller: _cityController,
                                        decoration: const InputDecoration(
                                          labelText: "Ville",
                                          prefixIcon: Icon(Icons.location_city),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? "Champ requis"
                                            : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: isWide ? 260 : double.infinity,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedRole,
                                        decoration: const InputDecoration(
                                          labelText: "Rôle",
                                          prefixIcon: Icon(Icons.badge),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                              value: "Fournisseur",
                                              child: Text("Fournisseur")),
                                          DropdownMenuItem(
                                              value: "Distributeur",
                                              child: Text("Distributeur")),
                                          DropdownMenuItem(
                                              value: "Gerant",
                                              child: Text("Gerant")),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedRole = value;
                                          });
                                        },
                                        validator: (value) => value == null ||
                                                value.isEmpty
                                            ? "Champ requis"
                                            : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: isWide ? 540 : double.infinity,
                                      child: TextFormField(
                                        controller: _addressController,
                                        decoration: const InputDecoration(
                                          labelText: "Adresse",
                                          prefixIcon: Icon(Icons.home),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        validator: (v) => v == null || v.isEmpty
                                            ? "Champ requis"
                                            : null,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text("Ajouter"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 28),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _addUser,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Liste des utilisateurs",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Nom")),
                        DataColumn(label: Text("Téléphone")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Pays")),
                        DataColumn(label: Text("Ville")),
                        DataColumn(label: Text("Adresse")),
                        DataColumn(label: Text("Rôle")), // Ajouté
                      ],
                      rows: _users
                          .map(
                            (user) => DataRow(
                              cells: [
                                DataCell(Text(user['Nom']!)),
                                DataCell(Text(user['Téléphone']!)),
                                DataCell(Text(user['Email']!)),
                                DataCell(Text(user['Pays']!)),
                                DataCell(Text(user['Ville']!)),
                                DataCell(Text(user['Adresse']!)),
                                DataCell(Text(user['Rôle'] ?? '')), // Ajouté
                              ],
                            ),
                          )
                          .toList(),
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

// Sidebar complète avec navigation
class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(Icons.space_dashboard_outlined, "Dashboard", () {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }),
      _NavItem(Icons.qr_code_2_rounded, "Scan", () {
        Navigator.of(context).pushReplacementNamed('/scan');
      }),
      _NavItem(Icons.account_circle_outlined, "Utilisateur", () {
        // Déjà sur la page utilisateur
      }),
      _NavItem(Icons.inventory_2_outlined, "Produits", () {
        Navigator.of(context).pushReplacementNamed('/product');
      }),
      _NavItem(Icons.notifications_active_outlined, "Alertes", () {
        Navigator.of(context).pushReplacementNamed('/alerts');
      }),
      _NavItem(Icons.settings, "Paramètres", () {
        Navigator.of(context).pushReplacementNamed('/settings');
      }),
    ];

    return Container(
      width: 220,
      color: const Color(0xFF1976D2),
      child: Column(
        children: [
          const SizedBox(height: 32),
          ...navItems.map((item) => ListTile(
                leading: Icon(item.icon, color: Colors.white),
                title: Text(item.label,
                    style: const TextStyle(color: Colors.white)),
                onTap: item.onTap,
              )),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.icon, this.label, this.onTap);
}