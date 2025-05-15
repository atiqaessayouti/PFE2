import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoriqueCommandesClientPage extends StatelessWidget {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  HistoriqueCommandesClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Commandes"),
        backgroundColor: Colors.green.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commandesPieces')
            .where('creePar', isEqualTo: uid)
            .orderBy('dateCommande', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement des commandes."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final commandes = snapshot.data!.docs;

          if (commandes.isEmpty) {
            return const Center(child: Text("Aucune commande trouvée."));
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
                      Text("Date : ${date.day}/${date.month}/${date.year}"),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart),
                      Text(commande['etat']),
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
