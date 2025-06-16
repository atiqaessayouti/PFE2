import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _userRole;
  List<Map<String, dynamic>> _vehiculesClient = [];
  Map<String, dynamic>? _vehiculeSelectionne;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

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
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
    _loadUserRoleEtVehicules();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
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

  Future<void> _loadUserRoleEtVehicules() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _userRole = userDoc.data()?['role'];

      final vehiculesSnapshot = await FirebaseFirestore.instance
          .collection('vehicules')
          .where('userId', isEqualTo: user.uid)
          .get();

      _vehiculesClient = vehiculesSnapshot.docs.map((doc) => doc.data()).toList();

      if (_vehiculesClient.isNotEmpty) {
        _vehiculeSelectionne = _vehiculesClient.first;
      }

      setState(() {});
    }
  }

  void _changerVehicule(Map<String, dynamic> vehicule) {
    setState(() {
      _vehiculeSelectionne = vehicule;
    });
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
      padding: padding ?? const EdgeInsets.all(24),
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

  void _showCommandeDialog(BuildContext context, String pieceId, String nom, String ref, int stockDispo) {
    final TextEditingController _qteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: _buildGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryTeal, primaryEmerald],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryTeal.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nouvelle Commande',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            nom,
                            style: const TextStyle(
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

                // Champ de quantité
                Container(
                  decoration: BoxDecoration(
                    color: darkBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _qteController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Quantité',
                      labelStyle: const TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: const Icon(Icons.confirmation_number, color: primaryTeal),
                      helperText: _userRole == 'Client'
                          ? 'Maximum 5 unités par commande'
                          : 'Stock disponible: $stockDispo unités',
                      helperStyle: const TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: textMuted,
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
                          onTap: () async {
                            final int quantite = int.tryParse(_qteController.text) ?? 0;

                            // Validations
                            if (quantite <= 0) {
                              Navigator.pop(ctx);
                              _showSnackBar('Veuillez entrer une quantité valide.', primaryAmber);
                              return;
                            }

                            if (quantite > stockDispo) {
                              Navigator.pop(ctx);
                              _showSnackBar('Stock insuffisant. Disponible: $stockDispo unités', primaryAmber);
                              return;
                            }

                            if (_userRole == 'Client' && quantite > 5) {
                              Navigator.pop(ctx);
                              _showSnackBar('Un client ne peut commander que 5 unités maximum.', primaryRose);
                              return;
                            }

                            // Traitement de la commande
                            try {
                              await FirebaseFirestore.instance.collection('commandesPieces').add({
                                'pieceId': pieceId,
                                'nomPiece': nom,
                                'refPiece': ref,
                                'quantite': quantite,
                                'dateCommande': Timestamp.now(),
                                'etat': 'En attente',
                                'creePar': FirebaseAuth.instance.currentUser?.uid ?? 'anonyme',
                                'userRole': _userRole ?? 'inconnu',
                              });

                              await FirebaseFirestore.instance.collection('piecesStock').doc(pieceId).update({
                                'stok': FieldValue.increment(-quantite),
                              });

                              Navigator.pop(ctx);
                              _showSnackBar('Commande de $quantite unité(s) envoyée avec succès', primaryEmerald);
                            } catch (e) {
                              Navigator.pop(ctx);
                              _showSnackBar('Erreur lors de la commande', primaryRose);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            child: Text(
                              'Commander',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == primaryEmerald ? Icons.check_circle : Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == 'Admin';
    final isClient = _userRole == 'Client';

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
            // AppBar personnalisée
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
                      colors: [
                        primaryBlue.withOpacity(0.2),
                        primaryIndigo.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                title: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory, color: textPrimary, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Gestion du Stock',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
              ),
            ),

            // Contenu principal
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      // Section véhicule et recherche
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: _buildGlassCard(
                          child: Column(
                            children: [
                              // Sélecteur de véhicule pour clients
                              if (_userRole == 'Client' && _vehiculesClient.isNotEmpty) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: darkBackground.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderColor.withOpacity(0.3)),
                                  ),
                                  child: DropdownButtonFormField<Map<String, dynamic>>(
                                    decoration: const InputDecoration(
                                      labelText: 'Sélectionner un véhicule',
                                      labelStyle: TextStyle(color: textSecondary),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      prefixIcon: Icon(Icons.directions_car, color: primaryTeal),
                                    ),
                                    value: _vehiculeSelectionne,
                                    dropdownColor: cardDark,
                                    items: _vehiculesClient.map((vehicule) {
                                      String label = '${vehicule['marque']} ${vehicule['modele']} (${vehicule['annee'] ?? ''})';
                                      return DropdownMenuItem<Map<String, dynamic>>(
                                        value: vehicule,
                                        child: Text(label, style: const TextStyle(color: textPrimary)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        _changerVehicule(value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Barre de recherche
                              Container(
                                decoration: BoxDecoration(
                                  color: darkBackground.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor.withOpacity(0.3)),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(color: textPrimary, fontSize: 16),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.search, color: primaryBlue),
                                    hintText: 'Rechercher une pièce...',
                                    hintStyle: TextStyle(color: textMuted),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Liste des pièces
                      _buildPiecesList(isAdmin, isClient),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildPiecesList(bool isAdmin, bool isClient) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('piecesStock').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryBlue,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des pièces...',
                    style: TextStyle(color: textSecondary, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        final allPieces = snapshot.data!.docs;
        final filteredPieces = allPieces.where((piece) {
          final data = piece.data() as Map<String, dynamic>;
          final nom = (data['nom'] ?? '').toString().toLowerCase();
          final ref = (data['ref'] ?? '').toString().toLowerCase();
          final marque = data['marque'] ?? '';
          final modele = data['modele'] ?? '';
          final annee = data['annee'] ?? '';

          final matchesSearch = nom.contains(_searchText) || ref.contains(_searchText);

          if (isClient) {
            if (_vehiculeSelectionne == null) return false;
            return matchesSearch &&
                marque == _vehiculeSelectionne!['marque'] &&
                modele == _vehiculeSelectionne!['modele'] &&
                annee.toString() == _vehiculeSelectionne!['annee'].toString();
          }

          return matchesSearch;
        }).toList();

        if (filteredPieces.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: filteredPieces.length,
          itemBuilder: (context, index) {
            final piece = filteredPieces[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              child: _buildPieceCard(piece, isAdmin),
            );
          },
        );
      },
    );
  }

  Widget _buildPieceCard(QueryDocumentSnapshot piece, bool isAdmin) {
    final data = piece.data() as Map<String, dynamic>;
    final nom = data['nom'] ?? 'Nom inconnu';
    final ref = data['ref'] ?? 'N/A';
    final prixClient = (data['prixClient'] ?? 0).toDouble();
    final prixGaragiste = (data['prixGaragiste'] ?? 0).toDouble();
    final stock = (data['stok'] ?? 0).toInt();
    final imageUrl = data['imageUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: _buildGlassCard(
        child: Row(
          children: [
            // Image de la pièce
            Hero(
              tag: 'piece_${piece.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/100',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: darkBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          color: primaryBlue,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Informations de la pièce
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue.withOpacity(0.2), primaryIndigo.withOpacity(0.2)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Réf: $ref',
                      style: const TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (isAdmin) ...[
                    _buildInfoRow(Icons.person, 'Prix Client', '${prixClient.toStringAsFixed(2)} DH', primaryTeal),
                    _buildInfoRow(Icons.build, 'Prix Garagiste', '${prixGaragiste.toStringAsFixed(2)} DH', primaryPurple),
                    _buildInfoRow(Icons.inventory_2, 'Stock', '$stock unités',
                        stock > 0 ? primaryEmerald : primaryRose),
                  ] else ...[
                    _buildInfoRow(Icons.euro, 'Prix', '${prixClient.toStringAsFixed(2)} DH', primaryTeal),
                  ],

                  const SizedBox(height: 16),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isAdmin)
                        _buildGradientContainer(
                          colors: const [primaryPurple, primaryIndigo],
                          borderRadius: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/editPiece', arguments: piece.id);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Modifier',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!isAdmin)
                        _buildGradientContainer(
                          colors: stock > 0
                              ? const [primaryTeal, primaryEmerald]
                              : const [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                          borderRadius: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: stock > 0 ? () {
                                _showCommandeDialog(context, piece.id, nom, ref, stock);
                              } : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      stock > 0 ? Icons.shopping_cart : Icons.remove_shopping_cart,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      stock > 0 ? 'Commander' : 'Rupture',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue.withOpacity(0.2), primaryIndigo.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.search_off,
                size: 64,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune pièce trouvée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez de modifier vos critères de recherche',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return _buildGradientContainer(
      colors: const [primaryTeal, primaryEmerald],
      borderRadius: 16,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          Navigator.pushNamed(context, '/addPiece');
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}