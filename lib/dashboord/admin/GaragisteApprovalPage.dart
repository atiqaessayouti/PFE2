import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GaragisteApprovalPage extends StatelessWidget {
  const GaragisteApprovalPage({super.key});

  Future<void> approveGaragiste(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isApproved': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validation des Garagistes'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Garagiste')
            .where('isApproved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final garagistes = snapshot.data?.docs ?? [];

          if (garagistes.isEmpty) {
            return Center(child: Text('Aucun garagiste à valider.'));
          }

          return ListView.builder(
            itemCount: garagistes.length,
            itemBuilder: (context, index) {
              final doc = garagistes[index];
              final prenom = doc['prenom'] ?? '';
              final nom = doc['nom'] ?? '';
              final email = doc['email'] ?? '';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text('$prenom $nom'),
                  subtitle: Text(email),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await approveGaragiste(doc.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Garagiste approuvé')),
                      );
                    },
                    child: Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
