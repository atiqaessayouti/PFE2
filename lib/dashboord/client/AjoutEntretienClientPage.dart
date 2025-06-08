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
  final _prixController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedVehicule;
  List<Map<String, dynamic>> _vehicules = [];
  bool _isLoading = true;

  // Couleurs pour le thème sombre
  static const Color _primaryColor = Color(0xFF1E88E5);
  static const Color _secondaryColor = Color(0xFF42A5F5);
  static const Color _backgroundColor = Color(0xFF0A0E13);
  static const Color _surfaceColor = Color(0xFF1A1E23);
  static const Color _cardColor = Color(0xFF252A32);
  static const Color _textPrimaryColor = Color(0xFFE1E4E8);
  static const Color _textSecondaryColor = Color(0xFFB0B8C1);
  static const Color _accentColor = Color(0xFF00E676);
  static const Color _warningColor = Color(0xFFFFB74D);
  static const Color _errorColor = Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    _loadVehicules();
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _prixController.dispose();
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
          'nom': doc['marque'],
          'immatriculation': doc['immatriculation'] ?? '',
        }).toList();

        setState(() {
          _vehicules = vehiculesList;
          _isLoading = false;
        });
      } else {
        _showSnackBar("Erreur d'authentification", isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Erreur: ${e.toString()}", isError: true);
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
        'userId': user.uid,
        'service': _serviceController.text.trim(),
        'prix': double.tryParse(_prixController.text.trim()) ?? 0.0,
        'date': "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
        'statut': 'À venir',
        'dateCréation': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Entretien planifié avec succès", isSuccess: true);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Erreur: ${e.toString()}", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline :
              isSuccess ? Icons.check_circle_outline : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? _errorColor :
        isSuccess ? _accentColor : _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildStyledCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surfaceColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  InputDecoration _getInputDecoration({
    required String labelText,
    String? hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: _textSecondaryColor, fontSize: 14),
      hintStyle: TextStyle(color: _textSecondaryColor.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: _primaryColor, size: 22),
      filled: true,
      fillColor: _surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        primaryColor: _primaryColor,
        colorScheme: const ColorScheme.dark(
          primary: _primaryColor,
          secondary: _secondaryColor,
          surface: _surfaceColor,
          background: _backgroundColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text(
            "Planifier un entretien",
            style: TextStyle(
              color: _textPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _surfaceColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: _textPrimaryColor),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_surfaceColor, _cardColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: _primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                "Chargement...",
                style: TextStyle(
                  color: _textSecondaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_vehicules.isEmpty)
                  _buildStyledCard(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _warningColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: _warningColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Aucun véhicule enregistré",
                          style: TextStyle(
                            color: _textPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Vous devez d'abord ajouter un véhicule pour planifier un entretien",
                          style: TextStyle(
                            color: _textSecondaryColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Ajouter navigation vers AjouterVehiculePage
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text("Ajouter un véhicule"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _warningColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_vehicules.isNotEmpty) ...[
                  _buildStyledCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.directions_car, color: _primaryColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Sélection du véhicule",
                              style: TextStyle(
                                color: _textPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedVehicule,
                          onChanged: (val) => setState(() => _selectedVehicule = val),
                          items: _vehicules.map((v) {
                            return DropdownMenuItem<String>(
                              value: v['id'],
                              child: Text(
                                "${v['nom']} - ${v['immatriculation']}",
                                style: const TextStyle(color: _textPrimaryColor),
                              ),
                            );
                          }).toList(),
                          decoration: _getInputDecoration(
                            labelText: "Véhicule",
                            hintText: "Choisissez votre véhicule",
                            icon: Icons.directions_car,
                          ),
                          validator: (value) => value == null ? "Veuillez choisir un véhicule" : null,
                          dropdownColor: _cardColor,
                          style: const TextStyle(color: _textPrimaryColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildStyledCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.build, color: _accentColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Détails du service",
                              style: TextStyle(
                                color: _textPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _serviceController,
                          style: const TextStyle(color: _textPrimaryColor),
                          decoration: _getInputDecoration(
                            labelText: "Service souhaité",
                            hintText: "Vidange, Révision, Freinage...",
                            icon: Icons.build,
                          ),
                          validator: (value) => value!.isEmpty ? "Champ requis" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _prixController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: _textPrimaryColor),
                          decoration: _getInputDecoration(
                            labelText: "Prix estimé (€)",
                            hintText: "49.99",
                            icon: Icons.euro,
                          ),
                          validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildStyledCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.calendar_today, color: _secondaryColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Date souhaitée",
                              style: TextStyle(
                                color: _textPrimaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: _primaryColor,
                                      onPrimary: Colors.white,
                                      surface: _cardColor,
                                      onSurface: _textPrimaryColor,
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
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedDate != null ? _primaryColor : Colors.transparent,
                                width: _selectedDate != null ? 2 : 0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: _selectedDate != null ? _primaryColor : _textSecondaryColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDate == null
                                      ? "Sélectionner une date"
                                      : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                                  style: TextStyle(
                                    color: _selectedDate != null ? _textPrimaryColor : _textSecondaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _planifierEntretien,
                      icon: const Icon(Icons.schedule, size: 24),
                      label: const Text(
                        "Planifier l'entretien",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}