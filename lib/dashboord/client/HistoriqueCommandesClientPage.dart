import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoriqueCommandesClientPage extends StatefulWidget {
  const HistoriqueCommandesClientPage({super.key});

  @override
  State<HistoriqueCommandesClientPage> createState() => _HistoriqueCommandesClientPageState();
}

class _HistoriqueCommandesClientPageState extends State<HistoriqueCommandesClientPage>
    with TickerProviderStateMixin {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Palette de couleurs cohérente avec le dashboard
  final primaryColor = Color(0xFF0D7377);
  final accentColor = Color(0xFF14A085);
  final backgroundColor = Color(0xFF0A0E27);
  final cardColor = Color(0xFF1B1B2F);
  final surfaceColor = Color(0xFF162447);
  final textColor = Colors.white;
  final secondaryTextColor = Color(0xFF94A3B8);
  final gradientColors = [Color(0xFF14A085), Color(0xFF0D7377)];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              surfaceColor.withOpacity(0.8),
              backgroundColor,
              Color(0xFF0F0F1E),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('commandesPieces')
                  .where('creePar', isEqualTo: uid)
                  .orderBy('dateCommande', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                final commandes = snapshot.data!.docs;

                if (commandes.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildCommandesList(commandes);
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors,
        ).createShader(bounds),
        child: Text(
          'Mes Commandes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Chargement de vos commandes...",
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Erreur lors du chargement",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Vérifiez votre connexion internet",
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors.map((c) => c.withOpacity(0.2)).toList(),
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: accentColor,
              size: 64,
            ),
          ),
          SizedBox(height: 32),
          Text(
            "Aucune commande",
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Vous n'avez pas encore passé de commandes.\nCommencez par explorer notre catalogue !",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandesList(List<QueryDocumentSnapshot> commandes) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${commandes.length} commande${commandes.length > 1 ? 's' : ''}",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final commande = commandes[index] as QueryDocumentSnapshot<Map<String, dynamic>>;
                return _buildCommandeCard(commande, index);
              },
              childCount: commandes.length,
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildCommandeCard(QueryDocumentSnapshot<Map<String, dynamic>> commande, int index) {
    final data = commande.data();
    final date = (data['dateCommande'] as Timestamp).toDate();
    final etat = data['etat'] ?? 'Inconnu';
    final nomPiece = data['nomPiece'] ?? 'Pièce inconnue';
    final quantite = data['quantite'] ?? 1;
    final refPiece = data['refPiece'] ?? 'N/A';

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: surfaceColor.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradientColors),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomPiece,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Quantité: $quantite",
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildEtatBadge(etat),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.numbers,
                                label: "Référence",
                                value: refPiece,
                              ),
                              SizedBox(height: 8),
                              _buildInfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: "Date de commande",
                                value: "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
                              ),
                            ],
                          ),
                        ),
                        if (etat.toLowerCase() == 'envoyé') ...[
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _confirmerReception(context, commande.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ).copyWith(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: gradientColors),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Marquer comme reçu",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 16),
        SizedBox(width: 12),
        Text(
          "$label:",
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 14,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEtatBadge(String etat) {
    final colors = _getEtatColors(etat);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEtatIcon(etat),
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 6),
          Text(
            _getEtatLabel(etat),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getEtatColors(String etat) {
    switch (etat.toLowerCase()) {
      case 'en attente':
        return [Color(0xFFFF9800), Color(0xFFFF5722)];
      case 'traité':
        return [Color(0xFF2196F3), Color(0xFF1976D2)];
      case 'envoyé':
        return [Color(0xFF9C27B0), Color(0xFF673AB7)];
      case 'reçu':
        return [Color(0xFF4CAF50), Color(0xFF388E3C)];
      default:
        return [Color(0xFF9E9E9E), Color(0xFF616161)];
    }
  }

  IconData _getEtatIcon(String etat) {
    switch (etat.toLowerCase()) {
      case 'en attente':
        return Icons.access_time;
      case 'traité':
        return Icons.settings;
      case 'envoyé':
        return Icons.local_shipping;
      case 'reçu':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getEtatLabel(String etat) {
    switch (etat.toLowerCase()) {
      case 'en attente':
        return 'En attente';
      case 'traité':
        return 'Traitée';
      case 'envoyé':
        return 'Envoyée';
      case 'reçu':
        return 'Reçue';
      default:
        return etat;
    }
  }

  void _confirmerReception(BuildContext context, String docId) async {
    // Animation du bouton
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
                SizedBox(height: 16),
                Text(
                  "Confirmation en cours...",
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await FirebaseFirestore.instance
          .collection('commandesPieces')
          .doc(docId)
          .update({
        'etat': 'Reçu',
        'dateReception': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Ferme le dialog de chargement

      // Snackbar de succès avec style
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Commande marquée comme reçue"),
            ],
          ),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Ferme le dialog de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text("Erreur: ${e.toString()}")),
            ],
          ),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }
}