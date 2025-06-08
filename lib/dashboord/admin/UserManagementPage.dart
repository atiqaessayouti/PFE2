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

class _UserManagementPageState extends State<UserManagementPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _currentUserRole;
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Couleurs du thème sombre dégradé
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryOrange = Color(0xFFFB8C00);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadCurrentUserRole();
    _searchController.addListener(_updateSearchText);
    if (mounted) {
      setState(() => _isLoading = false);
      _animationController.forward();
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
    final isSelected = _selectedFilter == label;
    Color chipColor;

    if (label == 'Garagistes') {
      chipColor = primaryBlue;
    } else if (label == 'Clients') {
      chipColor = primaryGreen;
    } else if (label == 'Admins') {
      chipColor = primaryRed;
    } else {
      chipColor = primaryOrange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : textLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedFilter = selected ? label : 'Tous');
          },
          backgroundColor: cardDark,
          selectedColor: chipColor,
          elevation: isSelected ? 4 : 0,
          shadowColor: chipColor.withOpacity(0.3),
          side: BorderSide(
            color: isSelected ? chipColor : Colors.grey.shade700,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats(String title, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? primaryOrange,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, String userId) {
    final isGaragiste = userData['role'] == 'Garagiste';
    final isAdmin = userData['role'] == 'Admin';
    final fullName = '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}'.trim();
    final email = userData['email'] ?? '';
    final phone = userData['telephone'] ?? 'Non renseigné';
    final role = userData['role'] ?? 'Client';

    Color roleColor = primaryGreen;
    Color roleBackgroundColor = primaryGreen.withOpacity(0.1);
    IconData roleIcon = Icons.person;

    if (isGaragiste) {
      roleColor = primaryBlue;
      roleBackgroundColor = primaryBlue.withOpacity(0.1);
      roleIcon = Icons.build_circle;
    } else if (isAdmin) {
      roleColor = primaryRed;
      roleBackgroundColor = primaryRed.withOpacity(0.1);
      roleIcon = Icons.admin_panel_settings;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Card(
        elevation: 0,
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: roleBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: roleColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      roleIcon,
                      color: roleColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentUserRole == 'Admin') ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit_outlined, size: 20, color: primaryOrange),
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
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        phone,
                        style: TextStyle(
                          color: textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: roleBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: roleColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.grey.shade800,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildUserStats(
                    isGaragiste ? 'Entretiens' : 'Véhicules',
                    isGaragiste ? '42' : '2',
                    color: roleColor,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.grey.shade800,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  _buildUserStats('Statut', 'Actif', color: primaryGreen),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryOrange],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => _showUserDetails(userId, userData),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Détails',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetails(String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: darkBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cardDark,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Détails de ${userData['prenom'] ?? 'l\'utilisateur'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                child: Column(
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Fermer',
                      style: TextStyle(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailsPage(userData: userData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Voir Plus', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textSecondary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textLight,
            ),
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
          return Dialog(
            backgroundColor: darkBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cardDark,
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_add_outlined,
                              color: primaryGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Ajouter un utilisateur',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildFormField(
                        controller: firstNameController,
                        label: 'Prénom',
                        icon: Icons.person_outline,
                        validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                      ),
                      _buildFormField(
                        controller: lastNameController,
                        label: 'Nom',
                        icon: Icons.person_outline,
                        validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                      ),
                      _buildFormField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
                      ),
                      _buildFormField(
                        controller: passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => (value?.length ?? 0) < 6 ? 'Minimum 6 caractères' : null,
                      ),
                      _buildFormField(
                        controller: phoneController,
                        label: 'Téléphone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade800),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedRole,
                          items: ['Client', 'Garagiste', 'Admin']
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(color: textLight),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedRole = value);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Rôle',
                            labelStyle: TextStyle(color: textSecondary),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: textSecondary),
                          ),
                          dropdownColor: cardDark,
                          style: TextStyle(color: textLight),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                            child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(color: textLight),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textSecondary),
          prefixIcon: Icon(icon, color: textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryOrange, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade900,
        ),
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
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Utilisateur $email créé avec succès'),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erreur: ${e.message}')),
            ],
          ),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erreur: ${e.toString()}')),
            ],
          ),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                darkBackground,
                Colors.black,
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text(
          'Gestion des Utilisateurs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textLight,
          ),
        ),
        backgroundColor: cardDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryRed.withOpacity(0.2), primaryBlue.withOpacity(0.2)],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: textLight),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un utilisateur...',
                          hintStyle: TextStyle(color: textSecondary),
                          prefixIcon: Icon(Icons.search, color: textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun utilisateur trouvé',
                            style: TextStyle(
                              fontSize: 18,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun utilisateur correspondant',
                            style: TextStyle(
                              fontSize: 18,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Essayez de modifier vos critères de recherche',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200 + (index * 50)),
                        curve: Curves.easeOut,
                        child: _buildUserCard(
                          user.data() as Map<String, dynamic>,
                          user.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentUserRole == 'Admin'
          ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [primaryOrange, primaryRed],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddUserDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Nouvel utilisateur',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
          : null,
    );
  }
}