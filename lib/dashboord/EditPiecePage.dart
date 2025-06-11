import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  final _prixClientController = TextEditingController();
  final _prixGaragisteController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categorieController = TextEditingController();

  bool _isLoading = true;
  bool _isUploading = false;
  String? _imageUrl;
  XFile? _pickedFile;

  List<Map<String, String>> _compatibilites = [];

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
      _prixClientController.text = (data['prixClient'] ?? 0).toString();
      _prixGaragisteController.text = (data['prixGaragiste'] ?? 0).toString();
      _stockController.text = (data['stok'] ?? 0).toString();
      _descriptionController.text = data['description'] ?? '';
      _categorieController.text = data['categorie'] ?? '';
      _imageUrl = data['imageUrl'];

      final List<dynamic>? compatData = data['compatibilites'];
      if (compatData != null) {
        _compatibilites = compatData
            .whereType<Map>()
            .map((item) => {
          'marque': (item['marque'] ?? '').toString(),
          'modele': (item['modele'] ?? '').toString(),
          'annee': (item['annee'] ?? '').toString(),
        })
            .toList();
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _pickedFile = picked);
    }
  }

  Future<String?> _uploadImageToCloudinary() async {
    if (_pickedFile == null) return _imageUrl;

    const cloudName = 'diffc9et3';
    const uploadPreset = 'unsigned_preset';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    try {
      if (kIsWeb) {
        final bytes = await _pickedFile!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: _pickedFile!.name));
      } else {
        final file = File(_pickedFile!.path);
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody.body);
        return data['secure_url'];
      } else {
        throw Exception('Échec de l\'upload Cloudinary');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur image : $e')));
      return null;
    }
  }

  Future<void> _updatePiece() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      final newImageUrl = await _uploadImageToCloudinary();
      setState(() => _isUploading = false);

      if (newImageUrl == null) return;

      try {
        await FirebaseFirestore.instance.collection('piecesStock').doc(widget.pieceId).update({
          'nom': _nomController.text.trim(),
          'ref': _refController.text.trim(),
          'prixClient': double.parse(_prixClientController.text.trim()),
          'prixGaragiste': double.parse(_prixGaragisteController.text.trim()),
          'stok': int.parse(_stockController.text.trim()),
          'description': _descriptionController.text.trim(),
          'imageUrl': newImageUrl,
          'categorie': _categorieController.text.trim(),
          'compatibilites': _compatibilites,
          'updatedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Pièce mise à jour avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? inputType,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: inputType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _pickedFile != null
                ? kIsWeb
                ? FutureBuilder<Uint8List>(
              future: _pickedFile!.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error, color: Colors.red);
                } else {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                }
              },
            )
                : Image.file(File(_pickedFile!.path), fit: BoxFit.cover)
                : _imageUrl != null
                ? Image.network(_imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 80, color: Colors.grey),
          ),
          const Positioned(bottom: 8, child: Icon(Icons.edit, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildCompatibilitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Compatibilité Véhicules", style: TextStyle(fontWeight: FontWeight.bold)),
        ..._compatibilites.asMap().entries.map((entry) {
          final index = entry.key;
          final compat = entry.value;

          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Marque'),
                  initialValue: compat['marque'],
                  onChanged: (value) => _compatibilites[index]['marque'] = value,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Modèle'),
                  initialValue: compat['modele'],
                  onChanged: (value) => _compatibilites[index]['modele'] = value,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Année'),
                  initialValue: compat['annee'],
                  onChanged: (value) => _compatibilites[index]['annee'] = value,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _compatibilites.removeAt(index)),
              )
            ],
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => setState(() {
            _compatibilites.add({'marque': '', 'modele': '', 'annee': ''});
          }),
          icon: const Icon(Icons.add),
          label: const Text("Ajouter une compatibilité"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _refController.dispose();
    _prixClientController.dispose();
    _prixGaragisteController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _categorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier la pièce'), backgroundColor: Colors.redAccent),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              if (_isUploading) const LinearProgressIndicator(),
              _buildTextField(
                label: 'Nom',
                controller: _nomController,
                validator: (value) => value!.isEmpty ? 'Nom requis' : null,
              ),
              _buildTextField(
                label: 'Référence',
                controller: _refController,
                validator: (value) => value!.isEmpty ? 'Référence requise' : null,
              ),
              _buildTextField(
                label: 'Prix Client (DH)',
                controller: _prixClientController,
                inputType: TextInputType.number,
                validator: (value) => double.tryParse(value ?? '') == null ? 'Prix invalide' : null,
              ),
              _buildTextField(
                label: 'Prix Garagiste (DH)',
                controller: _prixGaragisteController,
                inputType: TextInputType.number,
                validator: (value) => double.tryParse(value ?? '') == null ? 'Prix invalide' : null,
              ),
              _buildTextField(
                label: 'Stock',
                controller: _stockController,
                inputType: TextInputType.number,
                validator: (value) => int.tryParse(value ?? '') == null ? 'Stock invalide' : null,
              ),
              _buildTextField(label: 'Description', controller: _descriptionController, maxLines: 3),
              _buildTextField(label: 'Catégorie', controller: _categorieController),
              _buildCompatibilitesSection(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updatePiece,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
