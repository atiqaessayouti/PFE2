import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoriqueEntretienAdminPage extends StatelessWidget {
  const HistoriqueEntretienAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les entretiens"),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('entretiens')
            .orderBy('dateCréation', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entretiens = snapshot.data!.docs;

          if (entretiens.isEmpty) {
            return const Center(child: Text("Aucun entretien trouvé."));
          }

          return ListView.builder(
            itemCount: entretiens.length,
            itemBuilder: (context, index) {
              final doc = entretiens[index];
              final data = doc.data() as Map<String, dynamic>;

              // ✅ Gestion robuste du champ "date"
              DateTime? date;
              if (data['date'] is Timestamp) {
                date = (data['date'] as Timestamp).toDate();
              } else if (data['date'] is String) {
                try {
                  date = DateTime.parse(data['date']);
                } catch (e) {
                  date = null;
                }
              }

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    "Véhicule : ${data['vehicule'] ?? 'N/A'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Client : ${data['client'] ?? ''}"),
                      Text("Service : ${data['service'] ?? ''}"),
                      Text("Prix : ${data['prix'] ?? ''}"),
                      Text("Heure : ${data['heure'] ?? ''}"),
                      if (date != null)
                        Text("Date : ${DateFormat.yMMMd().format(date)}"),
                      Text("Statut : ${data['statut'] ?? ''}"),
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
