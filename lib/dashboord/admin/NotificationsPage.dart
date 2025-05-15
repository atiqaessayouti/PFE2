import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedCategory = 'Toutes';
  late Stream<QuerySnapshot> _notificationsStream;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
  }

  Future<void> _checkIfAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final role = userDoc.data()?['role'] ?? '';
      setState(() {
        _isAdmin = role == 'Admin';
        _notificationsStream = _getNotificationsStream();
      });
    }
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    try {
      if (_isAdmin) {
        return _firestore
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots();
      } else {
        return _firestore
            .collection('notifications')
            .where('userId', isEqualTo: _auth.currentUser?.uid ?? '')
            .orderBy('timestamp', descending: true)
            .snapshots();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des notifications : $e');
      return const Stream.empty();
    }
  }

  Future<void> _markAsRead(String docId) async {
    try {
      await _firestore.collection('notifications').doc(docId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la mise à jour')),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date.isAfter(today)) {
      return 'Aujourd\'hui, ${DateFormat('HH:mm').format(date)}';
    } else if (date.isAfter(yesterday)) {
      return 'Hier, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy, HH:mm').format(date);
    }
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCategory == label,
        onSelected: (selected) =>
            setState(() => _selectedCategory = selected ? label : 'Toutes'),
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: _selectedCategory == label ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(DocumentSnapshot doc) {
    if (!doc.exists) return const SizedBox();

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final isRead = data['read'] ?? false;
    final timestamp = data['timestamp'] as Timestamp?;
    final userId = data['userId'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isRead ? Colors.white : Colors.blue[50],
      elevation: 0,
      child: InkWell(
        onTap: () {
          if (!isRead) _markAsRead(doc.id);
          // Navigation vers une autre page si nécessaire
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                _getIconForType(data['type'] ?? ''),
                color: Colors.blue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? '',
                      style: TextStyle(
                        fontWeight:
                        isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['message'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_isAdmin && userId == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Notification globale',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (timestamp != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatDate(timestamp.toDate()),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isRead)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: Colors.blue,
                  onPressed: () => _markAsRead(doc.id),
                  tooltip: 'Marquer comme lu',
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'stock':
        return Icons.inventory;
      case 'report':
        return Icons.assignment;
      case 'user':
        return Icons.person_add;
      case 'vehicle':
        return Icons.directions_car;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsPage(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildCategoryChip('Toutes'),
                _buildCategoryChip('Non lues'),
                _buildCategoryChip('Stock'),
                _buildCategoryChip('Rapports'),
                _buildCategoryChip('Utilisateurs'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aucune notification disponible'),
                  );
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // Filtrage pour les non-admins
                  if (!_isAdmin &&
                      data['userId'] != _auth.currentUser?.uid) {
                    return false;
                  }

                  switch (_selectedCategory) {
                    case 'Non lues':
                      return !(data['read'] ?? false);
                    case 'Stock':
                      return data['type'] == 'stock';
                    case 'Rapports':
                      return data['type'] == 'report';
                    case 'Utilisateurs':
                      return data['type'] == 'user';
                    default:
                      return true;
                  }
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune notification dans la catégorie "$_selectedCategory"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(filteredDocs[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de notification'),
      ),
      body: const Center(
        child: Text('Paramètres de notification à implémenter'),
      ),
    );
  }
}
