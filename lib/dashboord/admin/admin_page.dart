import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:SuiviAuto/dashboord/admin/HistoriqueCommandesPage.dart';
import 'package:SuiviAuto/dashboord/client/HistoriqueCommandesClientPage.dart';
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

  // Palette de couleurs professionnelle
  static const Color primaryColor = Color(0xFF2A3F54);
  static const Color secondaryColor = Color(0xFF1ABB9C);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color darkBackground = Color(0xFF172D3A);
  static const Color cardColor = Color(0xFF2A3F54);
  static const Color textColor = Color(0xFFECF0F1);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darkBackground, primaryColor],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec bienvenue
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
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
                                  'Tableau de bord Admin',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gestion complète de votre application',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: textColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: secondaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: textColor,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Statistiques principales
            Text(
              'Statistiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                StreamBuilder<int>(
                  stream: _countCollection('users'),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Utilisateurs",
                      value: '${snapshot.data ?? 0}',
                      icon: Icons.people,
                      color: const Color(0xFF3498DB),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
                      },
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _countCollection('commandesPieces'),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Commandes",
                      value: '${snapshot.data ?? 0}',
                      icon: Icons.shopping_cart,
                      color: const Color(0xFF9B59B6),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoriqueCommandesAdminPage()));
                      },
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _countCollection('vehicule par client'),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Véhicules",
                      value: '${snapshot.data ?? 10}',
                      icon: Icons.directions_car,
                      color: const Color(0xFFE74C3C),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => VehiculesParClientPage()));
                      },
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: _countCollection('piecesStock'),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Pièces Stock",
                      value: '${snapshot.data ?? 0}',
                      icon: Icons.inventory,
                      color: const Color(0xFF1ABB9C),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage()));
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Actions rapides
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  icon: Icons.group_add,
                  title: "Gérer utilisateurs",
                  color: const Color(0xFF3498DB),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.inventory,
                  title: "Gérer stock",
                  color: const Color(0xFF1ABB9C),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage()));
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.car_repair,
                  title: "Véhicules clients",
                  color: const Color(0xFFE74C3C),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => VehiculesParClientPage()));
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.settings,
                  title: "Paramètres",
                  color: const Color(0xFF9B59B6),
                  onTap: () {
                    // Naviguer vers les paramètres
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Alertes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE74C3C).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Color(0xFFE74C3C),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alertes système',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '3 articles en stock critique',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                    },
                  ),
                ],
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

      const Center(child: Text('Paramètres', style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          'Tableau de bord Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: cardColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: textColor.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),

        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Déconnexion',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: textColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
}