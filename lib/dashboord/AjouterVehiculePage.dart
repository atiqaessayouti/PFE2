import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AjouterVehiculePage extends StatefulWidget {
  @override
  _AjouterVehiculePageState createState() => _AjouterVehiculePageState();
}

class _AjouterVehiculePageState extends State<AjouterVehiculePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _success = false;
  bool _isLoading = false;
  String? _nouveauVehiculeNom;

  // Couleurs thème sombre bleu-vert
  final primaryColor = const Color(0xFF00796B);
  final accentColor = const Color(0xFF26C6DA);
  final secondaryColor = const Color(0xFF0277BD);
  final backgroundColor = const Color(0xFF121212);
  final surfaceColor = const Color(0xFF1E1E1E);
  final cardColor = const Color(0xFF2D2D2D);
  final textPrimaryColor = const Color(0xFFE0E0E0);
  final textSecondaryColor = const Color(0xFFB0B0B0);

  String? _marque, _modele, _annee, _immatriculation, _imageUrl;
  int? _kilometrage;
  File? _imageFile;

  // Structure de données organisée par marque avec leurs modèles correspondants
  final Map<String, List<String>> marquesModeles = {
    'Peugeot': ['308', '208', '2008', '207'],
    'Renault': ['Clio',],

    'Toyota': ['Corolla', 'Yaris'],
    'Dacia': ['Sandero', 'Duster', 'Spring'],
    'BMW': ['Serie 1', 'Serie 3',],
    'Mercedes': ['Classe A', 'Classe C', 'Classe E'],

  };

  final List<String> annees = ['2020', '2021', '2022', '2023'];

  // Liste des modèles disponibles selon la marque sélectionnée
  List<String> modelesDisponibles = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Méthode pour mettre à jour les modèles selon la marque sélectionnée
  void _onMarqueChanged(String? marque) {
    setState(() {
      _marque = marque;
      _modele = null; // Réinitialiser le modèle
      if (marque != null && marquesModeles.containsKey(marque)) {
        modelesDisponibles = marquesModeles[marque]!;
      } else {
        modelesDisponibles = [];
      }
    });
  }

  // Validation des données avant l'envoi
  bool _isValidVehicle() {
    if (_marque == null || _modele == null) return false;

    // Vérifier que le modèle correspond bien à la marque
    if (!marquesModeles.containsKey(_marque!) ||
        !marquesModeles[_marque!]!.contains(_modele!)) {
      return false;
    }

    return true;
  }

  Future<void> _pickerImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File image) async {
    final cloudName = 'your_cloud_name';
    final uploadPreset = 'your_upload_preset';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);
      return data['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> _ajouterVehicule() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validation supplémentaire pour la cohérence marque/modèle
      if (!_isValidVehicle()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Combinaison marque/modèle invalide')),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final vehiculeRef = FirebaseFirestore.instance.collection('vehicules').doc();

        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToCloudinary(_imageFile!);
          if (imageUrl == null) {
            throw Exception("Échec de l'upload de l'image");
          }
        }

        await vehiculeRef.set({
          'vehiculeId': vehiculeRef.id,
          'marque': _marque,
          'modele': _modele,
          'annee': _annee,
          'immatriculation': _immatriculation,
          'kilometrage': _kilometrage,
          'imageUrl': imageUrl,
          'userId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _success = true;
          _nouveauVehiculeNom = '$_marque $_modele';
          _isLoading = false;
        });

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Erreur : ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccessView();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Ajouter un véhicule',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFormCard(),
                const SizedBox(height: 24),
                _buildImageSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
            accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.directions_car,
              color: textPrimaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouveau véhicule',
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Remplissez les informations ci-dessous',
                  style: TextStyle(
                    color: textPrimaryColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du véhicule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            Divider(
              height: 24,
              color: Colors.white.withOpacity(0.2),
            ),
            _buildFormField(
              'Marque',
              Icons.car_repair,
              _buildDropdown(
                  marquesModeles.keys.toList(),
                  _onMarqueChanged,
                  'Choisissez une marque'
              ),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Modèle',
              Icons.model_training,
              _buildDropdown(
                  modelesDisponibles,
                      (val) => _modele = val,
                  'Choisissez d\'abord une marque',
                  enabled: _marque != null
              ),
            ),
            if (_marque != null && modelesDisponibles.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Aucun modèle disponible pour cette marque',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildFormField(
              'Année',
              Icons.calendar_today,
              _buildDropdown(annees, (val) => _annee = val, 'Choisissez une année'),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Immatriculation',
              Icons.confirmation_number,
              _buildTextField((val) => _immatriculation = val, 'Entrez l\'immatriculation'),
            ),
            const SizedBox(height: 16),
            _buildFormField(
              'Kilométrage',
              Icons.speed,
              _buildTextField(
                    (val) => _kilometrage = int.tryParse(val ?? '0'),
                'Entrez le kilométrage',
                isNumber: true,
                suffix: 'km',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, IconData icon, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [accentColor, primaryColor],
              ).createShader(bounds),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [accentColor, primaryColor],
              ).createShader(bounds),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
            color: surfaceColor,
          ),
          child: field,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [accentColor, primaryColor],
                ).createShader(bounds),
                child: const Icon(Icons.photo_camera, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [accentColor, primaryColor],
                ).createShader(bounds),
                child: const Text(
                  'Photo du véhicule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imageFile == null)
            GestureDetector(
              onTap: _pickerImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: accentColor.withOpacity(0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: surfaceColor,
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      accentColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [accentColor, primaryColor],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Appuyez pour ajouter une photo',
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Optionnel',
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _imageFile = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (_imageFile == null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _pickerImage,
              icon: Icon(Icons.image, color: accentColor),
              label: Text(
                'Sélectionner depuis la galerie',
                style: TextStyle(color: accentColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _ajouterVehicule,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: textPrimaryColor,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ajout en cours...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimaryColor,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: textPrimaryColor),
            const SizedBox(width: 8),
            Text(
              'Ajouter ce véhicule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Succès',
          style: TextStyle(color: textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: textPrimaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.2),
                      accentColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [accentColor, primaryColor],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [accentColor, primaryColor],
                ).createShader(bounds),
                child: const Text(
                  'Véhicule ajouté !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_nouveauVehiculeNom a été ajouté avec succès à votre garage.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Retour au garage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimaryColor,
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

  Widget _buildDropdown(List<String> items, void Function(String?) onChanged, String validatorText, {bool enabled = true}) {
    return DropdownButtonFormField<String>(
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(color: textPrimaryColor),
        ),
      )).toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: enabled ? null : validatorText,
        hintStyle: TextStyle(color: textSecondaryColor),
      ),
      validator: (val) => val == null ? validatorText : null,
      dropdownColor: surfaceColor,
      style: TextStyle(color: enabled ? textPrimaryColor : textSecondaryColor),
      iconEnabledColor: enabled ? accentColor : textSecondaryColor,
    );
  }

  Widget _buildTextField(Function(String?) onSaved, String hint, {bool isNumber = false, String? suffix}) {
    return TextFormField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onSaved: onSaved,
      validator: (val) => val == null || val.isEmpty ? hint : null,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: hint,
        hintStyle: TextStyle(color: textSecondaryColor),
        suffixText: suffix,
        suffixStyle: TextStyle(color: textSecondaryColor),
      ),
      style: TextStyle(color: textPrimaryColor),
    );
  }
}