import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../AjouterVehiculePage.dart';
import 'ProfilClientPage.dart';
import 'client_page.dart';

// Placeholder pour HomePage et ProfilPage
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      body: const Center(child: Text("Page d'accueil")),
    );
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: const Center(child: Text("Page profil")),
    );
  }
}

class MesVehiculesPage extends StatefulWidget {
  const MesVehiculesPage({super.key});

  @override
  State<MesVehiculesPage> createState() => _MesVehiculesPageState();
}

class _MesVehiculesPageState extends State<MesVehiculesPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Palette de couleurs thème sombre vert-bleu
  final primaryColor = const Color(0xFF00B4A6); // Teal/Cyan
  final secondaryColor = const Color(0xFF4CAF50); // Vert
  final accentColor = const Color(0xFF00E5FF); // Cyan clair
  final darkBg = const Color(0xFF0F1419); // Fond très sombre
  final cardBg = const Color(0xFF1A2332); // Fond des cartes
  final surfaceBg = const Color(0xFF243447); // Surface intermédiaire
  final textPrimary = const Color(0xFFE8F4F8);
  final textSecondary = const Color(0xFFB0BEC5);

  IconData _getCarIcon(String? marque) {
    if (marque == null) return Icons.directions_car;

    switch (marque.toLowerCase()) {
      case 'mercedes':
      case 'bmw':
      case 'audi':
        return Icons.directions_car_filled;
      case 'toyota':
      case 'honda':
      case 'nissan':
        return Icons.directions_car_outlined;
      case 'peugeot':
      case 'renault':
      case 'citroen':
        return Icons.directions_car;
      default:
        return Icons.directions_car;
    }
  }

  Color _getCarColor(String? marque) {
    if (marque == null) return primaryColor;

    switch (marque.toLowerCase()) {
      case 'mercedes':
        return const Color(0xFF90A4AE);
      case 'bmw':
        return const Color(0xFF2196F3);
      case 'audi':
        return const Color(0xFFE57373);
      case 'toyota':
        return const Color(0xFF4CAF50);
      case 'honda':
        return const Color(0xFFFF9800);
      case 'nissan':
        return const Color(0xFF9C27B0);
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text(
          'Mes Véhicules',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.8),
                secondaryColor.withOpacity(0.6),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.add, size: 20, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AjouterVehiculePage()),
                ).then((_) => setState(() {}));
              },
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 2.0,
            colors: [
              primaryColor.withOpacity(0.1),
              darkBg,
              const Color(0xFF0A0E13),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header avec statistiques
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardBg,
                    surfaceBg.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.8),
                          accentColor.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.garage,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mon Garage",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('vehicules')
                              .where('userId', isEqualTo: uid)
                              .get(),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.docs.length ?? 0;
                            return Text(
                              "$count véhicule${count > 1 ? 's' : ''} enregistré${count > 1 ? 's' : ''}",
                              style: TextStyle(
                                fontSize: 15,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('vehicules')
                    .where('userId', isEqualTo: uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        strokeWidth: 3,
                      ),
                    );
                  }

                  final vehicules = snapshot.data?.docs ?? [];

                  if (vehicules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.2),
                                  accentColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.directions_car_outlined,
                              size: 64,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Aucun véhicule enregistré",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Ajoutez votre premier véhicule",
                            style: TextStyle(
                              fontSize: 16,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [primaryColor, secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  spreadRadius: 0,
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AjouterVehiculePage()),
                                ).then((_) => setState(() {}));
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Ajouter un véhicule',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicules.length,
                    itemBuilder: (context, index) {
                      final v = vehicules[index].data() as Map<String, dynamic>;
                      final marque = v['marque'] ?? '';
                      final modele = v['modele'] ?? '';
                      final immatriculation = v['immatriculation'] ?? '';
                      final kilometrage = v['kilometrage'] ?? '';
                      final annee = v['annee'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cardBg,
                              surfaceBg.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _getCarColor(marque).withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getCarColor(marque).withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            splashColor: primaryColor.withOpacity(0.1),
                            highlightColor: primaryColor.withOpacity(0.05),
                            onTap: () {
                              // Aller vers les détails du véhicule
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getCarColor(marque).withOpacity(0.8),
                                          _getCarColor(marque).withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getCarColor(marque).withOpacity(0.3),
                                          spreadRadius: 0,
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getCarIcon(marque),
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "$marque $modele",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                surfaceBg.withOpacity(0.8),
                                                darkBg.withOpacity(0.6),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _getCarColor(marque).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            immatriculation,
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.speed,
                                              size: 18,
                                              color: accentColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "$kilometrage km",
                                              style: TextStyle(
                                                color: textSecondary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                              color: primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              annee.toString(),
                                              style: TextStyle(
                                                color: textSecondary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor.withOpacity(0.8),
                                          accentColor.withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
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

            // Bouton flottant d'ajout
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AjouterVehiculePage()),
                    ).then((_) => setState(() {}));
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Ajouter un véhicule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cardBg,
              darkBg,
            ],
          ),
          border: Border(
            top: BorderSide(
              color: primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ClientDashboard()),
              );
            } else if (index == 1) {
              // Déjà ici
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProfilClientPage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: 'Véhicules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}