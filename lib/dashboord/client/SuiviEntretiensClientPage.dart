import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SuiviEntretiensClientPage extends StatelessWidget {
  const SuiviEntretiensClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Suivi de mes entretiens"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A1A2E), // Bleu très sombre
                Color(0xFF16213E), // Bleu nuit
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0F1B), // Noir bleuté
              Color(0xFF1A1A2E), // Bleu très sombre
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('demandesEntretiens')
              .where('clientId', isEqualTo: userId)
              .orderBy('dateSouhaitee', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('🔥 Firestore error: ${snapshot.error}');
              return const Center(child: Text("Erreur de chargement", style: TextStyle(color: Colors.white70)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4D4D))));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "Aucune demande trouvée",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nomVehicule = data['nomVehicule'] ?? 'Inconnu';
                final description = data['description'] ?? 'Aucune description';
                final date = (data['dateSouhaitee'] as Timestamp?)?.toDate();
                final statut = (data['statut'] ?? 'en attente').toString().toLowerCase().trim();

                IconData icon;
                Color color;
                String statutAffiche;

                switch (statut) {
                  case 'accepté':
                    icon = Icons.check_circle;
                    color = const Color(0xFF4CAF50); // Vert
                    statutAffiche = "Accepté";
                    break;
                  case 'refusé':
                    icon = Icons.cancel;
                    color = const Color(0xFFFF4D4D); // Rouge orangé
                    statutAffiche = "Refusé";
                    break;
                  default:
                    icon = Icons.hourglass_top;
                    color = const Color(0xFFFFA726); // Orange
                    statutAffiche = "En attente";
                }

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color(0xFF1E1E2E).withOpacity(0.8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      nomVehicule,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "Description : $description",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Date souhaitée : ${date?.toLocal().toString().split(' ')[0] ?? 'Non précisée'}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: color, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          statutAffiche,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}