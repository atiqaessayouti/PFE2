import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoriqueCommandesAdminPage extends StatefulWidget {
  const HistoriqueCommandesAdminPage({Key? key}) : super(key: key);

  @override
  State<HistoriqueCommandesAdminPage> createState() => _HistoriqueCommandesAdminPageState();
}

class _HistoriqueCommandesAdminPageState extends State<HistoriqueCommandesAdminPage>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> _userInfoCache = {};
  String _filtreEtat = 'Tous';
  String _searchQuery = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Palette de couleurs sombre professionnelle
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color cardDark = Color(0xFF252B3B);
  static const Color borderColor = Color(0xFF374151);

  // Couleurs d'accent
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color primaryAmber = Color(0xFFF59E0B);
  static const Color primaryRose = Color(0xFFEC4899);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
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
            _buildSliverAppBar(),
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
                      _buildSearchAndFilters(),
                      const SizedBox(height: 24),
                      _buildCommandesList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140, // Réduit de 160 à 140
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
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Ajuste le contenu en fonction de l'espace disponible
            final isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;

            if (isCollapsed) {
              return const Text(
                'Historique des Commandes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  fontSize: 18,
                ),
              );
            }

            return const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Historique des Commandes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    fontSize: 22, // Réduit de 28 à 22
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4), // Réduit de 8 à 4
                Text(
                  'Suivez et gérez toutes les commandes',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14, // Réduit de 16 à 14
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16), // Ajusté le padding
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
            icon: const Icon(Icons.refresh_rounded, color: textPrimary),
            onPressed: () => setState(() {}),
            tooltip: 'Actualiser',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildGlassCard(
        child: Column(
          children: [
            // Barre de recherche
            Container(
              decoration: BoxDecoration(
                color: darkBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor.withOpacity(0.3)),
              ),
              child: TextField(
                style: const TextStyle(color: textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom ou référence...',
                  hintStyle: TextStyle(color: textMuted),
                  prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),

            const SizedBox(height: 20),

            // Filtres horizontaux
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('Tous', Icons.all_inclusive_rounded, primaryAmber),
                  const SizedBox(width: 12),
                  _buildFilterChip('En attente', Icons.schedule_rounded, primaryAmber),
                  const SizedBox(width: 12),
                  _buildFilterChip('Traité', Icons.check_circle_rounded, primaryEmerald),
                  const SizedBox(width: 12),
                  _buildFilterChip('Envoyé', Icons.local_shipping_rounded, primaryBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color) {
    final isSelected = _filtreEtat == label;

    return GestureDetector(
      onTap: () => setState(() => _filtreEtat = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isSelected ? null : surfaceDark.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color : borderColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('commandesPieces')
          .orderBy('dateCommande', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                    'Chargement des commandes...',
                    style: TextStyle(color: textSecondary, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final commandes = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final etat = (data['etat'] ?? '').toString().toLowerCase();
          final nom = (data['nomPiece'] ?? '').toString().toLowerCase();
          final ref = (data['refPiece'] ?? '').toString().toLowerCase();

          final filtreEtatOK = _filtreEtat == 'Tous' || etat == _filtreEtat.toLowerCase();
          final filtreTexteOK = _searchQuery.isEmpty ||
              nom.contains(_searchQuery) ||
              ref.contains(_searchQuery);

          return filtreEtatOK && filtreTexteOK;
        }).toList();

        if (commandes.isEmpty) {
          return _buildEmptyFilterState();
        }

        return ListView.separated(
          shrinkWrap: true, // Important: permet au ListView de s'adapter à son contenu
          physics: const NeverScrollableScrollPhysics(), // Désactive le scroll du ListView
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: commandes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutCubic,
            child: _buildCommandeCard(commandes[index]),
          ),
        );
      },
    );
  }

  Widget _buildCommandeCard(QueryDocumentSnapshot commande) {
    final data = commande.data() as Map<String, dynamic>;
    final uid = data['creePar'] ?? '';
    final dateCommande = (data['dateCommande'] as Timestamp).toDate();
    final dateTraitement = data['dateTraitement'] != null
        ? (data['dateTraitement'] as Timestamp).toDate()
        : null;
    final etat = data['etat'] ?? '';

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryBlue, primaryIndigo],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nomPiece'] ?? 'Pièce sans nom',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Réf: ${data['refPiece'] ?? 'N/A'}",
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(etat),
            ],
          ),

          const SizedBox(height: 20),

          // Informations détaillées
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.inventory_2_rounded,
                  "Quantité",
                  "${data['quantite'] ?? 1}",
                  primaryTeal,
                ),
                const SizedBox(height: 12),
                FutureBuilder<String>(
                  future: _getUserInfo(uid),
                  builder: (context, snapshot) {
                    final nomUser = snapshot.data ?? 'Chargement...';
                    return _buildInfoRow(
                      Icons.person_rounded,
                      "Client",
                      nomUser,
                      primaryPurple,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.schedule_rounded,
                  "Commandée le",
                  _formatDate(dateCommande),
                  primaryAmber,
                ),
                if (dateTraitement != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.check_circle_rounded,
                    "Traitée le",
                    _formatDate(dateTraitement),
                    primaryEmerald,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Actions
          if (etat == 'En attente')
            _buildActionButton(
              "Valider la commande",
              Icons.check_rounded,
              [primaryEmerald, primaryTeal],
                  () => _updateEtatCommande(commande.id, 'Traité'),
            ),
          if (etat == 'Traité')
            _buildActionButton(
              "Marquer comme envoyée",
              Icons.local_shipping_rounded,
              [primaryBlue, primaryIndigo],
                  () => _updateEtatCommande(commande.id, 'Envoyé'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String etat) {
    final color = _getColorForEtat(etat);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            etat.isNotEmpty ? etat : 'Inconnu',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, List<Color> colors, VoidCallback onPressed) {
    return _buildGradientContainer(
      colors: colors,
      borderRadius: 14,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
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
                Icons.inventory_rounded,
                size: 64,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Aucune commande trouvée",
              style: TextStyle(
                fontSize: 24,
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Les commandes apparaîtront ici une fois créées",
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
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
                  colors: [primaryAmber.withOpacity(0.2), primaryRose.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: primaryAmber,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Aucune commande correspondante",
              style: TextStyle(
                fontSize: 24,
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Modifiez vos critères de recherche ou filtres",
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _buildGradientContainer(
              colors: const [primaryBlue, primaryIndigo],
              borderRadius: 14,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() {
                    _filtreEtat = 'Tous';
                    _searchQuery = '';
                  }),
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          "Réinitialiser les filtres",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16,
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
      ),
    );
  }

  Future<String> _getUserInfo(String uid) async {
    if (_userInfoCache.containsKey(uid)) return _userInfoCache[uid]!;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      final prenom = data?['prenom'] ?? '';
      final nom = data?['nom'] ?? '';
      final fullName = '$prenom $nom'.trim();
      final result = fullName.isNotEmpty ? fullName : 'Utilisateur inconnu';
      _userInfoCache[uid] = result;
      return result;
    } catch (_) {
      return 'Utilisateur inconnu';
    }
  }

  Color _getColorForEtat(String? etat) {
    switch (etat?.toLowerCase()) {
      case 'en attente':
        return primaryAmber;
      case 'traité':
        return primaryEmerald;
      case 'envoyé':
        return primaryBlue;
      default:
        return textMuted;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  Future<void> _updateEtatCommande(String docId, String nouvelEtat) async {
    try {
      final updateData = {
        'etat': nouvelEtat,
        if (nouvelEtat == 'Traité') 'dateTraitement': FieldValue.serverTimestamp(),
        if (nouvelEtat == 'Envoyé') 'dateEnvoi': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('commandesPieces').doc(docId).update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text("Commande marquée comme $nouvelEtat"),
            ],
          ),
          backgroundColor: primaryEmerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Erreur lors de la mise à jour"),
            ],
          ),
          backgroundColor: primaryRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}