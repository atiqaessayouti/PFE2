import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AjouterEntretienGaragistePage extends StatefulWidget {
  const AjouterEntretienGaragistePage({Key? key}) : super(key: key);

  @override
  State<AjouterEntretienGaragistePage> createState() => _AjouterEntretienGaragistePageState();
}

class _AjouterEntretienGaragistePageState extends State<AjouterEntretienGaragistePage> {
  final _formKey = GlobalKey<FormState>();
  final _vehiculeController = TextEditingController();
  final _serviceController = TextEditingController();
  final _heureController = TextEditingController();
  final _prixController = TextEditingController();

  DateTime? _selectedDate;

  // Couleurs du thème sombre vert/bleu
  static const Color _backgroundColor = Color(0xFF0D1117);
  static const Color _surfaceColor = Color(0xFF161B22);
  static const Color _primaryGreen = Color(0xFF00D9FF);
  static const Color _accentBlue = Color(0xFF58A6FF);
  static const Color _cardColor = Color(0xFF21262D);
  static const Color _textPrimary = Color(0xFFF0F6FC);
  static const Color _textSecondary = Color(0xFF8B949E);
  static const Color _borderColor = Color(0xFF30363D);

  void _ajouterEntretien() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (_formKey.currentState!.validate() && _selectedDate != null && currentUser != null) {
      try {
        final uid = currentUser.uid;

        await FirebaseFirestore.instance.collection('entretiens').add({
          'vehicule': _vehiculeController.text.trim(),
          'service': _serviceController.text.trim(),
          'heure': _heureController.text.trim(),
          'prix': _prixController.text.trim(),
          'date': Timestamp.fromDate(_selectedDate!),
          'dateCréation': Timestamp.now(),
          'statut': 'À venir',
          'garagisteId': uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Entretien ajouté avec succès"),
            backgroundColor: _primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e"),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tous les champs sont requis."),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Ajouter un entretien",
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textPrimary),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _backgroundColor,
              _surfaceColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                _buildTextField(_vehiculeController, "Nom du véhicule", Icons.directions_car),
                _buildTextField(_serviceController, "Service", Icons.build),
                _buildTextField(_heureController, "Heure (ex: 09:00)", Icons.access_time),
                _buildTextField(_prixController, "Prix (ex: 50.0)", Icons.attach_money),
                const SizedBox(height: 20),
                _buildDateSelector(),
                const SizedBox(height: 32),
                _buildAddButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(color: _textPrimary, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: _textSecondary, fontSize: 14),
            prefixIcon: Icon(icon, color: _accentBlue, size: 22),
            filled: true,
            fillColor: _cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red[400]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
          validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: _primaryGreen,
                      onPrimary: _backgroundColor,
                      surface: _cardColor,
                      onSurface: _textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: _accentBlue, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? "Sélectionner une date"
                        : "Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: TextStyle(
                      color: _selectedDate == null ? _textSecondary : _textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: _textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [_primaryGreen, _accentBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _ajouterEntretien,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Ajouter",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _vehiculeController.dispose();
    _serviceController.dispose();
    _heureController.dispose();
    _prixController.dispose();
    super.dispose();
  }
}