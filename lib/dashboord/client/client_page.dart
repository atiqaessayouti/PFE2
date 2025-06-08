import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/StockPage.dart';
import 'AjoutEntretienClientPage.dart';
import 'HistoriqueCommandesClientPage.dart';
import 'HistoriqueEntretienClientPage.dart';
import 'MesVehiculesPage.dart';
import 'ProfilClientPage.dart';
import 'catalogue_pieces_page.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({Key? key}) : super(key: key);

  @override
  _ClientDashboardState createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> with TickerProviderStateMixin {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Palette de couleurs moderne
  final primaryColor = Color(0xFF0D7377);
  final accentColor = Color(0xFF14A085);
  final backgroundColor = Color(0xFF0A0E27);
  final cardColor = Color(0xFF1B1B2F);
  final surfaceColor = Color(0xFF162447);
  final textColor = Colors.white;
  final secondaryTextColor = Color(0xFF94A3B8);
  final gradientColors = [Color(0xFF14A085), Color(0xFF0D7377)];

  late Stream<int> _vehiculeCountStream;
  late Stream<int> _entretienCountStream;
  late Stream<int> _commandeCountStream;
  late Stream<int> _unreadNotifCountStream;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _vehiculeCountStream = _createVehiculeCountStream();
    _entretienCountStream = _createEntretienCountStream();
    _commandeCountStream = _createCommandeCountStream();
    _unreadNotifCountStream = _createUnreadNotifCountStream();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Stream<int> _createVehiculeCountStream() {
    return FirebaseFirestore.instance
        .collection('vehicules')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _createEntretienCountStream() {
    return FirebaseFirestore.instance
        .collection('entretiens')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _createCommandeCountStream() {
    return FirebaseFirestore.instance
        .collection('commandesPieces')
        .where('creePar', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _createUnreadNotifCountStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('lu', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              surfaceColor.withOpacity(0.8),
              backgroundColor,
              Color(0xFF0F0F1E),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(),
                          SizedBox(height: 32),
                          _buildStatsGrid(),
                          SizedBox(height: 24),
                          _buildQuickActions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
        ).createShader(bounds),
        child: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      actions: [
        StreamBuilder<int>(
          stream: _unreadNotifCountStream,
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return Container(
              margin: EdgeInsets.only(right: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 24),
                      onPressed: () {
                        // Navigation vers les notifications
                      },
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.5),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        Container(
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilClientPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bienvenue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Gérez vos véhicules et entretiens",
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StreamBuilder<int>(
                stream: _vehiculeCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return _buildStatCard(
                    title: "Véhicules",
                    count: count.toString(),
                    icon: Icons.directions_car_outlined,
                    gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MesVehiculesPage()),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StreamBuilder<int>(
                stream: _entretienCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return _buildStatCard(
                    title: "Entretiens",
                    count: count.toString(),
                    icon: Icons.build_outlined,
                    gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
                    onTap: () => _showEntretienOptions(),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StreamBuilder<int>(
                stream: _commandeCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return _buildStatCard(
                    title: "Commandes",
                    count: count.toString(),
                    icon: Icons.shopping_bag_outlined,
                    gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoriqueCommandesClientPage()),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: "Catalogue",
                count: "∞",
                icon: Icons.store_outlined,
                gradient: gradientColors,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockPage()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 120,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Actions rapides",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        _buildActionCard(
          title: "Planifier un entretien",
          subtitle: "Réservez un créneau pour votre véhicule",
          icon: Icons.calendar_today_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjouterEntretienClientPage()),
          ),
        ),
        SizedBox(height: 12),
        _buildActionCard(
          title: "Voir l'historique",
          subtitle: "Consultez vos entretiens précédents",
          icon: Icons.history_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoriqueEntretienClientPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: surfaceColor.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: accentColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEntretienOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildModalOption(
                    icon: Icons.history_outlined,
                    title: "Voir l'historique",
                    subtitle: "Consultez vos entretiens",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoriqueEntretienClientPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildModalOption(
                    icon: Icons.add_circle_outline,
                    title: "Planifier un entretien",
                    subtitle: "Réservez un nouveau créneau",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AjouterEntretienClientPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: accentColor,
        unselectedItemColor: secondaryTextColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MesVehiculesPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilClientPage()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.home_outlined, size: 20),
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            label: 'Véhicules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}