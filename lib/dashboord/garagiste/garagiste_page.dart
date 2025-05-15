import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'AjouterEntretienPage.dart';

class GaragistePage extends StatelessWidget {
  const GaragistePage({Key? key}) : super(key: key);

  final Color primaryColor = Colors.orange;

  @override
  Widget build(BuildContext context) {
    final aujourdHui = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Tableau de Bord", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Véhicules'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Entretiens'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pièces'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('entretiens').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final allDocs = snapshot.data!.docs;
                final aujourdHuiStr = "${aujourdHui.year}-${aujourdHui.month.toString().padLeft(2, '0')}-${aujourdHui.day.toString().padLeft(2, '0')}";

                int today = 0;
                int enCours = 0;
                int aVenir = 0;

                for (var doc in allDocs) {
                  final date = doc['date'] ?? '';
                  final statut = doc['statut'] ?? '';

                  if (date == aujourdHuiStr) {
                    today++;
                    if (statut == 'En cours') enCours++;
                    if (statut == 'À venir') aVenir++;
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildDashboardCard("Entretiens", today, Colors.amber),
                    buildDashboardCard("Commandes", 3, Colors.green),
                    buildDashboardCard("Véhicules actifs", 28, Colors.grey),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AjouterEntretienPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Planifier un entretien"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Commander des pièces"),
            ),

            const SizedBox(height: 16),
            const Text("Entretiens du jour", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('entretiens')
                    .where('date', isEqualTo: "${aujourdHui.year}-${aujourdHui.month.toString().padLeft(2, '0')}-${aujourdHui.day.toString().padLeft(2, '0')}")
                    .orderBy('heure')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("Aucun entretien pour aujourd'hui."));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final vehicule = doc['vehicule'] ?? '';
                      final client = doc['client'] ?? '';
                      final service = doc['service'] ?? '';
                      final heure = doc['heure'] ?? '';
                      final statut = doc['statut'] ?? 'À venir';

                      return EntretienCard(
                        vehicule: vehicule,
                        client: client,
                        service: service,
                        heure: heure,
                        statut: statut,
                      );
                    },
                  );
                },
              ),
            ),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text("Voir tous les entretiens"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardCard(String title, int value, Color color) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text("$value", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class EntretienCard extends StatelessWidget {
  final String vehicule;
  final String client;
  final String service;
  final String heure;
  final String statut;

  const EntretienCard({
    required this.vehicule,
    required this.client,
    required this.service,
    required this.heure,
    required this.statut,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getStatutColor(String statut) {
      switch (statut) {
        case 'Terminé':
          return Colors.green;
        case 'En cours':
          return Colors.orange;
        case 'À venir':
        default:
          return Colors.amber;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: BoxDecoration(
                color: getStatutColor(statut),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicule, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Client: $client"),
                  Text(service),
                  Text(heure),
                ],
              ),
            ),
            Column(
              children: [
                Chip(
                  label: Text(statut, style: const TextStyle(color: Colors.white)),
                  backgroundColor: getStatutColor(statut),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Détails"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
