import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommandesEnAttentePage extends StatelessWidget {
  const CommandesEnAttentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Commandes en attente"),
        backgroundColor: Colors.brown.shade400,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commandesPieces')
            .where('etat', isEqualTo: 'En attente')
            .orderBy('dateCommande', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement des commandes."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final commandes = snapshot.data!.docs;

          if (commandes.isEmpty) {
            return const Center(child: Text("Aucune commande en attente."));
          }

          return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              final commande = commandes[index];
              final date = (commande['dateCommande'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text("${commande['nomPiece']} (x${commande['quantite']})"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Réf : ${commande['refPiece'] ?? 'N/A'}"),
                      Text("Créée par : ${commande['creePar']}"),
                      Text("Date : ${date.day}/${date.month}/${date.year}"),
                    ],
                  ),
                  trailing: const Icon(Icons.pending_actions, color: Colors.brown),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
