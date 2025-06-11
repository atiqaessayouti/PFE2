import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDemandesEntretiensPage extends StatelessWidget {
  const AdminDemandesEntretiensPage({super.key});

  Future<String> getNomUtilisateur(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('utilisateurs').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return data['nom'] ?? 'Nom inconnu';
    }
    return 'Utilisateur inconnu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Toutes les demandes d'entretiens")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('demandesEntretiens')
            .orderBy('dateDemande', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final demandes = snapshot.data!.docs;

          if (demandes.isEmpty) {
            return Center(child: Text("Aucune demande trouvée."));
          }

          return ListView.builder(
            itemCount: demandes.length,
            itemBuilder: (context, index) {
              final doc = demandes[index];
              final data = doc.data() as Map<String, dynamic>;

              final nomVehicule = data['nomVehicule'] ?? "Véhicule inconnu";
              final description = data['description'] ?? "";
              final dateSouhaitee = data['dateSouhaitee']?.toDate();
              final statut = data['statut'] ?? "Inconnu";

              return FutureBuilder(
                future: Future.wait([
                  getNomUtilisateur(data['clientId']),
                  if (statut != 'En attente') getNomUtilisateur(data['garagisteId']) else Future.value(''),
                ]),
                builder: (context, AsyncSnapshot<List<String>> userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox();

                  final nomClient = userSnapshot.data![0];
                  final nomGaragiste = statut != 'En attente' ? userSnapshot.data![1] : '';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      title: Text(nomVehicule),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Client : $nomClient"),
                          if (nomGaragiste.isNotEmpty) Text("Garagiste : $nomGaragiste"),
                          Text("Description : $description"),
                          Text("Date souhaitée : ${dateSouhaitee != null ? dateSouhaitee.toLocal().toString().split(' ')[0] : '---'}"),
                          Text("Statut : $statut"),
                        ],
                      ),
                      trailing: Icon(
                        statut == 'Confirmé'
                            ? Icons.check_circle
                            : statut == 'Refusé'
                            ? Icons.cancel
                            : Icons.hourglass_empty,
                        color: statut == 'Confirmé'
                            ? Colors.green
                            : (statut == 'Refusé' ? Colors.red : Colors.orange),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
