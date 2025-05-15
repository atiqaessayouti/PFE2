import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPiecePage extends StatefulWidget {
  final String pieceId;

  const EditPiecePage({Key? key, required this.pieceId}) : super(key: key);

  @override
  State<EditPiecePage> createState() => _EditPiecePageState();
}

class _EditPiecePageState extends State<EditPiecePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _refController = TextEditingController();
  final _prixController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPieceData();
  }

  Future<void> _loadPieceData() async {
    final doc = await FirebaseFirestore.instance.collection('piecesStock').doc(widget.pieceId).get();
    final data = doc.data();

    if (data != null) {
      _nomController.text = data['nom'] ?? '';
      _refController.text = data['ref'] ?? '';
      _prixController.text = (data['prix'] ?? 0).toString();
      _stockController.text = (data['stok'] ?? 0).toString();
      _descriptionController.text = data['description'] ?? '';
    }
  }

  Future<void> _updatePiece() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('piecesStock').doc(widget.pieceId).update({
          'nom': _nomController.text.trim(),
          'ref': _refController.text.trim(),
          'prix': double.parse(_prixController.text),
          'stok': int.parse(_stockController.text),
          'description': _descriptionController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Modifications enregistrées")),
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
        title: const Text('Modifier la pièce'),
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
                onPressed: _updatePiece,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
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
