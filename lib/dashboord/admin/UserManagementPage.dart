import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Palette de couleurs professionnelle sombre sans orange
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color cardDark = Color(0xFF252B3B);
  static const Color borderColor = Color(0xFF374151);

  // Couleurs d'accent professionnelles
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color primaryRose = Color(0xFFEC4899);
  static const Color primaryAmber = Color(0xFFF59E0B);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _ensureCurrentUserDocument();
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

  Future<void> _ensureCurrentUserDocument() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          print('Creating user document for: ${user.email}');

          // Créer le document utilisateur avec le rôle Admin par défaut
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'prenom': 'Admin',
            'nom': 'System',
            'role': 'Admin',
            'telephone': '',
            'createdAt': FieldValue.serverTimestamp(),
          });

          print('User document created successfully');
        }
      }
    } catch (e) {
      print('Error ensuring user document: $e');
    }
  }

  Future<void> _loadCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && mounted) {
          final userData = userDoc.data();
          setState(() => _currentUserRole = userData?['role']?.toString());
          print('Current user role loaded: $_currentUserRole');
        }
      }
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  Widget _buildGradientContainer({
    required Widget child,
    List<Color>? colors,
    double borderRadius = 16,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [primaryBlue, primaryIndigo],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (colors?.first ?? primaryBlue).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsets? padding,
    double borderRadius = 20,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    Color chipColor;

    switch (label) {
      case 'Garagistes':
        chipColor = primaryBlue;
        break;
      case 'Clients':
        chipColor = primaryEmerald;
        break;
      case 'Admins':
        chipColor = primaryRose;
        break;
      default:
        chipColor = primaryTeal;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedFilter = selected ? label : 'Tous');
          },
          backgroundColor: surfaceDark,
          selectedColor: chipColor,
          elevation: isSelected ? 4 : 0,
          shadowColor: chipColor.withOpacity(0.3),
          side: BorderSide(
            color: isSelected ? chipColor : borderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, String userId) {
    final isGaragiste = userData['role'] == 'Garagiste';
    final isAdmin = userData['role'] == 'Admin';
    final fullName = '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}'.trim();
    final email = userData['email'] ?? '';
    final phone = userData['telephone'] ?? 'Non renseigné';
    final role = userData['role'] ?? 'Client';

    Color roleColor = primaryEmerald;
    IconData roleIcon = Icons.person;

    if (isGaragiste) {
      roleColor = primaryBlue;
      roleIcon = Icons.build_circle;
    } else if (isAdmin) {
      roleColor = primaryRose;
      roleIcon = Icons.admin_panel_settings;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [roleColor.withOpacity(0.2), roleColor.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: roleColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    roleIcon,
                    color: roleColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Utilisateur' : fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentUserRole == 'Admin') ...[
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: darkBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20, color: primaryTeal),
                      onPressed: () {
                        print('Edit user: $userId');
                      },
                      tooltip: 'Modifier',
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: darkBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryRose.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: primaryRose),
                      onPressed: () => _showDeleteConfirmation(userId, fullName.isEmpty ? email : fullName),
                      tooltip: 'Supprimer',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.phone_outlined, size: 18, color: primaryTeal),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Téléphone',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [roleColor.withOpacity(0.2), roleColor.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: roleColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryRose, Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Confirmer la suppression',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Êtes-vous sûr de vouloir supprimer l\'utilisateur "$userName" ?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGradientContainer(
                        colors: const [primaryRose, Color(0xFFDC2626)],
                        borderRadius: 12,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              await _deleteUser(userId, userName);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Supprimer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Future<void> _deleteUser(String userId, String userName) async {
    try {
      await _firestore.collection('users').doc(userId).delete();

      if (mounted) {
        _showSnackBar(
          'Utilisateur "$userName" supprimé avec succès',
          primaryEmerald,
          Icons.check_circle,
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Erreur lors de la suppression: ${e.toString()}',
          primaryRose,
          Icons.error_outline,
        );
      }
    }
  }

  void _showAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'Client';
    bool isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildGlassCard(
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryTeal, primaryEmerald],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person_add_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nouvel Utilisateur',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Créer un nouveau compte',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
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
                            color: darkBackground.withOpacity(0.5),
                            border: Border.all(color: borderColor.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedRole,
                            items: ['Client', 'Garagiste', 'Admin']
                                .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role,
                                style: const TextStyle(color: textPrimary),
                              ),
                            ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() => selectedRole = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Rôle',
                              labelStyle: TextStyle(color: textSecondary),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: textSecondary),
                            ),
                            dropdownColor: cardDark,
                            style: const TextStyle(color: textPrimary),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isCreating ? null : () => Navigator.pop(context),
                              child: Text(
                                'Annuler',
                                style: TextStyle(
                                  color: isCreating ? textMuted.withOpacity(0.5) : textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildGradientContainer(
                              colors: const [primaryTeal, primaryEmerald],
                              borderRadius: 12,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isCreating ? null : () async {
                                    if (formKey.currentState?.validate() ?? false) {
                                      setDialogState(() => isCreating = true);

                                      final success = await _createUser(
                                        email: emailController.text,
                                        password: passwordController.text,
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        phone: phoneController.text,
                                        role: selectedRole,
                                      );

                                      if (mounted) {
                                        Navigator.pop(context);
                                        if (success) {
                                          setState(() {});
                                        }
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    child: isCreating
                                        ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Création...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                        : const Text(
                                      'Créer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
        style: const TextStyle(color: textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: textSecondary),
          prefixIcon: Icon(icon, color: textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryTeal, width: 2),
          ),
          filled: true,
          fillColor: darkBackground.withOpacity(0.5),
        ),
      ),
    );
  }

  Future<bool> _createUser({
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
        'telephone': phone ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar(
        'Utilisateur $email créé avec succès',
        primaryEmerald,
        Icons.check_circle,
      );
      return true;
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}', primaryRose, Icons.error_outline);
      return false;
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: darkBackground,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryTeal, strokeWidth: 3),
              SizedBox(height: 16),
              Text('Chargement...', style: TextStyle(color: textSecondary, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkBackground, Color(0xFF0F172A)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryBlue.withOpacity(0.2), primaryIndigo.withOpacity(0.2)],
                    ),
                  ),
                ),
                title: const Text(
                  'Gestion des Utilisateurs',
                  style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 20),
                ),
                centerTitle: true,
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: surfaceDark.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: textPrimary),
                    onPressed: () => setState(() {}),
                    tooltip: 'Actualiser',
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildGlassCard(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: darkBackground.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Rechercher un utilisateur...',
                              hintStyle: TextStyle(color: textMuted),
                              prefixIcon: Icon(Icons.search, color: textMuted),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
              ),
            ),

            SliverToBoxAdapter(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: primaryTeal, strokeWidth: 3),
                            SizedBox(height: 16),
                            Text('Chargement des utilisateurs...', style: TextStyle(color: textSecondary, fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: primaryRose),
                            const SizedBox(height: 16),
                            const Text('Erreur de chargement', style: TextStyle(fontSize: 20, color: textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('${snapshot.error}', style: const TextStyle(fontSize: 14, color: textSecondary), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [primaryBlue.withOpacity(0.2), primaryIndigo.withOpacity(0.2)]),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: borderColor.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.people_outline, size: 64, color: primaryBlue),
                            ),
                            const SizedBox(height: 24),
                            const Text('Aucun utilisateur trouvé', style: TextStyle(fontSize: 24, color: textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Commencez par créer votre premier utilisateur', style: TextStyle(fontSize: 16, color: textSecondary)),
                          ],
                        ),
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
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [primaryAmber.withOpacity(0.2), primaryRose.withOpacity(0.2)]),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: borderColor.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.search_off, size: 64, color: primaryAmber),
                            ),
                            const SizedBox(height: 24),
                            const Text('Aucun utilisateur correspondant', style: TextStyle(fontSize: 20, color: textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Essayez de modifier vos critères de recherche', style: TextStyle(fontSize: 14, color: textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        child: _buildUserCard(user.data() as Map<String, dynamic>, user.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildGradientContainer(
        colors: const [primaryTeal, primaryEmerald],
        borderRadius: 16,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddUserDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nouvel utilisateur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}