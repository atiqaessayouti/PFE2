import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../EditUserPage.dart';
import 'UserDetailsPage.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _currentUserRole;
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadCurrentUserRole();
    _searchController.addListener(_updateSearchText);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _updateSearchText() {
    if (mounted) {
      setState(() => _searchText = _searchController.text.trim().toLowerCase());
    }
  }

  Future<void> _loadCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (mounted) {
          setState(() => _currentUserRole = userDoc.data()?['role']?.toString());
        }
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedFilter == label,
        onSelected: (selected) {
          setState(() => _selectedFilter = selected ? label : 'Tous');
        },
        selectedColor: Colors.redAccent,
        labelStyle: TextStyle(
          color: _selectedFilter == label ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildUserStats(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, String userId) {
    final isGaragiste = userData['role'] == 'Garagiste';
    final fullName = '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}'.trim();
    final email = userData['email'] ?? '';
    final phone = userData['telephone'] ?? 'Non renseigné';
    final role = userData['role'] ?? 'Client';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  child: Icon(
                    isGaragiste ? Icons.build : Icons.person,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentUserRole == 'Admin') ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.grey,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditUserPage(
                          userId: userId,
                          userData: userData,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tél: $phone',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (role == 'Garagiste'
                        ? Colors.blue.shade50
                        : Colors.green.shade50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: (role == 'Garagiste'
                          ? Colors.blue
                          : Colors.green),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserStats(
                  isGaragiste ? 'Entretiens' : 'Véhicules',
                  isGaragiste ? '42' : '2',
                ),
                _buildUserStats('Statut', 'Actif'),
                TextButton(
                  onPressed: () => _showUserDetails(userId, userData),
                  child: const Text(
                    'Détails',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${userData['prenom'] ?? 'l\'utilisateur'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nom complet', '${userData['prenom']} ${userData['nom']}'),
              _buildDetailRow('Email', userData['email']),
              _buildDetailRow('Téléphone', userData['telephone'] ?? 'Non renseigné'),
              _buildDetailRow('Rôle', userData['role']),
              _buildDetailRow('Date création',
                  userData['createdAt']?.toDate().toString() ?? 'Inconnue'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailsPage(userData: userData),
                ),
              );
            },

            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'Client';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ajouter un utilisateur'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Minimum 6 caractères'
                          : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                      keyboardType: TextInputType.phone,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: ['Client', 'Garagiste', 'Admin']
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedRole = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Rôle'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    await _createUser(
                      email: emailController.text,
                      password: passwordController.text,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      phone: phoneController.text,
                      role: selectedRole,
                    );
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Créer', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user?.uid).set({
        'email': email,
        'prenom': firstName,
        'nom': lastName,
        'telephone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisateur $email créé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tous'),
                      _buildFilterChip('Garagistes'),
                      _buildFilterChip('Clients'),
                      if (_currentUserRole == 'Admin') _buildFilterChip('Admins'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun utilisateur trouvé'));
                }

                final filteredUsers = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesSearch = [
                    data['nom']?.toString().toLowerCase() ?? '',
                    data['prenom']?.toString().toLowerCase() ?? '',
                    data['email']?.toString().toLowerCase() ?? '',
                  ].any((field) => field.contains(_searchText));

                  final matchesFilter = _selectedFilter == 'Tous' ||
                      (_selectedFilter == 'Garagistes' && data['role'] == 'Garagiste') ||
                      (_selectedFilter == 'Clients' && data['role'] == 'Client') ||
                      (_selectedFilter == 'Admins' && data['role'] == 'Admin');

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('Aucun utilisateur correspondant'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(
                      user.data() as Map<String, dynamic>,
                      user.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),




    );
  }
}