import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPiecePage extends StatefulWidget {
  const AddPiecePage({Key? key}) : super(key: key);

  @override
  State<AddPiecePage> createState() => _AddPiecePageState();
}

class _AddPiecePageState extends State<AddPiecePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  final TextEditingController _prixClientController = TextEditingController();
  final TextEditingController _prixGaragisteController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImage;
  bool _isUploading = false;

  // Mapping marques -> modèles compatibles
  final Map<String, List<String>> marqueModeles = {
    'Peugeot': ['308', '208', '2008', '207'],
    'Renault': ['Clio',],

    'Toyota': ['Corolla', 'Yaris'],
    'Dacia': ['Sandero', 'Duster', 'Spring'],
    'BMW': ['Serie 1', 'Serie 3',],
    'Mercedes': ['Classe A', 'Classe C', 'Classe E'],

  };

  final List<String> annees = ['2020', '2021', '2022', '2023'];

  List<String> selectedMarques = [];
  List<String> selectedModeles = [];
  List<String> selectedAnnees = [];

  // Couleurs du thème sombre dégradé vert-bleu
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);

  // Getter pour obtenir toutes les marques
  List<String> get allMarques => marqueModeles.keys.toList();

  // Getter pour obtenir tous les modèles
  List<String> get allModeles {
    Set<String> modeles = {};
    marqueModeles.values.forEach((list) => modeles.addAll(list));
    return modeles.toList();
  }

  // Getter pour obtenir les modèles filtrés selon les marques sélectionnées
  List<String> get filteredModeles {
    if (selectedMarques.isEmpty) {
      return allModeles;
    }

    Set<String> compatibleModeles = {};
    for (String marque in selectedMarques) {
      if (marqueModeles.containsKey(marque)) {
        compatibleModeles.addAll(marqueModeles[marque]!);
      }
    }
    return compatibleModeles.toList();
  }

  // Getter pour obtenir les marques filtrées selon les modèles sélectionnés
  List<String> get filteredMarques {
    if (selectedModeles.isEmpty) {
      return allMarques;
    }

    List<String> compatibleMarques = [];
    for (String marque in allMarques) {
      if (marqueModeles[marque]!.any((modele) => selectedModeles.contains(modele))) {
        compatibleMarques.add(marque);
      }
    }
    return compatibleMarques;
  }

  // Fonction pour nettoyer les sélections incompatibles
  void _cleanIncompatibleSelections() {
    // Nettoyer les modèles qui ne sont plus compatibles avec les marques sélectionnées
    if (selectedMarques.isNotEmpty) {
      selectedModeles.removeWhere((modele) => !filteredModeles.contains(modele));
    }

    // Nettoyer les marques qui ne sont plus compatibles avec les modèles sélectionnés
    if (selectedModeles.isNotEmpty) {
      selectedMarques.removeWhere((marque) => !filteredMarques.contains(marque));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = File(pickedFile.path);
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'diffc9et3';
    const uploadPreset = 'unsigned_preset';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    if (kIsWeb && _webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('file', _webImage!, filename: 'upload.jpg'));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      return data['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> _addPiece() async {
    if (_formKey.currentState!.validate()) {
      if (selectedMarques.isEmpty || selectedModeles.isEmpty || selectedAnnees.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Veuillez sélectionner marque, modèle et année'),
          backgroundColor: primaryBlue,
        ));
        return;
      }

      setState(() => _isUploading = true);

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
        if (imageUrl == null) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ Échec de l\'upload de l\'image'),
              backgroundColor: Colors.red[400],
            ),
          );
          return;
        }
      }

      try {
        await FirebaseFirestore.instance.collection('piecesStock').add({
          'nom': _nomController.text.trim(),
          'ref': _refController.text.trim(),
          'prixClient': double.tryParse(_prixClientController.text.trim()) ?? 0,
          'prixGaragiste': double.tryParse(_prixGaragisteController.text.trim()) ?? 0,
          'stok': int.tryParse(_stockController.text.trim()) ?? 0,
          'description': _descriptionController.text.trim(),
          'categorie': _categorieController.text.trim(),
          'imageUrl': imageUrl ?? '',
          'createdAt': Timestamp.now(),
          'marques': selectedMarques,
          'modeles': selectedModeles,
          'annees': selectedAnnees,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Pièce ajoutée avec succès'),
            backgroundColor: primaryGreen,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildMarqueSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Marques compatibles', style: TextStyle(fontWeight: FontWeight.bold, color: textLight)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: filteredMarques.map((marque) {
            final isSelected = selectedMarques.contains(marque);
            final isFiltered = selectedModeles.isNotEmpty && !filteredMarques.contains(marque);

            return FilterChip(
              label: Text(
                marque,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isFiltered ? textSecondary : textLight),
                ),
              ),
              selected: isSelected,
              onSelected: isFiltered ? null : (selected) {
                setState(() {
                  if (selected) {
                    selectedMarques.add(marque);
                  } else {
                    selectedMarques.remove(marque);
                  }
                  _cleanIncompatibleSelections();
                });
              },
              backgroundColor: isFiltered ? cardDark.withOpacity(0.5) : cardDark,
              selectedColor: primaryBlue,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isFiltered ? Colors.grey.shade800 : Colors.grey.shade700,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildModeleSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Modèles compatibles', style: TextStyle(fontWeight: FontWeight.bold, color: textLight)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: filteredModeles.map((modele) {
            final isSelected = selectedModeles.contains(modele);
            final isFiltered = selectedMarques.isNotEmpty && !filteredModeles.contains(modele);

            return FilterChip(
              label: Text(
                modele,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isFiltered ? textSecondary : textLight),
                ),
              ),
              selected: isSelected,
              onSelected: isFiltered ? null : (selected) {
                setState(() {
                  if (selected) {
                    selectedModeles.add(modele);
                  } else {
                    selectedModeles.remove(modele);
                  }
                  _cleanIncompatibleSelections();
                });
              },
              backgroundColor: isFiltered ? cardDark.withOpacity(0.5) : cardDark,
              selectedColor: primaryBlue,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isFiltered ? Colors.grey.shade800 : Colors.grey.shade700,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMultiSelect<T>(String label, List<T> options, List<T> selectedList, void Function(List<T>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textLight)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selectedList.contains(option);
            return FilterChip(
              label: Text(
                option.toString(),
                style: TextStyle(color: isSelected ? Colors.white : textLight),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedList.add(option);
                  } else {
                    selectedList.remove(option);
                  }
                  onChanged(selectedList);
                });
              },
              backgroundColor: cardDark,
              selectedColor: primaryBlue,
              checkmarkColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade700),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text('Ajouter une pièce', style: TextStyle(color: textLight)),
        backgroundColor: cardDark,
        iconTheme: IconThemeData(color: textLight),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryGreen.withOpacity(0.3), primaryBlue.withOpacity(0.3)],
            ),
          ),
        ),
        actions: [
          if (selectedMarques.isNotEmpty || selectedModeles.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all, color: textLight),
              onPressed: () {
                setState(() {
                  selectedMarques.clear();
                  selectedModeles.clear();
                });
              },
              tooltip: 'Effacer toutes les sélections',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: cardDark,
                    border: Border.all(color: Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _webImage != null
                      ? Image.memory(_webImage!, fit: BoxFit.cover)
                      : (_selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: textSecondary, size: 40),
                        const SizedBox(height: 8),
                        Text('Choisir une image', style: TextStyle(color: textSecondary)),
                      ],
                    ),
                  )),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Nom de la pièce',
                  labelStyle: TextStyle(color: textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  filled: true,
                  fillColor: cardDark,
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez saisir un nom' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _refController,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Référence',
                  labelStyle: TextStyle(color: textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  filled: true,
                  fillColor: cardDark,
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez saisir une référence' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prixClientController,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Prix Client (DH)',
                  labelStyle: TextStyle(color: textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  filled: true,
                  fillColor: cardDark,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prixGaragisteController,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Prix Garagiste (DH)',
                  labelStyle: TextStyle(color: textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  filled: true,
                  fillColor: cardDark,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Stock initial',
                  labelStyle: TextStyle(color: textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  filled: true,
                  fillColor: cardDark,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categorieController,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  labelStyle: TextStyle(color: textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  filled: true,
                  fillColor: cardDark,
                ),
              ),
              const SizedBox(height: 12),

              // Sélection des marques avec filtrage
              _buildMarqueSelect(),

              // Sélection des modèles avec filtrage
              _buildModeleSelect(),

              // Sélection des années (pas de filtrage)
              _buildMultiSelect('Années compatibles', annees, selectedAnnees, (value) {
                selectedAnnees = value;
              }),

              const SizedBox(height: 24),
              _isUploading
                  ? CircularProgressIndicator(color: primaryBlue)
                  : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryGreen, primaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _addPiece,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ajouter la pièce',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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