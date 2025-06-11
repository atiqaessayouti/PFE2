import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/dashboord/admin/HistoriqueCommandesPage.dart';
import 'package:untitled1/dashboord/client/HistoriqueCommandesClientPage.dart';
import '../../LoginScreen.dart';
import '../AddPiecePage.dart';
import 'CommandesEnAttentePage.dart';
import 'HistoriqueEntretienAdminPage.dart';
import 'StockPage.dart';
import 'UserManagementPage.dart';
import 'NotificationsPage.dart';
import 'GaragisteApprovalPage.dart';
import 'VehiculesParClientPage.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  // Palette de couleurs sombres avec dégradés mauve et orange
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color deepPurple = Color(0xFF4C1D95);
  static const Color lightPurple = Color(0xFF8B5CF6);
  static const Color primaryOrange = Color(0xFFEA580C);
  static const Color deepOrange = Color(0xFFD97706);
  static const Color lightOrange = Color(0xFFFF8A50);

  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color cardDark = Color(0xFF1A1B3A);
  static const Color surfaceDark = Color(0xFF252641);
  static const Color accentDark = Color(0xFF2D2F48);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Stream<int> _countCollection(String collectionPath) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboardContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 2.0,
          colors: [
            Color(0xFF1A1B3A),
            darkBackground,
            Color(0xFF0A0A1A),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec bienvenue amélioré - Style sombre
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      margin: const EdgeInsets.only(bottom: 28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6B46C1),
                            Color(0xFF8B5CF6),
                            Color(0xFFEA580C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(8, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenue Admin 🚀',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tableau de bord moderne - Gestion intelligente',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Statistiques principales avec design sombre amélioré
            Text(
              'Analytics en Temps Réel',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 1.0,
              children: [
                StreamBuilder<int>(
                  stream: _countCollection('users'),
                  builder: (context, snapshot) {
                    return _buildStatCard2(
                      title: "Utilisateurs",
                      value: '${snapshot.data ?? 0}',
                      icon: Icons.people_alt_rounded,
                      gradient: const [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
                      },
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _countCollection('commandesPieces'),
                  builder: (context, snapshot) {
                    return _buildStatCard2(
                      title: "Commandes",
                      value: '${snapshot.data ?? 0}',
                      icon: Icons.shopping_cart_rounded,
                      gradient: const [Color(0xFFFF8A50), Color(0xFFEA580C)],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoriqueCommandesAdminPage()));
                      },
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _countCollection('vehicule par client'),
                  builder: (context, snapshot) {
                    return _buildStatCard2(
                      title: "Véhicules",
                      value: '${snapshot.data ?? 10}',
                      icon: Icons.directions_car_rounded,
                      gradient: const [Color(0xFFA855F7), Color(0xFF7C2D92)],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => VehiculesParClientPage()));
                      },
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _countCollection('piecesStock'),
                  builder: (context, snapshot) {
                    return _buildStatCard2(
                      title: "Pièces Stock",
                      value: '${snapshot.data ?? 0}',
                      icon: Icons.handyman_rounded,
                      gradient: const [Color(0xFFD97706), Color(0xFFB45309)],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage()));
                      },
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('commandesPieces')
                      .where('etat', isEqualTo: 'En attente')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final nbCommandes = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard2(
                      title: "En Attente",
                      value: '$nbCommandes',
                      icon: Icons.pending_actions_rounded,
                      gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoriqueCommandesAdminPage()));
                      },
                    );
                  },
                ),

              ],
            ),

            const SizedBox(height: 36),

            // Section Actions rapides améliorée - Style sombre
            Text(
              'Actions Rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cardDark.withOpacity(0.8),
                    surfaceDark.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
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
              child: Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  _buildQuickAction(
                    icon: Icons.group_add_rounded,
                    label: 'Gérer Utilisateurs',
                    gradient: const [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.inventory_rounded,
                    label: 'Stock Pièces',
                    gradient: const [Color(0xFFFF8A50), Color(0xFFEA580C)],
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage()));
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.analytics_rounded,
                    label: 'Analytics',
                    gradient: const [Color(0xFFA855F7), Color(0xFF7C2D92)],
                    onTap: () {
                      // Naviguer vers la page des statistiques
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.settings_applications_rounded,
                    label: 'Paramètres',
                    gradient: const [Color(0xFFD97706), Color(0xFFB45309)],
                    onTap: () {
                      // Naviguer vers les paramètres
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Section Alertes améliorée - Style sombre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alertes Système',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFDC2626).withOpacity(0.2),
                    const Color(0xFFEA580C).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFDC2626).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock Critique Détecté',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '3 articles sont en rupture ou niveau critique. Action immédiate requise.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                      ),
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

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildDashboardContent(),
      const StockPage(),
      const UserManagementPage(),
      const GaragisteApprovalPage(),
      const Center(child: Text('Paramètres (à implémenter)', style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6B46C1),
                Color(0xFF8B5CF6),
                Color(0xFFEA580C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: Colors.white),
            ),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white),
            ),
            tooltip: 'Déconnexion',
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => LoginScreen()));
              _showLogoutDialog();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardDark.withOpacity(0.95),
              surfaceDark.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: BottomAppBar(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.transparent,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
              _buildBottomNavItem(Icons.inventory_2_rounded, 'Stock', 1),
              _buildBottomNavItem(Icons.people_alt_rounded, 'Utilisateurs', 2),
              _buildBottomNavItem(Icons.settings_rounded, 'Paramètres', 4),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Déconnexion',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: lightPurple),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEA580C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade400,
              size: 20, // Reduced icon size
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Smaller font size
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade400,
              ),
              maxLines: 1, // Ensure text doesn't wrap
              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatCard2({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardDark.withOpacity(0.8),
              surfaceDark.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[300],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentDark.withOpacity(0.6),
              surfaceDark.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}