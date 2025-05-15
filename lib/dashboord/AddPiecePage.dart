import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPiecePage extends StatefulWidget {
  const AddPiecePage({Key? key}) : super(key: key);

  @override
  State<AddPiecePage> createState() => _AddPiecePageState();
}

class _AddPiecePageState extends State<AddPiecePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _refController = TextEditingController();
  final _prixController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _ajouterPiece() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('piecesStock').add({
          'nom': _nomController.text.trim(),
          'ref': _refController.text.trim(),
          'prix': double.parse(_prixController.text),
          'stok': int.parse(_stockController.text),
          'description': _descriptionController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Pièce ajoutée avec succès")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une pièce'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nomController, 'Nom de la pièce'),
              _buildTextField(_refController, 'Référence'),
              _buildTextField(_prixController, 'Prix (€)', type: TextInputType.number),
              _buildTextField(_stockController, 'Quantité en stock', type: TextInputType.number),
              _buildTextField(_descriptionController, 'Description', maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _ajouterPiece,
                icon: const Icon(Icons.save),
                label: const Text('Ajouter la pièce'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
