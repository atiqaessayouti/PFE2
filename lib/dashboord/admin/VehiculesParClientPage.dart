import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehiculesParClientPage extends StatefulWidget {
  const VehiculesParClientPage({super.key});

  @override
  State<VehiculesParClientPage> createState() => _VehiculesParClientPage();
}

class _VehiculesParClientPage extends State<VehiculesParClientPage>
    with TickerProviderStateMixin {
  Map<String, String> userNames = {};
  String searchQuery = '';
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
    _loadUserNames();
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

  Future<void> _loadUserNames() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, String> names = {};
    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      final prenom = data['prenom'] ?? '';
      final nom = data['nom'] ?? '';
      names[doc.id] = '$prenom $nom'.trim().isNotEmpty ? '$prenom $nom'.trim() : 'Client inconnu';
    }
    setState(() {
      userNames = names;
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

  Color _getStatusColor(Map<String, dynamic> data) {
    final maintenancePrevue = data['maintenancePrevue'] as Timestamp?;
    if (maintenancePrevue != null) {
      final now = DateTime.now();
      final prevue = maintenancePrevue.toDate();
      if (prevue.isBefore(now)) return primaryRose;
      if (prevue.difference(now).inDays < 15) return primaryAmber;
    }
    return primaryEmerald;
  }

  String _getStatusText(Map<String, dynamic> data) {
    final derniere = data['derniereMaintenance'] as Timestamp?;
    final prevue = data['maintenancePrevue'] as Timestamp?;
    final format = DateFormat('dd/MM/yyyy');
    if (prevue != null) {
      final now = DateTime.now();
      final date = prevue.toDate();
      if (date.isBefore(now)) return 'Maintenance requise';
      if (date.difference(now).inDays < 15) return 'Prévue: ${format.format(date)}';
    }
    if (derniere != null) return 'À jour - ${format.format(derniere.toDate())}';
    return 'Pas d\'historique';
  }

  String _getVehicleEmoji(String? type) {
    switch (type?.toLowerCase()) {
      case 'berline': return '🚗';
      case 'suv': return '🚙';
      case 'camionnette': return '🚐';
      case 'moto': return '🏍️';
      default: return '🚗';
    }
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
                      _buildSearchSection(),
                      _buildVehiculesContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
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
        title: const Text(
          "Gestion des Véhicules",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: surfaceDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: textPrimary),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryTeal, primaryEmerald],
            ),
            shape: BoxShape.circle,
          ),
          child: const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Text(
              "A",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _buildGlassCard(
        child: Container(
          decoration: BoxDecoration(
            color: darkBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withOpacity(0.3)),
          ),
          child: TextField(
            style: const TextStyle(color: textPrimary, fontSize: 16),
            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Rechercher un véhicule...",
              hintStyle: const TextStyle(color: textMuted),
              prefixIcon: const Icon(Icons.search, color: primaryBlue),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: textMuted),
                onPressed: () => setState(() => searchQuery = ''),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehiculesContent() {
    return Column(
      children: [
        // En-tête de la liste
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildGradientContainer(
            colors: const [primaryTeal, primaryEmerald],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Véhicules",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Gestion et suivi des véhicules",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Liste des véhicules
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vehicules').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || userNames.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: primaryBlue,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chargement des véhicules...',
                        style: TextStyle(color: textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              final vehicules = snapshot.data!.docs.where((vehicule) {
                final data = vehicule.data() as Map<String, dynamic>;
                final marque = data['marque']?.toString().toLowerCase() ?? '';
                final modele = data['modele']?.toString().toLowerCase() ?? '';
                final immat = data['immatriculation']?.toString().toLowerCase() ?? '';
                return searchQuery.isEmpty ||
                    marque.contains(searchQuery) ||
                    modele.contains(searchQuery) ||
                    immat.contains(searchQuery);
              }).toList();

              if (vehicules.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: vehicules.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    child: _buildVehiculeCard(vehicules[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehiculeCard(QueryDocumentSnapshot vehicule) {
    final data = vehicule.data() as Map<String, dynamic>;
    final userId = data['userId'] ?? 'inconnu';
    final marque = data['marque'] ?? 'Inconnue';
    final modele = data['modele'] ?? '';
    final immat = data['immatriculation'] ?? 'N/A';
    final type = data['type'] ?? '';
    final nomClient = userNames[userId] ?? 'Client inconnu';
    final statusColor = _getStatusColor(data);
    final statusText = _getStatusText(data);
    final emoji = _getVehicleEmoji(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: _buildGlassCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigation vers les détails du véhicule
          },
          child: Row(
            children: [
              // Icône du véhicule
              Hero(
                tag: 'vehicule_${vehicule.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue.withOpacity(0.3), primaryIndigo.withOpacity(0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryBlue.withOpacity(0.5)),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Informations du véhicule
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$marque $modele',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryTeal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          nomClient,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Immatriculation et flèche
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                      immat,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: darkBackground.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: textMuted,
                      size: 20,
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

  Widget _buildEmptyState() {
    return Center(
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
              Icons.search_off_rounded,
              size: 64,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Aucun véhicule trouvé",
            style: TextStyle(
              fontSize: 20,
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Essayez avec d'autres termes de recherche",
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return _buildGradientContainer(
      colors: const [primaryTeal, primaryEmerald],
      borderRadius: 16,
      child: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'ajout d'un nouveau véhicule
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}