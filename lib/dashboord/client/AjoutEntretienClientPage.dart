import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AjouterEntretienClientPage extends StatefulWidget {
  const AjouterEntretienClientPage({Key? key}) : super(key: key);

  @override
  State<AjouterEntretienClientPage> createState() => _AjouterEntretienClientPageState();
}

class _AjouterEntretienClientPageState extends State<AjouterEntretienClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _heureController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedVehicule;
  List<Map<String, dynamic>> _vehicules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicules();
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _heureController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicules() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('vehicules')
            .where('userId', isEqualTo: user.uid)
            .get();

        final vehiculesList = snapshot.docs.map((doc) => {
          'id': doc.id,
          'nom': doc['marque'], // Remplace 'nom' par 'marque'
          'immatriculation': doc['immatriculation'] ?? '',
        }).toList();

        setState(() {
          _vehicules = vehiculesList;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur d'authentification")),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _planifierEntretien() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedVehicule == null) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final vehiculeDetail = _vehicules.firstWhere((v) => v['id'] == _selectedVehicule);

      await FirebaseFirestore.instance.collection('entretiens').add({
        'vehicule': "${vehiculeDetail['nom']} - ${vehiculeDetail['immatriculation']}",
        'vehiculeId': vehiculeDetail['id'],
        'client': user!.email,
        'clientId': user.uid,
        'userId': user.uid,  // Ajout du champ userId
        'service': _serviceController.text.trim(),
        'heure': _heureController.text.trim(),
        'date': "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
        'statut': 'À venir',
        'dateCréation': FieldValue.serverTimestamp(),
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entretien planifié avec succès")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planifier un entretien"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_vehicules.isEmpty)
                Card(
                  color: Colors.amber[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Vous n'avez aucun véhicule enregistré",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Ajouter navigation vers AjouterVehiculePage
                          },
                          child: const Text("Ajouter un véhicule"),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_vehicules.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedVehicule,
                  onChanged: (val) => setState(() => _selectedVehicule = val),
                  items: _vehicules.map((v) {
                    return DropdownMenuItem<String>(
                      value: v['id'],
                      child: Text(
                        "${v['nom']} - ${v['immatriculation']}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: "Sélectionnez un véhicule",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.directions_car),
                  ),
                  validator: (value) =>
                  value == null ? "Veuillez choisir un véhicule" : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serviceController,
                decoration: InputDecoration(
                  labelText: "Service souhaité",
                  hintText: "Ex: Vidange, Révision, Changement de pneus...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.build),
                ),
                validator: (value) => value!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heureController,
                decoration: InputDecoration(
                  labelText: "Heure souhaitée",
                  hintText: "Ex: 09:00 - 10:00",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.access_time),
                ),
                validator: (value) => value!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Date souhaitée",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? "Sélectionner une date"
                        : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _vehicules.isEmpty ? null : _planifierEntretien,
                icon: const Icon(Icons.schedule),
                label: const Text("Planifier l'entretien"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
