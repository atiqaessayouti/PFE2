import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DemandesEntretiensPage extends StatelessWidget {
  final Color primaryGreen = const Color(0xFF10B981);
  final Color darkGreen = const Color(0xFF064E3B);

  DemandesEntretiensPage({super.key});

  void updateStatut(String docId, String newStatut) {
    FirebaseFirestore.instance
        .collection('demandesEntretiens')
        .doc(docId)
        .update({'statut': newStatut});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Demandes d'entretiens",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryGreen,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('demandesEntretiens')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Aucune demande pour le moment", style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final statut = data['statut'];
              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Client ID : ${data['clientId']}", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text("Véhicule : ${data['vehicule']}", style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text("Date : ${data['date']}", style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text("Description : ${data['description']}", style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              statut,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: statut == "accepté"
                                ? Colors.green
                                : statut == "refusé"
                                ? Colors.red
                                : Colors.orange,
                          ),
                          const Spacer(),
                          if (statut == "en attente") ...[
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Accepter"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () => updateStatut(data.id, "accepté"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text("Refuser"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => updateStatut(data.id, "refusé"),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
