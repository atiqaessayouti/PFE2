import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoriqueEntretienClientPage extends StatefulWidget {
  const HistoriqueEntretienClientPage({Key? key}) : super(key: key);

  @override
  _HistoriqueEntretienClientPageState createState() => _HistoriqueEntretienClientPageState();
}

class _HistoriqueEntretienClientPageState extends State<HistoriqueEntretienClientPage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    // Vérification de l'utilisateur authentifié
    if (FirebaseAuth.instance.currentUser == null) {
      return const Center(child: Text("Utilisateur non authentifié"));
    }

    print("UID de l'utilisateur authentifié: $uid");  // Débogage pour vérifier l'UID

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique d'Entretiens"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('entretiens')
              .where('client', isEqualTo: uid)
              .orderBy('date', descending: true) // Assurez-vous que 'date' existe dans votre base de données
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Aucun entretien trouvé"));
            }

            final entretiens = snapshot.data!.docs;

            return ListView.builder(
              itemCount: entretiens.length,
              itemBuilder: (context, index) {
                final entretien = entretiens[index];
                final String date = entretien['date'];
                final String service = entretien['service'];
                final String vehicule = entretien['vehicule'];
                final String statut = entretien['statut'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // TODO: Ajouter une navigation pour afficher les détails de l'entretien
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.build, color: Colors.green, size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Véhicule: $vehicule",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Service: $service",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Date: $date",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Statut: $statut",
                                  style: TextStyle(
                                    color: statut == 'Terminé' ? Colors.green : Colors.orange,
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
              },
            );
          },
        ),
      ),
    );
  }
}
