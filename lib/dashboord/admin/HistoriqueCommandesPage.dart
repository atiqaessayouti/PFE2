import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoriqueCommandesAdminPage extends StatefulWidget {
  const HistoriqueCommandesAdminPage({Key? key}) : super(key: key);

  @override
  State<HistoriqueCommandesAdminPage> createState() => _HistoriqueCommandesAdminPageState();
}

class _HistoriqueCommandesAdminPageState extends State<HistoriqueCommandesAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> _userInfoCache = {};
  String _filtreEtat = 'Tous';
  String _searchQuery = '';

  // Palette de couleurs bleues modernisée
  final Color _primaryColor = const Color(0xFF1E40AF);      // Bleu profond
  final Color _secondaryColor = const Color(0xFF3B82F6);    // Bleu vif
  final Color _accentColor = const Color(0xFF60A5FA);       // Bleu clair
  final Color _surfaceColor = const Color(0xFFF8FAFC);      // Gris très clair
  final Color _cardColor = const Color(0xFFFFFFFF);         // Blanc pur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilterChip(),
          const SizedBox(height: 16),
          Expanded(child: _buildCommandesList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Historique des Commandes",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: _primaryColor,
      elevation: 0,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryColor, _secondaryColor],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtrer',
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _secondaryColor],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Commandes',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Suivez et gérez toutes les commandes',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher par nom ou référence...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search_rounded, color: _secondaryColor, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_secondaryColor.withOpacity(0.1), _accentColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: _secondaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list_rounded, size: 18, color: _secondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Filtre: $_filtreEtat',
                  style: TextStyle(
                    color: _secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filtreEtat == 'Tous' ? 'Toutes les' : 'Les'} commandes',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('commandesPieces')
          .orderBy('dateCommande', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _secondaryColor, strokeWidth: 3),
                const SizedBox(height: 16),
                Text(
                  'Chargement...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final commandes = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final etat = (data['etat'] ?? '').toString().toLowerCase();
          final nom = (data['nomPiece'] ?? '').toString().toLowerCase();
          final ref = (data['refPiece'] ?? '').toString().toLowerCase();

          final filtreEtatOK = _filtreEtat == 'Tous' || etat == _filtreEtat.toLowerCase();
          final filtreTexteOK = _searchQuery.isEmpty ||
              nom.contains(_searchQuery) ||
              ref.contains(_searchQuery);

          return filtreEtatOK && filtreTexteOK;
        }).toList();

        if (commandes.isEmpty) {
          return _buildEmptyFilterState();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: commandes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildCommandeCard(commandes[index]),
        );
      },
    );
  }

  Widget _buildCommandeCard(QueryDocumentSnapshot commande) {
    final data = commande.data() as Map<String, dynamic>;
    final uid = data['creePar'] ?? '';
    final dateCommande = (data['dateCommande'] as Timestamp).toDate();
    final dateTraitement = data['dateTraitement'] != null
        ? (data['dateTraitement'] as Timestamp).toDate()
        : null;
    final etat = data['etat'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data['nomPiece'] ?? 'Pièce sans nom',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(etat),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.tag_rounded,
                "Réf: ${data['refPiece'] ?? 'N/A'}",
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.inventory_2_rounded,
                "Quantité: ${data['quantite'] ?? 1}",
              ),
              const SizedBox(height: 12),
              FutureBuilder<String>(
                future: _getUserInfo(uid),
                builder: (context, snapshot) {
                  final nomUser = snapshot.data ?? 'Utilisateur';
                  return _buildInfoRow(
                    Icons.person_rounded,
                    "Client: $nomUser",
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.schedule_rounded,
                "Commande: ${_formatDate(dateCommande)}",
              ),
              if (dateTraitement != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.check_circle_rounded,
                  "Traitée: ${_formatDate(dateTraitement)}",
                ),
              ],
              const SizedBox(height: 20),
              if (etat == 'En attente')
                _buildActionButton(
                  "Valider la commande",
                  Icons.check_rounded,
                  const Color(0xFF059669),
                      () => _updateEtatCommande(commande.id, 'Traité'),
                ),
              if (etat == 'Traité')
                _buildActionButton(
                  "Marquer comme envoyée",
                  Icons.local_shipping_rounded,
                  _secondaryColor,
                      () => _updateEtatCommande(commande.id, 'Envoyé'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String etat) {
    final color = _getColorForEtat(etat);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            etat.isNotEmpty ? etat : 'Inconnu',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _secondaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 20, color: Colors.white),
          label: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_rounded,
              size: 60,
              color: _secondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Aucune commande trouvée",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Les commandes apparaîtront ici une fois créées",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Colors.orange[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Aucune commande correspondante",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Modifiez vos critères de recherche",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_secondaryColor, _accentColor],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _secondaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                "Réinitialiser les filtres",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onPressed: () => setState(() {
                _filtreEtat = 'Tous';
                _searchQuery = '';
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Filtrer par état",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption("Toutes les commandes", 'Tous'),
            _buildRadioOption("En attente", 'En attente'),
            _buildRadioOption("Traitées", 'Traité'),
            _buildRadioOption("Envoyées", 'Envoyé'),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _filtreEtat = result);
    }
  }

  Widget _buildRadioOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      value: value,
      groupValue: _filtreEtat,
      activeColor: _secondaryColor,
      onChanged: (value) => Navigator.pop(context, value),
    );
  }

  Future<String> _getUserInfo(String uid) async {
    if (_userInfoCache.containsKey(uid)) return _userInfoCache[uid]!;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      final nom = data?['nom'] ?? 'Utilisateur inconnu';
      _userInfoCache[uid] = nom;
      return nom;
    } catch (_) {
      return 'Utilisateur inconnu';
    }
  }

  Color _getColorForEtat(String? etat) {
    switch (etat?.toLowerCase()) {
      case 'en attente':
        return const Color(0xFFD97706); // Orange
      case 'traité':
        return const Color(0xFF059669); // Vert
      case 'envoyé':
        return const Color(0xFF3B82F6); // Bleu
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  Future<void> _updateEtatCommande(String docId, String nouvelEtat) async {
    try {
      final updateData = {
        'etat': nouvelEtat,
        if (nouvelEtat == 'Traité') 'dateTraitement': FieldValue.serverTimestamp(),
        if (nouvelEtat == 'Envoyé') 'dateEnvoi': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('commandesPieces').doc(docId).update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text("Commande marquée comme $nouvelEtat"),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Text("Erreur lors de la mise à jour"),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}