import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoriqueEntretienGaragistePage extends StatelessWidget {
  const HistoriqueEntretienGaragistePage({super.key});

  // Couleurs du thème vert-bleuté sombre
  static const Color primaryTeal = Color(0xFF00695C);
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFFE0F2F1);
  static const Color textSecondary = Color(0xFFB2DFDB);

  @override
  Widget build(BuildContext context) {
    final String? garagisteId = FirebaseAuth.instance.currentUser?.uid;

    if (garagisteId == null) {
      return Scaffold(
        backgroundColor: darkBackground,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentTeal.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: accentTeal,
                ),
                const SizedBox(height: 16),
                Text(
                  'Utilisateur non connecté',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final Stream<QuerySnapshot> entretiensStream = FirebaseFirestore.instance
        .collection('entretiens')
        .where('garagisteId', isEqualTo: garagisteId)
    // .orderBy('date', descending: true) // Désactivé temporairement
        .snapshots();

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'Mes Entretiens',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: accentTeal),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryTeal.withOpacity(0.8),
                accentTeal.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: entretiensStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentTeal),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des entretiens...',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentTeal.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: accentTeal.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: accentTeal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.build_outlined,
                        size: 48,
                        color: accentTeal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Aucun entretien trouvé",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Vos entretiens apparaîtront ici",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final entretiens = snapshot.data!.docs;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  darkBackground,
                  darkBackground.withOpacity(0.95),
                ],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entretiens.length,
              itemBuilder: (context, index) {
                final doc = entretiens[index];
                final data = doc.data() as Map<String, dynamic>;

                // Gestion de date null ou invalide
                String formattedDate = "Date inconnue";
                if (data['date'] != null && data['date'] is Timestamp) {
                  final date = (data['date'] as Timestamp).toDate();
                  formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                }

                // Déterminer la couleur du statut
                Color statusColor = textSecondary;
                IconData statusIcon = Icons.info_outline;

                final String statut = data['statut'] ?? 'Non défini';
                switch (statut.toLowerCase()) {
                  case 'terminé':
                  case 'termine':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle_outline;
                    break;
                  case 'en cours':
                    statusColor = Colors.orange;
                    statusIcon = Icons.schedule;
                    break;
                  case 'en attente':
                    statusColor = Colors.blue;
                    statusIcon = Icons.hourglass_empty;
                    break;
                  case 'annulé':
                  case 'annule':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel_outlined;
                    break;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardBackground,
                        cardBackground.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentTeal.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentTeal.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        color: accentTeal,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      "Véhicule : ${data['vehicule'] ?? 'Inconnu'}",
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Statut : $statut",
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: textSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Date : $formattedDate",
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: accentTeal,
                        size: 20,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}