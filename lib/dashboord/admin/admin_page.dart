import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../AddPiecePage.dart';
import 'CommandesEnAttentePage.dart';
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

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          StreamBuilder<int>(
            stream: _countCollection('vehicules'),
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VehiculesParClientPage()),
                  );
                },
                child: _buildStatCard(
                  "Véhicules enregistrés",
                  '${snapshot.data ?? 0}',
                  Icons.directions_car,
                  Colors.red.shade100,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          StreamBuilder<int>(
            stream: _countCollection('entretiens'),
            builder: (context, snapshot) {
              return _buildStatCard("Entretiens en cours", '${snapshot.data ?? 0}', Icons.build, Colors.blue.shade100);
            },
          ),
          const SizedBox(height: 12),

          StreamBuilder<int>(
            stream: _countCollection('piecesStock'),
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage()));
                },
                child: _buildStatCard("Pièces enregistrées", '${snapshot.data ?? 0}', Icons.handyman, Colors.orange.shade100),
              );
            },
          ),
          const SizedBox(height: 12),

          StreamBuilder<int>(
            stream: _countCollection('users'),
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()));
                },
                child: _buildStatCard("Utilisateurs enregistrés", '${snapshot.data ?? 0}', Icons.people, Colors.green.shade100),
              );
            },
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('commandesPieces')
                .where('etat', isEqualTo: 'En attente')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildStatCard("Commandes en attente", '...', Icons.inventory, Colors.brown.shade100);
              }
              if (snapshot.hasError) {
                return _buildStatCard("Commandes en attente", 'Erreur', Icons.inventory, Colors.brown.shade100);
              }
              final nbCommandes = snapshot.data?.docs.length ?? 0;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CommandesEnAttentePage()),
                  );
                },
                child: _buildStatCard("Commandes en attente", '$nbCommandes', Icons.inventory, Colors.brown.shade100),
              );
            },
          ),


          const SizedBox(height: 24),
          const Text('Alertes Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.red, width: 4))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Stock critique', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    SizedBox(height: 8),
                    Text('3 articles sont en rupture de stock ou presque.'),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(label: Text('Urgent', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                        Text('Voir détails', style: TextStyle(color: Colors.red, decoration: TextDecoration.underline)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
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
      const Center(child: Text('Paramètres (à implémenter)')),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Voir les notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Utilisateurs'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Garagistes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}
