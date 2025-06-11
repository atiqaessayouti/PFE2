import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GestionDemandesEntretiensPage extends StatelessWidget {
  const GestionDemandesEntretiensPage({super.key});

  void updateStatut(String demandeId, String statut, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('demandesEntretiens').doc(demandeId).update({
        'statut': statut,
        'garagisteId': FirebaseAuth.instance.currentUser!.uid,
        'reponse': statut == 'Refusé' ? 'Refusé par le garagiste' : 'Demande confirmée',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut mis à jour : $statut'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(
          "Demandes d'entretiens",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade700,
                Colors.orange.shade600,
                Colors.blue.shade600,
                Colors.green.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
              Colors.grey.shade900,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('demandesEntretiens')
              .orderBy('dateDemande', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                  strokeWidth: 3,
                ),
              );
            }

            final demandes = snapshot.data!.docs;

            if (demandes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune demande.',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final doc = demandes[index];
                final data = doc.data() as Map<String, dynamic>;
                final statut = data['statut'] ?? 'En attente';

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade800,
                        Colors.grey.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          data['nomVehicule'] ?? "Véhicule inconnu",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Description : ${data['description']}",
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Date souhaitée : ${data['dateSouhaitee']?.toDate()?.toLocal()?.toString().split(' ')[0] ?? '---'}",
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatutColor(statut).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getStatutColor(statut),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "Statut : $statut",
                                  style: TextStyle(
                                    color: _getStatutColor(statut),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: statut == 'En attente'
                            ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.blue.shade600,
                                Colors.red.shade600,
                                Colors.orange.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check_circle, color: Colors.green.shade400, size: 28),
                                    onPressed: () => updateStatut(doc.id, 'Confirmé', context),
                                    tooltip: 'Confirmer',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red.shade400, size: 28),
                                    onPressed: () => updateStatut(doc.id, 'Refusé', context),
                                    tooltip: 'Refuser',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            : Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatutColor(statut).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatutColor(statut),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            statut == 'Confirmé' ? Icons.check : Icons.cancel,
                            color: _getStatutColor(statut),
                            size: 24,
                          ),
                        ),
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

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'Confirmé':
        return Colors.green.shade400;
      case 'Refusé':
        return Colors.red.shade400;
      case 'En attente':
        return Colors.orange.shade400;
      default:
        return Colors.blue.shade400;
    }
  }
}