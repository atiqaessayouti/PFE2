import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DemandeEntretienPage extends StatefulWidget {
  @override
  _DemandeEntretienPageState createState() => _DemandeEntretienPageState();
}

class _DemandeEntretienPageState extends State<DemandeEntretienPage>
    with TickerProviderStateMixin {
  String? selectedVehiculeId;
  DateTime? selectedDate;
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _gradientController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _gradientController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
    _gradientController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> sendRequest() async {
    if (selectedVehiculeId == null || selectedDate == null || descriptionController.text.isEmpty) {
      _showCustomSnackBar(
        'Veuillez remplir tous les champs.',
        Colors.deepOrange.shade400,
        Icons.error_outline,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final vehiculeDoc = await FirebaseFirestore.instance
          .collection('vehicules')
          .doc(selectedVehiculeId)
          .get();

      final vehiculeData = vehiculeDoc.data() as Map<String, dynamic>;
      final nomVehicule = '${vehiculeData['marque']} ${vehiculeData['modele']}';

      await FirebaseFirestore.instance.collection('demandesEntretiens').add({
        'clientId': FirebaseAuth.instance.currentUser!.uid,
        'vehiculeId': selectedVehiculeId,
        'nomVehicule': nomVehicule,
        'dateDemande': FieldValue.serverTimestamp(),
        'dateSouhaitee': Timestamp.fromDate(selectedDate!),
        'statut': 'En attente',
        'description': descriptionController.text,
        'garagisteId': null,
        'reponse': '',
      });

      _showCustomSnackBar(
        'Demande envoyée avec succès!',
        Colors.teal.shade400,
        Icons.check_circle_outline,
      );

      await Future.delayed(Duration(milliseconds: 1500));
      Navigator.pop(context);
    } catch (e) {
      print("Erreur : $e");
      _showCustomSnackBar(
        'Erreur lors de l\'envoi de la demande.',
        Colors.deepOrange.shade400,
        Icons.error_outline,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> getVehicules() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('vehicules')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs;
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * (index + 1)),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E).withOpacity(0.9),
                    Color(0xFF16213E).withOpacity(0.8),
                    Color(0xFF0F3460).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF6B35).withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Color(0xFF4ECDC4).withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(-5, -5),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Color(0xFF4ECDC4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(
          "Demande d'entretien",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                    Color(0xFF4ECDC4).withOpacity(0.8),
                    Color(0xFFFF6B35).withOpacity(0.7),
                  ],
                  stops: [
                    0.0,
                    0.3,
                    0.6,
                    0.8 + _gradientAnimation.value * 0.2,
                    1.0,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Color(0xFFFF6B35).withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 2.0,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              Color(0xFF0A0A0F),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<List<QueryDocumentSnapshot>>(
            future: getVehicules(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4ECDC4),
                              Color(0xFFFF6B35),
                              Color(0xFF1B4D3E),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4ECDC4).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Chargement des véhicules...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final vehicules = snapshot.data!;
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    // Card pour la sélection du véhicule
                    _buildAnimatedCard(
                      index: 0,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4ECDC4),
                                        Color(0xFFFF6B35),
                                        Color(0xFF1B4D3E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF4ECDC4).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.directions_car_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Sélectionner le véhicule",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1A1A2E).withOpacity(0.6),
                                    Color(0xFF16213E).withOpacity(0.4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFF4ECDC4).withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFF6B35).withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<String>(
                                hint: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "Choisir un véhicule",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                value: selectedVehiculeId,
                                dropdownColor: Color(0xFF16213E),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                items: vehicules.map((vehicule) {
                                  final data = vehicule.data() as Map<String, dynamic>;
                                  return DropdownMenuItem<String>(
                                    value: vehicule.id,
                                    child: Text(
                                      '${data['marque']} ${data['modele']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedVehiculeId = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Card pour la description
                    _buildAnimatedCard(
                      index: 1,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B35),
                                        Color(0xFF4ECDC4),
                                        Color(0xFF1B4D3E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFFF6B35).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.description_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "Description du problème",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1A1A2E).withOpacity(0.6),
                                    Color(0xFF16213E).withOpacity(0.4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFFFF6B35).withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF4ECDC4).withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: descriptionController,
                                maxLines: 5,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Décrivez en détail le problème rencontré avec votre véhicule...",
                                  hintStyle: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Card pour la date
                    _buildAnimatedCard(
                      index: 2,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1B4D3E),
                                        Color(0xFF4ECDC4),
                                        Color(0xFFFF6B35),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF1B4D3E).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Date souhaitée",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1A1A2E).withOpacity(0.6),
                                          Color(0xFF16213E).withOpacity(0.4),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Color(0xFF1B4D3E).withOpacity(0.4),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFFFF6B35).withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.event_available,
                                          color: selectedDate == null
                                              ? Colors.white60
                                              : Color(0xFF4ECDC4),
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          selectedDate == null
                                              ? "Aucune date sélectionnée"
                                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                          style: TextStyle(
                                            color: selectedDate == null
                                                ? Colors.white60
                                                : Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF4ECDC4),
                                              Color(0xFFFF6B35),
                                              Color(0xFF1B4D3E),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF4ECDC4).withOpacity(0.5),
                                              blurRadius: 15,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final now = DateTime.now();
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: now,
                                              firstDate: now,
                                              lastDate: DateTime(now.year + 1),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: ColorScheme.dark(
                                                      primary: Color(0xFF4ECDC4),
                                                      surface: Color(0xFF16213E),
                                                      onSurface: Colors.white,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                selectedDate = picked;
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            Icons.calendar_today_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          label: Text(
                                            "Choisir",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Bouton d'envoi
                    Center(
                      child: AnimatedBuilder(
                        animation: _gradientAnimation,
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4ECDC4),
                                  Color(0xFFFF6B35),
                                  Color(0xFF1B4D3E),
                                ],
                                stops: [
                                  0.0,
                                  0.5 + _gradientAnimation.value * 0.3,
                                  1.0,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4ECDC4).withOpacity(0.6),
                                  blurRadius: 25,
                                  offset: Offset(0, 12),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Color(0xFFFF6B35).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: isLoading
                                ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "Envoi en cours...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              label: Text(
                                "Envoyer la demande",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              onPressed: sendRequest,
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}