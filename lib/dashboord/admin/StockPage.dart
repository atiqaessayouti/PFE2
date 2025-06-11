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
  List<Map<String, dynamic>> _vehiculesClient = [];
  Map<String, dynamic>? _vehiculeSelectionne;

  // Couleurs du thème sombre dégradé
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryOrange = Color(0xFFFB8C00);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
    _loadUserRoleEtVehicules();
  }

  Future<void> _loadUserRoleEtVehicules() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _userRole = userDoc.data()?['role'];

      final vehiculesSnapshot = await FirebaseFirestore.instance
          .collection('vehicules')
          .where('userId', isEqualTo: user.uid)
          .get();

      _vehiculesClient = vehiculesSnapshot.docs.map((doc) => doc.data()).toList();

      if (_vehiculesClient.isNotEmpty) {
        _vehiculeSelectionne = _vehiculesClient.first;
      }

      setState(() {});
    }
  }

  void _changerVehicule(Map<String, dynamic> vehicule) {
    setState(() {
      _vehiculeSelectionne = vehicule;
    });
  }

  void _showCommandeDialog(BuildContext context, String pieceId, String nom, String ref, int stockDispo) {
    final TextEditingController _qteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, primaryRed],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shopping_cart, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Commander $nom',
                style: TextStyle(
                  color: textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryBlue.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _qteController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textLight),
            decoration: InputDecoration(
              labelText: 'Quantité',
              labelStyle: TextStyle(color: primaryOrange),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(Icons.confirmation_number, color: primaryOrange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              final int quantite = int.tryParse(_qteController.text) ?? 0;

              if (_userRole == 'Client' && quantite > 5) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Un client ne peut commander que 5 unités maximum.'),
                      ],
                    ),
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              if (quantite > 0 && quantite <= stockDispo) {
                await FirebaseFirestore.instance.collection('commandesPieces').add({
                  'pieceId': pieceId,
                  'nomPiece': nom,
                  'refPiece': ref,
                  'quantite': quantite,
                  'dateCommande': Timestamp.now(),
                  'etat': 'En attente',
                  'creePar': FirebaseAuth.instance.currentUser?.uid ?? 'anonyme',
                });

                await FirebaseFirestore.instance.collection('piecesStock').doc(pieceId).update({
                  'stok': FieldValue.increment(-quantite),
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Commande envoyée avec succès'),
                      ],
                    ),
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Quantité invalide ou stock insuffisant.'),
                      ],
                    ),
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Commander', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userRole == 'Admin';
    final isClient = _userRole == 'Client';

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryRed, primaryOrange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gestion du Stock',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryRed, primaryBlue],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // En-tête avec véhicule et recherche
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryGreen.withOpacity(0.1), Colors.transparent],
              ),
            ),
            child: Column(
              children: [
                if (_userRole == 'Client' && _vehiculesClient.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un véhicule',
                          labelStyle: TextStyle(color: primaryOrange, fontWeight: FontWeight.w600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.directions_car, color: primaryOrange),
                        ),
                        value: _vehiculeSelectionne,
                        dropdownColor: cardDark,
                        items: _vehiculesClient.map((vehicule) {
                          String label = '${vehicule['marque']} ${vehicule['modele']} (${vehicule['annee'] ?? ''})';
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: vehicule,
                            child: Text(label, style: TextStyle(color: textLight)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _changerVehicule(value);
                          }
                        },
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textLight),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: primaryOrange),
                      hintText: 'Rechercher une pièce...',
                      hintStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Liste des pièces
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('piecesStock').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement des pièces...',
                          style: TextStyle(color: textLight, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final allPieces = snapshot.data!.docs;
                final filteredPieces = allPieces.where((piece) {
                  final data = piece.data() as Map<String, dynamic>;
                  final nom = (data['nom'] ?? '').toString().toLowerCase();
                  final ref = (data['ref'] ?? '').toString().toLowerCase();
                  final marque = data['marque'] ?? '';
                  final modele = data['modele'] ?? '';
                  final annee = data['annee'] ?? '';

                  final matchesSearch = nom.contains(_searchText) || ref.contains(_searchText);

                  if (isClient) {
                    if (_vehiculeSelectionne == null) return false;
                    return matchesSearch &&
                        marque == _vehiculeSelectionne!['marque'] &&
                        modele == _vehiculeSelectionne!['modele'] &&
                        annee.toString() == _vehiculeSelectionne!['annee'].toString();
                  }

                  return matchesSearch;
                }).toList();

                if (filteredPieces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryRed, primaryOrange],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune pièce trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos critères de recherche',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredPieces.length,
                  itemBuilder: (context, index) {
                    final piece = filteredPieces[index];
                    final data = piece.data() as Map<String, dynamic>;

                    final nom = data['nom'] ?? 'Nom inconnu';
                    final ref = data['ref'] ?? 'N/A';
                    final prixClient = (data['prixClient'] ?? 0).toDouble();
                    final prixGaragiste = (data['prixGaragiste'] ?? 0).toDouble();
                    final stock = (data['stok'] ?? 0).toInt();
                    final imageUrl = data['imageUrl'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardDark, Color(0xFF252525)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Image de la pièce
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: primaryBlue.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/100',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: cardDark,
                                      child: Icon(
                                        Icons.broken_image,
                                        color: primaryOrange,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Informations de la pièce
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nom,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primaryBlue.withOpacity(0.2), primaryGreen.withOpacity(0.2)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Réf: $ref',
                                      style: TextStyle(
                                        color: primaryOrange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  if (isAdmin) ...[
                                    _buildInfoRow(Icons.person, 'Prix Client', '${prixClient.toStringAsFixed(2)} DH'),
                                    _buildInfoRow(Icons.build, 'Prix Garagiste', '${prixGaragiste.toStringAsFixed(2)} DH'),
                                    _buildInfoRow(Icons.inventory_2, 'Stock', '$stock unités',
                                        textColor: stock > 0 ? primaryGreen : primaryRed),
                                  ] else ...[
                                    _buildInfoRow(Icons.euro, 'Prix', '${prixClient.toStringAsFixed(2)} dh'),
                                  ],

                                  const SizedBox(height: 12),

                                  // Boutons d'action
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isAdmin)
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [primaryOrange, primaryRed],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: TextButton.icon(
                                            onPressed: () {
                                              Navigator.pushNamed(context, '/editPiece', arguments: piece.id);
                                            },
                                            icon: Icon(Icons.edit, color: Colors.white, size: 18),
                                            label: Text(
                                              'Modifier',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (!isAdmin)
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [primaryGreen, primaryBlue],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: TextButton.icon(
                                            onPressed: stock > 0 ? () {
                                              _showCommandeDialog(context, piece.id, nom, ref, stock);
                                            } : null,
                                            icon: Icon(
                                              stock > 0 ? Icons.shopping_cart : Icons.remove_shopping_cart,
                                              color: stock > 0 ? Colors.white : textSecondary,
                                              size: 18,
                                            ),
                                            label: Text(
                                              stock > 0 ? 'Commander' : 'Rupture',
                                              style: TextStyle(
                                                color: stock > 0 ? Colors.white : textSecondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            )
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
      floatingActionButton: isAdmin
          ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryOrange, primaryRed],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryRed.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.pushNamed(context, '/addPiece');
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Ajouter',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primaryOrange),
          const SizedBox(width: 6),
          Text(
            '$label : ',
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: textColor ?? textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}