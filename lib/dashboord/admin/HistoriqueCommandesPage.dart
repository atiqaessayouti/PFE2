import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoriqueCommandesClientPage extends StatelessWidget {
  HistoriqueCommandesClientPage({super.key});

  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Commandes en attente"),
          backgroundColor: Colors.green.shade700,
        ),
        body: const Center(
          child: Text("Veuillez vous connecter pour voir vos commandes."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Commandes de Pièces"),
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('commandesPieces')
            .where('commandePar', isEqualTo: uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint("Erreur Firestore: ${snapshot.error}");
            return _errorMessage(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            _checkAllCommandes();
            return const Center(
              child: Text("Aucune commande trouvée pour votre compte."),
            );
          }

          final commandes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              try {
                final data = commandes[index].data() as Map<String, dynamic>;

                final nomPiece = _getChampString(data, 'nomPiece', 'Nom inconnu');
                final etat = _getChampString(data, 'etat', 'État inconnu');
                final quantite = _getChampString(data, 'quantite', 'N/A');
                final dateFormatee = _formaterDate(data['dateCommande']);
                final docId = commandes[index].id;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nomPiece,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorForEtat(etat),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                etat,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Quantité: $quantite"),
                        Text("Date: $dateFormatee"),
                        Text("ID Commande: $docId", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                debugPrint("Erreur d'affichage de la commande $index: $e");
                return _errorCard("Erreur d'affichage de la commande.");
              }
            },
          );
        },
      ),
    );
  }

  // Fonction utilitaire pour lire un champ string de manière sécurisée
  String _getChampString(Map<String, dynamic> data, String champ, String valeurDefaut) {
    if (data.containsKey(champ) && data[champ] != null) {
      return data[champ].toString();
    }
    return valeurDefaut;
  }

  // Affiche une carte d'erreur dans la liste
  Widget _errorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  // Affiche une erreur en pleine page
  Widget _errorMessage(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Erreur de chargement des commandes."),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // Formate la date à partir d’un Timestamp Firebase
  String _formaterDate(dynamic dateRaw) {
    try {
      if (dateRaw is Timestamp) {
        final date = dateRaw.toDate();
        return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      }
    } catch (e) {
      debugPrint("Erreur de formatage de date: $e");
    }
    return "Date inconnue";
  }

  // Récupération des couleurs d’état
  Color _getColorForEtat(String etat) {
    switch (etat.toLowerCase()) {
      case 'en attente':
        return Colors.orange;
      case 'validée':
      case 'validee':
        return Colors.green;
      case 'livrée':
      case 'livree':
        return Colors.blue;
      case 'annulée':
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Vérifie s'il existe des commandes, pour tester les règles Firestore
  Future<void> _checkAllCommandes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('commandesPieces')
          .limit(5)
          .get();

      debugPrint("Commandes (sans filtre): ${snapshot.docs.length}");
      for (var doc in snapshot.docs) {
        debugPrint("Commande: ${doc.data()}");
      }
    } catch (e) {
      debugPrint("Erreur de vérification des commandes: $e");
    }
  }
}
