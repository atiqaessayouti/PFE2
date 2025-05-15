import 'package:flutter/material.dart';

class ConfirmationAjoutPage extends StatelessWidget {
  final String vehiculeNom;
  final Color primaryColor;

  const ConfirmationAjoutPage({
    Key? key,
    required this.vehiculeNom,
    this.primaryColor = const Color(0xFF388E3C), // Vert par défaut
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Véhicule ajouté'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: primaryColor, size: 80),
            const SizedBox(height: 20),
            Text(
              'Véhicule ajouté avec succès',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$vehiculeNom a été ajouté à votre liste de véhicules.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
