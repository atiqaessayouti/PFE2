import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AjouterEntretienPage extends StatefulWidget {
  const AjouterEntretienPage({Key? key}) : super(key: key);

  @override
  State<AjouterEntretienPage> createState() => _AjouterEntretienPageState();
}

class _AjouterEntretienPageState extends State<AjouterEntretienPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehiculeController = TextEditingController();
  final _clientController = TextEditingController();
  final _serviceController = TextEditingController();
  final _heureController = TextEditingController();
  DateTime? _selectedDate;

  void _ajouterEntretien() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final dateStr =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

      await FirebaseFirestore.instance.collection('entretiens').add({
        'vehicule': _vehiculeController.text.trim(),
        'client': _clientController.text.trim(),
        'service': _serviceController.text.trim(),
        'heure': _heureController.text.trim(),
        'date': dateStr,
        'statut': 'À venir',
        'userId': user.uid,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Ajouter un entretien"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField(_vehiculeController, "Véhicule"),
                  _buildTextField(_clientController, "Client"),
                  _buildTextField(_serviceController, "Service"),
                  _buildTextField(_heureController, "Heure (ex: 09:00 - 10:00)"),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: Colors.orange[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(
                      _selectedDate == null
                          ? "Sélectionner une date"
                          : "Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    ),
                    trailing: const Icon(Icons.calendar_today, color: Colors.deepOrange),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _ajouterEntretien,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Ajouter", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.orange[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value!.isEmpty ? "Champ requis" : null,
      ),
    );
  }
}
