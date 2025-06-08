import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../LoginScreen.dart';

class ProfilClientPage extends StatefulWidget {
  const ProfilClientPage({Key? key}) : super(key: key);

  @override
  State<ProfilClientPage> createState() => _ProfilClientPageState();
}

class _ProfilClientPageState extends State<ProfilClientPage> with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Configuration Cloudinary
  final String cloudName = 'votre_cloud_name';
  final String uploadPreset = 'votre_upload_preset';

  // Couleurs du thème
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color secondaryDark = Color(0xFF1B263B);
  static const Color accentGreen = Color(0xFF00D4AA);
  static const Color accentBlue = Color(0xFF4CC9F0);
  static const Color cardDark = Color(0xFF2D3748);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color dangerRed = Color(0xFFEF4444);

  String? nom;
  String? prenom;
  String? email;
  String? telephone;
  String? photoUrl;
  bool isLoading = true;
  bool isUploadingImage = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    final emailUser = _auth.currentUser?.email;

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      setState(() {
        nom = userData?['nom'] ?? 'Non défini';
        prenom = userData?['prenom'] ?? 'Non défini';
        email = emailUser ?? 'Non défini';
        telephone = userData?['telephone'] ?? 'Non défini';
        photoUrl = userData?['photoUrl'];
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      print('Erreur de chargement : $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return;

    setState(() {
      isUploadingImage = true;
    });

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = json.decode(await response.stream.bytesToString());
        final imageUrl = responseData['secure_url'];
        final uid = _auth.currentUser?.uid;

        await _firestore.collection('users').doc(uid).update({
          'photoUrl': imageUrl,
        });

        setState(() {
          photoUrl = imageUrl;
          isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: accentGreen),
                const SizedBox(width: 8),
                const Text('Photo mise à jour avec succès'),
              ],
            ),
            backgroundColor: cardDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        throw Exception('Erreur Cloudinary');
      }
    } catch (e) {
      print('Erreur Cloudinary : $e');
      setState(() {
        isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: dangerRed),
              const SizedBox(width: 8),
              const Text('Échec du chargement de la photo'),
            ],
          ),
          backgroundColor: cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentGreen.withOpacity(0.8),
                accentBlue.withOpacity(0.8),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryDark,
              secondaryDark,
              primaryDark,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, accentBlue],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Chargement du profil...",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo de profil et nom
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [accentGreen, accentBlue],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentGreen.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: cardDark,
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl!)
                                      : null,
                                  child: photoUrl == null
                                      ? Icon(
                                    Icons.person_rounded,
                                    size: 60,
                                    color: textSecondary,
                                  )
                                      : null,
                                ),
                              ),
                              if (isUploadingImage)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [accentGreen, accentBlue],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentGreen.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '$prenom $nom',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentGreen.withOpacity(0.2),
                                accentBlue.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accentGreen.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Client',
                            style: TextStyle(
                              color: accentGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Informations personnelles
                  _buildSectionTitle('Informations personnelles', Icons.person_rounded),
                  const SizedBox(height: 16),
                  _buildInfoCard(children: [
                    _buildInfoItem(Icons.badge_rounded, 'Nom complet', '$prenom $nom'),
                    _buildInfoItem(Icons.email_rounded, 'Email', email ?? 'Non défini'),
                    _buildInfoItem(Icons.phone_rounded, 'Téléphone', telephone ?? 'Non défini'),
                  ]),
                  const SizedBox(height: 32),

                  // Bouton de déconnexion
                  Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            dangerRed.withOpacity(0.8),
                            dangerRed,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: dangerRed.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: cardDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                'Confirmation',
                                style: TextStyle(color: textPrimary),
                              ),
                              content: Text(
                                'Êtes-vous sûr de vouloir vous déconnecter ?',
                                style: TextStyle(color: textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Annuler',
                                    style: TextStyle(color: textSecondary),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => LoginScreen()),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: dangerRed,
                                  ),
                                  child: const Text('Déconnecter'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Se déconnecter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentGreen.withOpacity(0.2),
                accentBlue.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardDark,
            cardDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentGreen.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentGreen.withOpacity(0.2),
                  accentBlue.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}