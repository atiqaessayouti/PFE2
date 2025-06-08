import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../admin/StockPage.dart';
import '../client/HistoriqueCommandesClientPage.dart';
import '../client/HistoriqueEntretienClientPage.dart';
import '../client/MesVehiculesPage.dart';
import '../client/ProfilClientPage.dart';
import '../client/catalogue_pieces_page.dart';
import 'AjouterEntretienPage.dart';
import 'HistoriqueEntretienGaragistePage.dart';

class GaragistePage extends StatelessWidget {
  const GaragistePage({Key? key}) : super(key: key);

  // Palette de couleurs dégradé vert moderne
  final Color primaryGreen = const Color(0xFF10B981);      // Vert moderne
  final Color secondaryGreen = const Color(0xFF059669);    // Vert plus foncé
  final Color accentGreen = const Color(0xFF047857);       // Vert accent
  final Color lightGreen = const Color(0xFF6EE7B7);       // Vert clair
  final Color darkGreen = const Color(0xFF064E3B);        // Vert très foncé

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fond sombre
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
            "Tableau de Bord Garagiste",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            )
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, secondaryGreen, accentGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF334155),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: lightGreen,
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoriqueEntretienGaragistePage()),
              );
            }else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage()));
            }
            else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilClientPage()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.build_rounded), label: 'Entretiens'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_rounded), label: 'Pièces'),

          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des actions rapides avec dégradé
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryGreen.withOpacity(0.1),
                    secondaryGreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryGreen, lightGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Actions rapides",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      modernDarkActionButton(
                        "Planifier un entretien",
                        Icons.add_task_rounded,
                        [primaryGreen, lightGreen],
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AjouterEntretienGaragistePage())),
                      ),
                      modernDarkActionButton(
                        "Commander des pièces",
                        Icons.shopping_cart_rounded,
                        [secondaryGreen, primaryGreen],
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockPage())),
                      ),
                      modernDarkActionButton(
                        "Historique entretiens",
                        Icons.history_rounded,
                        [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriqueEntretienGaragistePage())),
                      ),
                      modernDarkActionButton(
                        "Historique commandes",
                        Icons.receipt_long_rounded,
                        [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoriqueCommandesClientPage())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BOUTON D'ACTION MODERNE SOMBRE
  Widget modernDarkActionButton(String title, IconData icon, List<Color> gradientColors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}