import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String searchQuery = '';
  String selectedRole = 'Tous';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String newUserRole = 'Client';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des utilisateurs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => showAddUserDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: const InputDecoration(
                labelText: 'Rechercher par email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          DropdownButton<String>(
            value: selectedRole,
            onChanged: (value) => setState(() => selectedRole = value!),
            items: ['Tous', 'Admin', 'Client', 'Garagiste']
                .map((role) => DropdownMenuItem(
              value: role,
              child: Text(role),
            ))
                .toList(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text("Erreur de chargement");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final email = data['email']?.toLowerCase() ?? '';
                  final role = data['role'] ?? '';

                  return (searchQuery.isEmpty || email.contains(searchQuery.toLowerCase())) &&
                      (selectedRole == 'Tous' || role == selectedRole);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("Aucun utilisateur trouvé"));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user['email'] ?? 'Sans email'),
                      subtitle: Text("Rôle : ${user['role']}"),
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

  void showAddUserDialog() {
    emailController.clear();
    passwordController.clear();
    newUserRole = 'Client';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un utilisateur"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: newUserRole,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        newUserRole = value;
                      });
                    }
                  },
                  items: ['Client', 'Garagiste', 'Admin']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                await createUser();
                Navigator.pop(context);
              },
              child: const Text("Créer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> createUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': newUserRole,
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }
}
