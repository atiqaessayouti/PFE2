import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AjouterVehiculePage extends StatefulWidget {
  @override
  _AjouterVehiculePageState createState() => _AjouterVehiculePageState();
}

class _AjouterVehiculePageState extends State<AjouterVehiculePage> {
  final _formKey = GlobalKey<FormState>();
  bool _success = false;
  String? _nouveauVehiculeNom;
  final primaryColor = Colors.green.shade700;
  final accentColor = Colors.green.shade400;

  String? _marque, _modele, _annee, _immatriculation;
  int? _kilometrage;

  final marques = ['Peugeot', 'Renault', 'Volkswagen', 'Prisqued', 'Rensat', 'Vision'];
  final modeles = ['308', 'Clio', 'Golf', '128', 'Ote', 'Prospect 512'];
  final annees = ['2020', '2021', '2022', '2023'];

  Future<void> _ajouterVehicule() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final vehiculeRef = FirebaseFirestore.instance.collection('vehicules').doc();

        await vehiculeRef.set({
          'vehiculeId': vehiculeRef.id,
          'marque': _marque,
          'modele': _modele,
          'annee': _annee,
          'immatriculation': _immatriculation,
          'kilometrage': _kilometrage,
          'userId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _success = true;
          _nouveauVehiculeNom = '$_marque $_modele';
        });

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return _buildSuccessView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un véhicule'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du véhicule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInfoRow('Marque', _buildMarqueDropdown()),
                  _buildInfoRow('Modèle', _buildModeleDropdown()),
                  _buildInfoRow('Année', _buildAnneeDropdown()),
                  _buildInfoRow('Immatriculation', _buildImmatriculationField()),
                  _buildInfoRow('Kilométrage initial', _buildKilometrageField()),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _ajouterVehicule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ajouter ce véhicule',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Véhicule ajouté'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: primaryColor, size: 80),
            const SizedBox(height: 20),
            Text(
              'Véhicule ajouté avec succès',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_nouveauVehiculeNom a été ajouté à votre liste de véhicules.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retour à la liste'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: field,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarqueDropdown() {
    return DropdownButtonFormField<String>(
      items: marques.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
      onChanged: (val) => _marque = val,
      decoration: const InputDecoration(border: InputBorder.none),
      validator: (val) => val == null ? 'Choisissez une marque' : null,
    );
  }

  Widget _buildModeleDropdown() {
    return DropdownButtonFormField<String>(
      items: modeles.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
      onChanged: (val) => _modele = val,
      decoration: const InputDecoration(border: InputBorder.none),
      validator: (val) => val == null ? 'Choisissez un modèle' : null,
    );
  }

  Widget _buildAnneeDropdown() {
    return DropdownButtonFormField<String>(
      items: annees.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
      onChanged: (val) => _annee = val,
      decoration: const InputDecoration(border: InputBorder.none),
      validator: (val) => val == null ? 'Choisissez une année' : null,
    );
  }

  Widget _buildImmatriculationField() {
    return TextFormField(
      onSaved: (val) => _immatriculation = val,
      validator: (val) => val!.isEmpty ? 'Entrez une immatriculation' : null,
      decoration: const InputDecoration(border: InputBorder.none),
    );
  }

  Widget _buildKilometrageField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      onSaved: (val) => _kilometrage = int.tryParse(val ?? '0'),
      validator: (val) => val!.isEmpty ? 'Entrez le kilométrage' : null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: '5000',
      ),
    );
  }

  Widget _buildVehiculeCard(String nom, String immatriculation, String details) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nom,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(immatriculation),
            Text(details),
          ],
        ),
      ),
    );
  }
}