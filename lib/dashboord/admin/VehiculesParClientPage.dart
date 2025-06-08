import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehiculesParClientPage extends StatefulWidget {
  const VehiculesParClientPage({super.key});

  @override
  State<VehiculesParClientPage> createState() => _VehiculesParClientPageState();
}

class _VehiculesParClientPageState extends State<VehiculesParClientPage>
    with SingleTickerProviderStateMixin {
  Map<String, String> userNames = {};
  String searchQuery = '';
  late TabController _tabController;

  // Palette de couleurs sombre avec dégradé rouge-orange-bleu-vert
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color cardDark = Color(0xFF3A3A3A);
  static const Color backgroundDark = Color(0xFF121212);

  // Couleurs du dégradé
  static const Color gradientRed = Color(0xFFFF6B6B);
  static const Color gradientOrange = Color(0xFFFFB347);
  static const Color gradientBlue = Color(0xFF4ECDC4);
  static const Color gradientGreen = Color(0xFF45B7D1);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserNames();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserNames() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, String> names = {};
    for (var doc in usersSnapshot.docs) {
      names[doc.id] = doc.data()['nom'] ?? 'Client inconnu';
    }
    setState(() {
      userNames = names;
    });
  }

  Color _getStatusColor(Map<String, dynamic> data) {
    final maintenancePrevue = data['maintenancePrevue'] as Timestamp?;
    if (maintenancePrevue != null) {
      final now = DateTime.now();
      final prevue = maintenancePrevue.toDate();
      if (prevue.isBefore(now)) return gradientRed;
      if (prevue.difference(now).inDays < 15) return gradientOrange;
    }
    return gradientGreen;
  }

  String _getStatusText(Map<String, dynamic> data) {
    final derniere = data['derniereMaintenance'] as Timestamp?;
    final prevue = data['maintenancePrevue'] as Timestamp?;
    final format = DateFormat('dd/MM/yyyy');
    if (prevue != null) {
      final now = DateTime.now();
      final date = prevue.toDate();
      if (date.isBefore(now)) return 'Maintenance requise';
      if (date.difference(now).inDays < 15) return 'Prévue: ${format.format(date)}';
    }
    if (derniere != null) return 'À jour - ${format.format(derniere.toDate())}';
    return 'Pas d\'historique';
  }

  String _getVehicleEmoji(String? type) {
    switch (type?.toLowerCase()) {
      case 'berline': return '🚗';
      case 'suv': return '🚙';
      case 'camionnette': return '🚐';
      case 'moto': return '🏍️';
      default: return '🚗';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: const Text(
          "Véhicules Clients",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientRed, gradientOrange, gradientBlue, gradientGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Text("A", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: gradientBlue.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: gradientBlue.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: const TextStyle(color: textPrimary),
                      onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Rechercher un véhicule...",
                        hintStyle: const TextStyle(color: textSecondary),
                        prefixIcon: const Icon(Icons.search, color: gradientBlue),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: textSecondary),
                          onPressed: () => setState(() => searchQuery = ''),
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade700),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: gradientBlue,
                    unselectedLabelColor: textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    indicator: UnderlineTabIndicator(
                      borderSide: const BorderSide(color: gradientBlue, width: 3),
                      insets: const EdgeInsets.symmetric(horizontal: 40),
                    ),
                    tabs: const [
                      Tab(text: "VÉHICULES"),
                      Tab(text: "CLIENTS"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVehiculesTab(),
          _buildClientsTab(),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [gradientRed, gradientOrange, gradientBlue, gradientGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientBlue.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildVehiculesTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [surfaceDark, backgroundDark],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          // En-tête de la liste avec dégradé
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gradientRed, gradientOrange, gradientBlue, gradientGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Véhicules récents",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Liste des véhicules
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vehicules').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || userNames.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(gradientBlue),
                    ),
                  );
                }

                final vehicules = snapshot.data!.docs.where((vehicule) {
                  final data = vehicule.data() as Map<String, dynamic>;
                  final marque = data['marque']?.toString().toLowerCase() ?? '';
                  final modele = data['modele']?.toString().toLowerCase() ?? '';
                  final immat = data['immatriculation']?.toString().toLowerCase() ?? '';
                  return searchQuery.isEmpty ||
                      marque.contains(searchQuery) ||
                      modele.contains(searchQuery) ||
                      immat.contains(searchQuery);
                }).toList();

                if (vehicules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardDark,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search_off_rounded, size: 48, color: textSecondary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Aucun véhicule trouvé",
                          style: TextStyle(
                            fontSize: 16,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Essayez avec d'autres termes de recherche",
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: vehicules.length,
                  itemBuilder: (context, index) {
                    final data = vehicules[index].data() as Map<String, dynamic>;
                    final userId = data['userId'] ?? 'inconnu';
                    final marque = data['marque'] ?? 'Inconnue';
                    final modele = data['modele'] ?? '';
                    final immat = data['immatriculation'] ?? 'N/A';
                    final type = data['type'] ?? '';
                    final nomClient = userNames[userId] ?? 'Client inconnu';
                    final statusColor = _getStatusColor(data);
                    final statusText = _getStatusText(data);
                    final emoji = _getVehicleEmoji(type);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardDark),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [gradientBlue.withOpacity(0.3), gradientGreen.withOpacity(0.3)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: gradientBlue.withOpacity(0.5)),
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$marque $modele',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline_rounded,
                                          size: 16,
                                          color: textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          nomClient,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor.withOpacity(0.5)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: statusColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [gradientBlue.withOpacity(0.3), gradientGreen.withOpacity(0.3)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      immat,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: cardDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildClientsTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [surfaceDark, backgroundDark],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientRed, gradientOrange, gradientBlue, gradientGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientBlue.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Section Clients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cette fonctionnalité sera bientôt disponible",
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientOrange, gradientBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradientOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                label: const Text("M'avertir", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}