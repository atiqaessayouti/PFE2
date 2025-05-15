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

  int totalVehicules = 0;
  int maintenancesPrevues = 0;
  int alertes = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserNames();
    _loadStats();
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

  Future<void> _loadStats() async {
    final vehiculesSnapshot = await FirebaseFirestore.instance.collection('vehicules').get();
    setState(() {
      totalVehicules = vehiculesSnapshot.docs.length;
      maintenancesPrevues = (totalVehicules * 0.5).round();
      alertes = (totalVehicules * 0.2).round();
    });
  }

  Color _getStatusColor(Map<String, dynamic> data) {
    final maintenancePrevue = data['maintenancePrevue'] as Timestamp?;
    if (maintenancePrevue != null) {
      final now = DateTime.now();
      final prevue = maintenancePrevue.toDate();
      if (prevue.isBefore(now)) return Colors.red[700]!;
      if (prevue.difference(now).inDays < 15) return Colors.orange[700]!;
    }
    return Colors.green[600]!;
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

  Color _getStatusTextColor(Map<String, dynamic> data) {
    final maintenancePrevue = data['maintenancePrevue'] as Timestamp?;
    if (maintenancePrevue != null) {
      final now = DateTime.now();
      final prevue = maintenancePrevue.toDate();
      if (prevue.isBefore(now)) return Colors.red[700]!;
      if (prevue.difference(now).inDays < 15) return Colors.orange[700]!;
    }
    return Colors.green[600]!;
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
      appBar: AppBar(
        title: const Text("Véhicules Clients", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: const Text("A", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(child: Text("VÉHICULES", style: TextStyle(fontWeight: FontWeight.bold))),
            Tab(child: Text("CLIENTS", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          indicator: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.redAccent, width: 2.0),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVehiculesTab(),
          const Center(child: Text("Vue Clients en développement")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVehiculesTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: "Rechercher un véhicule...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFFF1F3F4),
                child: IconButton(
                  icon: const Icon(Icons.sort, color: Color(0xFF78909C)),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFFF1F3F4),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: Color(0xFF78909C)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("VÉHICULES", totalVehicules.toString(), const Color(0xFFFFEBEE), Colors.red[800]!),
              _buildStatCard("MAINTENANCES", maintenancesPrevues.toString(), const Color(0xFFFFF3E0), Colors.deepOrange),
              _buildStatCard("ALERTES", alertes.toString(), const Color(0xFFFFEBEE), Colors.red),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: const Color(0xFFECEFF1),
          child: const Row(
            children: [
              Text("RÉCENTS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF37474F))),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vehicules').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || userNames.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final vehicules = snapshot.data!.docs.where((vehicule) {
                final data = vehicule.data() as Map<String, dynamic>;
                final marque = data['marque']?.toString().toLowerCase() ?? '';
                final modele = data['modele']?.toString().toLowerCase() ?? '';
                final immat = data['immatriculation']?.toString().toLowerCase() ?? '';
                return searchQuery.isEmpty || marque.contains(searchQuery) || modele.contains(searchQuery) || immat.contains(searchQuery);
              }).toList();

              if (vehicules.isEmpty) return const Center(child: Text("Aucun véhicule trouvé."));

              return ListView.builder(
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
                  final statusTextColor = _getStatusTextColor(data);
                  final emoji = _getVehicleEmoji(type);

                  return Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(width: 8, color: statusColor),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFFECEFF1),
                                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$marque $modele', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF37474F))),
                                        const SizedBox(height: 4),
                                        Text('Client: $nomClient', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                        const SizedBox(height: 4),
                                        Text(statusText, style: TextStyle(fontSize: 14, color: statusTextColor)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(immat, style: const TextStyle(fontSize: 14, color: Color(0xFF37474F))),
                                      const SizedBox(height: 10),
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red[700],
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.chevron_right, size: 16, color: Colors.white),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
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
    );
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }
}
