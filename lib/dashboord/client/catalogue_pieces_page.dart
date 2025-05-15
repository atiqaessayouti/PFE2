import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CataloguePiecesPage extends StatefulWidget {
  const CataloguePiecesPage({Key? key}) : super(key: key);

  @override
  State<CataloguePiecesPage> createState() => _CataloguePiecesPageState();
}

class _CataloguePiecesPageState extends State<CataloguePiecesPage> {
  String searchQuery = '';
  String selectedCategory = 'Tous';

  Future<void> _showCommandeDialog(BuildContext context, String pieceId, String nom, String ref) async {
    final TextEditingController quantiteController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non authentifié")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Commander cette pièce"),
          content: TextField(
            controller: quantiteController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Quantité"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantite = int.tryParse(quantiteController.text);
                if (quantite == null || quantite <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veuillez entrer une quantité valide.")),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('commandesPieces').add({
                    'pieceId': pieceId,
                    'nomPiece': nom,
                    'refPiece': ref,
                    'quantite': quantite,
                    'dateCommande': Timestamp.now(),
                    'etat': 'En attente',
                    'creePar': user.uid, // 🔐 Essentiel pour la règle Firestore
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Commande envoyée avec succès !")),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur lors de la commande: $e")),
                  );
                }
              },
              child: const Text("Commander"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text('Catalogue de pièces'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filtres par catégorie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tous', 'Moteur', 'Freins'].map((category) {
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedCategory = category),
                      selectedColor: Colors.green.shade800,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Liste dynamique
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('piecesStock').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucune pièce disponible."));
                }

                final pieces = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nom = data['nom']?.toLowerCase() ?? '';
                  final categorie = data['categorie'] ?? 'Tous';
                  final matchesQuery = nom.contains(searchQuery);
                  final matchesCategory = selectedCategory == 'Tous' || selectedCategory == categorie;
                  return matchesQuery && matchesCategory;
                }).toList();

                return ListView.builder(
                  itemCount: pieces.length,
                  itemBuilder: (context, index) {
                    final pieceDoc = pieces[index];
                    final piece = pieceDoc.data() as Map<String, dynamic>;
                    final pieceId = pieceDoc.id;

                    final nom = piece['nom'] ?? 'Nom inconnu';
                    final ref = piece['ref'] ?? 'Réf inconnue';
                    final description = piece['description'] ?? 'Inconnu';
                    final prix = (piece['prix'] as num?)?.toStringAsFixed(2) ?? '-';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.build, size: 36, color: Colors.green),
                            title: Text(nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Compatible: $description", style: TextStyle(color: Colors.grey.shade700)),
                            trailing: Text(
                              "$prix €",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                _showCommandeDialog(context, pieceId, nom, ref);
                              },
                              child: const Text('Commander', style: TextStyle(color: Colors.green)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Barre de navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Navigation à personnaliser
        },
        selectedItemColor: Colors.green.shade800,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Véhicules'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
