import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailsPage({Key? key, required this.userData}) : super(key: key);

  // Helper method to safely format date
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Non renseigné';

    try {
      DateTime dateTime;

      if (dateValue is Timestamp) {
        dateTime = dateValue.toDate();
      } else if (dateValue is DateTime) {
        dateTime = dateValue;
      } else if (dateValue is String) {
        dateTime = DateTime.parse(dateValue);
      } else {
        return 'Format inconnu';
      }

      // Format the date nicely
      return DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Date invalide';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}'.trim();
    final email = userData['email'] ?? 'Inconnu';
    final phone = userData['telephone']?.toString() ?? 'Non renseigné';
    final role = userData['role'] ?? 'Inconnu';

    // Safely format the createdAt date
    final createdAt = _formatDate(userData['createdAt']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'utilisateur'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    backgroundImage: userData['profilePicture'] != null
                        ? NetworkImage(userData['profilePicture'])
                        : null,
                    child: userData['profilePicture'] == null
                        ? Icon(
                      _getIconForRole(role),
                      color: Colors.redAccent,
                      size: 32,
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Nom complet', fullName),
                _buildDetailRow('Email', email),
                _buildDetailRow('Téléphone', phone),
                _buildDetailRow('Rôle', role),
                _buildDetailRow('Date de création', createdAt),

                // Add notification preferences if they exist
                if (userData['notificationPreferences'] != null) ...[
                  const SizedBox(height: 16),
                  const Text('Préférences de notification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  _buildNotificationPreferences(userData['notificationPreferences']),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to edit page or show edit dialog
          _showEditDialog(context);
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.edit),
      ),
    );
  }

  IconData _getIconForRole(String role) {
    switch (role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Garagiste':
        return Icons.build;
      case 'Client':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 10),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferences(Map<String, dynamic> preferences) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: preferences.entries.map((entry) {
        final bool isEnabled = entry.value == true;
        final String prefName = _getReadablePrefName(entry.key);

        return ListTile(
          title: Text(prefName),
          trailing: Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.red,
          ),
          dense: true,
        );
      }).toList(),
    );
  }

  String _getReadablePrefName(String prefKey) {
    switch (prefKey) {
      case 'maintenanceReminders':
        return 'Rappels de maintenance';
      case 'orderUpdates':
        return 'Mises à jour des commandes';
      case 'stockAlerts':
        return 'Alertes de stock';
      case 'vehicleReminders':
        return 'Rappels véhicule';
      default:
        return prefKey;
    }
  }

  void _showEditDialog(BuildContext context) {
    // This is a placeholder for showing an edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier les informations'),
        content: const Text('Fonctionnalité à venir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}