import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userRole = userDoc.data()?['role'];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCommandeDialog(BuildContext context, String pieceId, String nom, String ref) {
    final TextEditingController _qteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Commander $nom'),
        content: TextField(
          controller: _qteController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantité'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final int quantite = int.tryParse(_qteController.text) ?? 0;
              if (quantite > 0) {
                await FirebaseFirestore.instance.collection('commandesPieces').add({
                  'pieceId': pieceId,
                  'nomPiece': nom,
                  'refPiece': ref,
                  'quantite': quantite,
                  'dateCommande': Timestamp.now(),
                  'etat': 'En attente',
                  'creePar': FirebaseAuth.instance.currentUser?.uid ?? 'anonyme',
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Commande créée avec succès')),
                );
              }
            },
            child: const Text('Commander'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == 'Admin';
    final isClientOrGaragiste = _userRole == 'Client' || _userRole == 'Garagiste';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du Stock'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/historiqueCommandes');
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher une pièce...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (isAdmin)
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/addPiece');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('+ Ajouter une pièce'),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('piecesStock').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final allPieces = snapshot.data!.docs;
                final filteredPieces = allPieces.where((piece) {
                  final data = piece.data() as Map<String, dynamic>;
                  final nom = (data['nom'] ?? '').toString().toLowerCase();
                  final ref = (data['ref'] ?? '').toString().toLowerCase();
                  return nom.contains(_searchText) || ref.contains(_searchText);
                }).toList();

                return ListView.builder(
                  itemCount: filteredPieces.length,
                  itemBuilder: (context, index) {
                    var piece = filteredPieces[index];
                    final data = piece.data() as Map<String, dynamic>;

                    String nom = data['nom'] ?? 'Nom inconnu';
                    String ref = data['ref'] ?? 'N/A';
                    double prix = 0;
                    int stock = 0;

                    try {
                      prix = (data['prix'] is int)
                          ? (data['prix'] as int).toDouble()
                          : (data['prix'] as double);
                      stock = (data['stok'] ?? 0 as num).toInt();
                    } catch (e) {
                      debugPrint('Erreur de parsing : $e');
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Réf: $ref'),
                            Text('Prix: ${prix.toStringAsFixed(2)} €'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: stock <= 5 ? Colors.orange[100] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    stock <= 5
                                        ? 'Stock bas: $stock unités'
                                        : 'En stock: $stock unités',
                                    style: TextStyle(
                                      color: stock <= 5 ? Colors.orange[800] : Colors.green[800],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isAdmin)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/editPiece', arguments: piece.id);
                                    },
                                    child: const Text('Modifier'),
                                  ),
                                if (isClientOrGaragiste)
                                  TextButton(
                                    onPressed: () {
                                      _showCommandeDialog(context, piece.id, nom, ref);
                                    },
                                    child: const Text('Commander', style: TextStyle(color: Colors.red)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
