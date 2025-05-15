import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

class _ClientDashboardState extends State<ClientDashboard> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Couleurs du thème sombre avec accent vert
  final primaryColor = Colors.green[700];
  final accentColor = Colors.green[500];
  final backgroundColor = Color(0xFF121212);
  final cardColor = Color(0xFF1E1E1E);
  final textColor = Colors.white;
  final secondaryTextColor = Colors.grey[400];

  late Stream<int> _vehiculeCountStream;
  late Stream<int> _entretienCountStream;
  late Stream<int> _commandeCountStream;
  late Stream<int> _unreadNotifCountStream;

  @override
  void initState() {
    super.initState();
    _vehiculeCountStream = _createVehiculeCountStream();
    _entretienCountStream = _createEntretienCountStream();
    _commandeCountStream = _createCommandeCountStream();
    _unreadNotifCountStream = _createUnreadNotifCountStream();
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        actions: [
          StreamBuilder<int>(
            stream: _unreadNotifCountStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // Navigation vers les notifications
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
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
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilClientPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              backgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Bienvenue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder<int>(
                stream: _vehiculeCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return _buildCard(
                    title: "Mes Véhicules",
                    subtitle: "$count véhicule${count != 1 ? 's' : ''} enregistré${count != 1 ? 's' : ''}",
                    icon: Icons.directions_car,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MesVehiculesPage()),
                      );
                    },
                  );
                },
              ),
              StreamBuilder<int>(
                stream: _entretienCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return _buildCard(
                    title: "Historique d'entretien",
                    subtitle: "$count entretien${count != 1 ? 's' : ''} récent${count != 1 ? 's' : ''}",
                    icon: Icons.build,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.history, color: accentColor),
                              title: Text("Voir l'historique", style: TextStyle(color: textColor)),
                              onTap: () {
                                Navigator.pop(context); // Ferme le modal
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HistoriqueEntretienClientPage(), // Naviguer vers la page historique des entretiens
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.add, color: accentColor),
                              title: Text("Planifier un entretien", style: TextStyle(color: textColor)),
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
                            SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              StreamBuilder<int>(
                stream: _commandeCountStream,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return _buildCard(
                    title: "Mes commandes de pièces",
                    subtitle: "$count commande${count != 1 ? 's' : ''} passée${count != 1 ? 's' : ''}",
                    icon: Icons.shopping_cart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoriqueCommandesClientPage()),
                      );
                    },
                  );
                },
              ),
              _buildCard(
                title: "Catalogue de pièces",
                subtitle: "Rechercher des pièces",
                icon: Icons.store,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CataloguePiecesPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 8,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MesVehiculesPage()),
            );
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilClientPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
            backgroundColor: Color(0xFF1A1A1A),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Véhicules',
            backgroundColor: Color(0xFF1A1A1A),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
            backgroundColor: Color(0xFF1A1A1A),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailingBadge,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: cardColor,
      shadowColor: Colors.black.withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: accentColor?.withOpacity(0.1),
        highlightColor: accentColor?.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              if (trailingBadge != null) ...[
                trailingBadge,
                const SizedBox(width: 8),
              ],
              Icon(Icons.chevron_right, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}